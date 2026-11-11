---
name: ci-gotchas
description: GitHub Actions trigger/permission pitfalls relevant to the OpenSpec lifecycle
---

- Pushes and PRs created with `GITHUB_TOKEN` do not trigger other workflows. The lifecycle relies on
  human actions (Ready for review, Approve) as triggers, so this is fine.
- `gh pr create` from Actions needs "Allow GitHub Actions to create and approve pull requests"
  plus `pull-requests: write` permission.
- A check from `pull_request_review` is reported separately from `pull_request` checks; branch
  protection may need a `pull_request` trigger too.
- `claude -p` in CI cannot prompt for permissions: tool allowances must be passed as flags.
  Verify the flags with `claude --help`; never invent them.

Related: [[environment]]

Learned from local plan runs (2026-11-11):
- Locally, user-level hooks (e.g. an `rtk` command rewriter) and global CLAUDE.md leak into
  `claude -p`. `--setting-sources project` drops user settings/hooks; global CLAUDE.md still loads
  (only `--bare` removes it, but `--bare` disables subscription auth). CI has neither.
- `Bash(openspec:*)` does not match chained commands (`a && b`, `a; b`). Prompts tell the agent to run
  one command per call.
- `/opsx:*` slash commands run through the `Skill` tool, which must be in `--allowedTools`.
- Check `.permission_denials` in the `--output-format json` result after each run.
- Repo state checked 2026-11-11 via `gh api repos/mastrobardo/openspec_ci_test/actions/permissions/workflow`:
  Actions enabled, `default_workflow_permissions: read`, `can_approve_pull_request_reviews: true`.
  Workflows must therefore declare explicit `permissions:` (contents/pull-requests: write).

Learned from the first CI plan run (2026-11-11, run 43091589972):
- A `CLAUDE_CODE_OAUTH_TOKEN` pasted from `claude setup-token` can carry the terminal's line wrap.
  Symptom: `turns=1 cost_usd=0 is_error=true`; the cause is in `.result` of `plan.json`
  ("contains a line break"). Fix: `pbpaste | tr -d ' \r\n' | gh secret set CLAUDE_CODE_OAUTH_TOKEN`.
  `run-agent.sh` now rejects whitespace in the token before calling the agent.
- With no `--model`, CI used `claude-sonnet-5-5` (local runs used `claude-fable-5-1`). Workflows
  therefore take a `model` dropdown (`sonnet`/`opus`/`fable` aliases; default `sonnet`).
- Re-running a failed run keeps the run id, and both attempts upload an artifact with the same name.
  `gh run download <id>` then fails with "file exists" unless each attempt goes into a fresh
  directory. The manifest records `plan_run_attempt`.

Learned building Apply (2026-11-11):
- `pull_request` events check out the merge ref by default. Apply must check out the PR head branch
  (`ref: <headRefName>`) so it can commit and push back to it.
- A PR authored by `github-actions` can be approved or have changes requested by the repo owner
  (GitHub blocks both on your own PRs), so the human gates work with bot-opened PRs.
- `pnpm build` (tsc -b + vite) leaves no untracked files outside ignored dirs, so `git add -A` after
  Apply only picks up the agent's changes, which `guard-diff` has already checked.
- Local test harness on zsh: `$CMD args` with `CMD="bash x.sh"` does not word-split. Use a function.

Learned testing Apply on PR #1 (2026-11-11):
- `pull_request` / `pull_request_review` workflows run from the PR's **merge ref**
  (`refs/pull/N/merge`). GitHub rebuilds it lazily, so a PR opened before a workflow existed (or
  an event fired seconds after the push to main) silently starts nothing: no run, no error.
  Check with `git fetch origin refs/pull/N/merge` + `git ls-tree` on `.github/workflows/`.
  Fallback: `gh workflow run "OpenSpec Apply" -f pr=N` (dispatch runs from main). This hits every
  new workflow in this POC on existing PRs.
- During a GitHub webhooks incident, dispatched runs stayed `queued` with no jobs. `gh run cancel`
  said "completed", `force-cancel` said "not queued yet" (409), and `gh run delete` gave a 403,
  even after the incident was resolved. Leave them to expire (~24h) or contact GitHub Support. Runs with no jobs have not used any Claude quota.
- Those runs were in fact `completed/startup_failure`. The **list** endpoint
  (`actions/runs?per_page=N`) showed that; the single-run endpoint and the UI kept saying
  `queued`. Trust the list endpoint.
- `startup_failure` on every run from ~20:20Z on 2026-11-11 was a **GitHub outage**: webhooks
  degraded, then a critical incident "Actions major outage" declared at 20:48Z. It is not shown on
  githubstatus.com until declared. The byte-identical 007 Plan workflow (green at 19:54Z) failed the
  same way on branch `probe/007`; after recovery the same account ran jobs again.
  Method: check githubstatus.com, re-run a known-good commit, and wait for a queued run to finish
  (it can sit queued for about 5 min) before blaming the code or the account.
- Lint workflows with `docker run --rm -v "$PWD":/repo:ro -w /repo rhysd/actionlint:1.7.7`.
  It is clean apart from shellcheck style notes (SC2016 on intentional backticks).
- **Version mismatch: workflow from main, scripts from the PR branch.** Apply checks out the PR
  branch; a branch cut before a script existed failed with `scripts/pr-feedback.sh: No such file or
  directory`. That was also a security gap (branch edits would run with the secret). Fix: check out
  the workflow commit, copy `scripts/` to `$RUNNER_TEMP/ci-scripts` (`$CI_SCRIPTS`), then check out
  the PR branch; `run-agent.sh` loads prompts from its own folder. Verify (step 8) must do the same.
- Test scripts end to end without quota by putting a stub `claude` first on PATH that prints a
  result JSON and saves its argv/prompt.
- zsh: quote `gh api` URLs that contain `?` (`'repos/o/r/actions/runs?per_page=3'`), otherwise
  zsh treats them as a glob and fails with "no matches found" (a background poller died silently).
- `gh api --help | grep` output is swallowed by the local `rtk` hook. Write help to a file first.
