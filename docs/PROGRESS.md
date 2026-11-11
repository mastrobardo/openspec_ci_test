# Progress map

Resume rule: read `docs/PLAN.md`, this file, and `memory/repo/*.md`, then continue from the first
unchecked step. **Every step needs explicit user approval before it is committed.**

| # | Step | Status | Commit |
|---|------|--------|--------|
| 1 | `openspec init --tools claude` (openspec/, .claude/commands/opsx, .claude/skills/openspec-*) | done | 80603ac |
| 2 | Plan, progress map, repo memory, session log | done | 953d591 (user) |
| 3 | `tasks/task-1.txt` sample task | done | 002 (4316fed) |
| 3b | `tasks/task-{2,3,4}.txt` (heading text, counter reset, tab title) | done | 003 (8ed97f3) |
| 4 | `scripts/run-agent.sh` + `scripts/prompts/{plan,apply,verify}.md` (plan stage verified locally) | done | 004 |
| 5 | `scripts/openspec-ops.sh` (change-id, validate, tasks-complete, guard-plan-diff, manifest); `.openspec-ci/runs/` gitignored | done | 006 |
| 6 | `.github/workflows/openspec-plan.yml` | done | 007 |
| 6b | Plan workflow: `model` dropdown (sonnet/opus/fable), token whitespace check, model + attempt in manifest | done | 008 |
| 7a | `openspec-apply.yml` first apply (`ready_for_review` + dispatch `pr`), `guard-diff`, manifest `model` alias | done (static + local tests); **not yet run on GitHub** (see Next action) | 009 |
| 7b | Re-apply with review feedback (`changes_requested`), `pr-feedback.sh`, `reapply` prompt/stage | done (static + simulated); **not yet run on GitHub** | 010 |
| 8 | `.github/workflows/openspec-verify.yml` | todo | |
| 9 | README: setup + run instructions | todo | |
| 10 | User: push, add secret, change repo settings | done: pushed, secret set, Actions enabled, create/approve PRs allowed, default perms read (checked 2026-11-11) | |
| 11 | E2E run: Plan → draft PR → Ready → Apply → Approve → Verify | plan passed in CI on the old repo (run 43091589972 → PR #1); GitHub outage 20:20–21:05Z; apply/verify todo | |
| 11b | Fallback repo `arcibardo/openspec_ci` (Plan passed there → its PR #1); back on the old repo after the outage | done | 011 |
| 11c | Apply runs trusted scripts from the workflow commit (`$CI_SCRIPTS`), prompts next to the script | done (stub-claude e2e on PR #1 branch) | 012 |

## Next action

GitHub had an Actions outage on 2026-11-11 (~20:20Z to ~21:05Z); all `startup_failure` runs date from
then. After recovery, Apply ran on the old repo and exposed a real bug (scripts run from the PR
branch were older than the workflow), fixed in 012. `origin` is the old repo again; `arcibardo` is
the fallback (see `memory/repo/environment.md`).

1. **Apply on PR #1 (old repo)**: `gh workflow run "OpenSpec Apply" -R mastrobardo/openspec_ci_test -f pr=1`
   (PR #1's merge ref is stale, so use dispatch). Expect mode `apply` and model `sonnet`, then a push
   of `openspec(task-1): apply …` and a PR comment. Check with
   `gh api 'repos/mastrobardo/openspec_ci_test/actions/runs?per_page=3'` (the list endpoint). If it fails:
   `gh run download <id> -R … -D <fresh dir>` and read `.result` / `.permission_denials` in `apply.json`.
2. **Re-apply test**: "Request changes" on PR #1 with comments (an inline nit + a requirement such as
   "also show the git SHA"); then dispatch `pr=1` again (stale merge ref). Expect mode `reapply`, a
   Spec impact box, follow-up tasks, and specs changed only for requirement items.
3. **Step 8: Verify** (plan to be shown first): `pull_request_review` approved (+ dispatch `pr`), model
   from the manifest, trusted `$CI_SCRIPTS` pattern, `tasks-complete` + `validate` +
   `run-agent.sh verify` (read-only), PR comment, exit 3/4 = failed check, per-PR concurrency group
   shared with Apply. Open question: also run on `synchronize` so it can be a required check?

Leftovers on the old repo: branch `probe/007` (safe to delete) and uncancellable `startup_failure`
runs from the outage.

## Facts for the next session

- Agreed decisions D9–D11 are in `docs/PLAN.md` (single model choice; re-apply trigger; spec changes
  through `/opsx:update` + Spec impact table).
- Manifest keys: `task change stage status model plan_model plan_run_id plan_run_attempt base_sha
  apply_run_id apply_run_attempt applied_at apply_count created_at updated_at`.
  `stage` is `plan`, `apply` or `reapply`; `applied_at` = start of the last (re)apply run and the
  cutoff for the next feedback collection.
  `model` = the alias picked at Plan, read by every later stage.
- `openspec-ops.sh` contract: exit 0 ok, 1 usage/setup error, 2 check failed.
  `guard-diff <apply|reapply> <change> <base-sha>` compares the working tree and untracked files
  against base-sha.
- Actions: checkout/setup-node/upload-artifact `@v7`, pnpm/action-setup `@v6` (pnpm 10); openspec
  `1.14.1`, claude-code `2.1.322`. Workflows are validated with PyYAML, `bash -n` on each `run:`,
  no `${{ }}` inside `run:`, and step-order checks for `steps.X` refs. actionlint and shellcheck
  are not installed.
- `scripts/pr-feedback.sh <pr> <since|-> <out>` prints the item count. `PR_FEEDBACK_INPUT=<json>`
  is a test hook that skips the API. The workflow writes feedback to `.openspec-ci/runs/feedback.md`
  (gitignored) and the guard's spec impact to `.openspec-ci/runs/spec-impact.txt`.
- PR #1 was authored by `github-actions`, so the owner can Approve or Request changes on it.
- Conventions: commits are numbered `NNN:` (`memory/repo/conventions.md`); every step waits for
  user approval before commit; re-confirm whenever the plan changes.

## Open questions

- Should Verify also run on `pull_request: synchronize` so it can be a required check? (step 8)
- Should archival be added after a passing verify? (out of scope for now)
