# OpenSpec-in-CI POC — Plan

Goal: prove that an OpenSpec change lifecycle can be driven end to end by Claude Code running in
GitHub Actions, authenticated with a personal Claude subscription, with humans gating each stage
through normal PR actions.

## Lifecycle

```
Actions tab: "OpenSpec Plan" (input: task=task-1)
   │  reads tasks/task-1.txt
   │  claude -p: explore + /opsx:propose  (planning artifacts only, no src/ edits)
   │  openspec validate
   │  branch openspec/task-1, commit, gh pr create --draft
   ▼
Draft PR  ── human reviews the proposal/specs/tasks ──
   │  human clicks "Ready for review"
   ▼
"OpenSpec Apply"  (pull_request: ready_for_review)
   │  claude -p: /opsx:apply  (works through tasks.md)
   │  pnpm build && pnpm lint
   │  commit + push to the PR branch
   ▼
── human reviews the code, approves ──
   ▼
"OpenSpec Verify" (pull_request_review: submitted, state=approved; also workflow_dispatch)
   │  openspec validate --strict, all tasks ticked
   │  claude -p: /opsx:verify  → report posted as PR comment
   │  job status pass/fail (can be made a required check)
   ▼
Human merges.
```

## Decisions

| # | Decision | Why |
|---|----------|-----|
| D1 | This repo is the POC; work happens on `main`. | User decision. |
| D2 | Tasks are plain text files `tasks/task-N.txt`. | User decision; replaces Jira. |
| D3 | Auth: `claude setup-token` → repo secret `CLAUDE_CODE_OAUTH_TOKEN`. | Uses the Claude subscription, no API key. |
| D4 | Raw `claude` CLI (`claude -p`) in workflows, not `claude-code-action`. | Same invocation locally and in CI; transparent. |
| D5 | GitHub Actions only, no `act`. | User decision. |
| D6 | Agent logic lives in `scripts/run-agent.sh` + `scripts/prompts/*.md`; OpenSpec checks in `scripts/openspec-ops.sh`. Workflows only orchestrate. | Layer separation from the reference task, kept minimal. |
| D7 | Branch manifest `.openspec-ci/manifests/<task>.json` (one per task since 026; was `.openspec-ci/manifest.json`) (task, change id, stage, status, run ids, SHAs). | Audit trail beyond transient logs. |
| D8 | Out of scope: Jira, Codex/Copilot, act, archival, post-merge verify. | Verify the idea first. Archival can later be a step after a passing verify. |
| D9 | Single model choice: a dropdown at Plan (`sonnet`/`opus`/`fable`), saved as manifest `model`; Apply, re-apply and Verify read it. | User decision (2026-11-11). PR events have no inputs; one choice per PR. |
| D10 | Re-apply is triggered by a "Request changes" review (plus dispatch with `pr`). It reads only feedback newer than `applied_at` from users with write access. | User decision. Mirrors Approve → Verify; the commenter filter blocks prompt injection from outsiders. |
| D11 | During re-apply the agent classifies feedback: requirement → `/opsx:update` (delta specs may change), implementation → new tasks in tasks.md. The report has a Spec impact table; `guard-diff` lists changed artifacts. | User decision. Delta specs are still in flight until archive; changing them through OpenSpec keeps Verify honest. |
| D12 | After review, the amended change is the source of truth; the task file is the baseline. Re-apply records each requirement change in `proposal.md` → `## Scope changes from review` (Fn, reviewer, link, which task line it overrides). Verify reports documented differences as NOTE and undocumented ones as FAIL. | User decision (2026-11-11), after Verify failed PR #1 because the reviewer-requested SHA contradicts the task's out-of-scope list. Mirrors a reviewer amending the plan while the ticket is stale. |
| D13 | Archive = a second job in the Verify run, `needs: verify`, only after PASS, bound to environment `openspec-archive` (required reviewer = manual approval). Deterministic `openspec archive -y`, no agent. Job-level concurrency so a waiting archive never blocks Apply. | User decision (2026-11-11): a manual gate before archiving; the archive lands on the PR branch, so code + main specs + archived change merge together. |
| D14 | Squash-only merges, commit = PR title + body. | User decision (2026-11-11): the bot commits per stage are noise; the PR body describes the change. GitHub has no "default" method, so the others are disabled. |
| D15 | PR events (Ready for review, Request changes, Approve) only reach `openspec-events.yml`, which dispatches Apply (`mode`) or Verify (`approved_sha`) on the default branch. Apply/Verify have no PR-event triggers. | User decision (2026-11-12): PR-event workflows run from the lazily rebuilt merge ref (3 stale or missing runs on PR #1); dispatches always run the current workflow from `main`. |
| D16 | Sync stage: on every push to `main` (and `/sync`), merge `main` into each open OpenSpec PR that is behind. Clean → deterministic checks + push; conflict → agent `resolve` (main is law; adapt this change, incl. its own delta) behind `guard-resolve`; a spec preflight proves the change still archives onto main's specs. The push makes approvals stale: re-approve → Verify. | User decision (2026-11-12) after parallel PRs #3/#4 conflicted (on the shared manifest; real code/spec conflicts are next). GitHub's merge queue re-tests but never resolves. |

## Required GitHub settings (manual, by the repo owner)

1. Secret `CLAUDE_CODE_OAUTH_TOKEN` (from `claude setup-token`).
2. Settings → Actions → General → Workflow permissions: **Read and write**, and tick
   **Allow GitHub Actions to create and approve pull requests**.
3. Optional: branch protection on `main` requiring the "OpenSpec Verify" check.

## Known gotchas

- Events caused by `GITHUB_TOKEN` (push, PR create) do **not** trigger other workflows. Fine here,
  because the gating events (ready for review, approval) are human actions.
- A `pull_request_review` check is not the same as a `pull_request` check: for branch protection,
  verify may also need a `pull_request: synchronize` trigger. Decide in step 5.
- `claude -p` in CI needs tool permissions set non-interactively (`--allowedTools` /
  `--permission-mode`). Verify the flags against `claude --help` before use.

## Steps

See `docs/PROGRESS.md` for status. Every step after the OpenSpec init waits for user approval
before commit.
