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
| 8 | `openspec-verify.yml` (Approve + dispatch; read-only, no commit; verdict comment; stale-approval check), `guard-diff verify`, per-PR concurrency `openspec-pr-N` shared with Apply | done; ran on GitHub (dispatch; the approval event saw a stale merge ref) → FAIL for scope (→ D12) | 013 |
| 8a | Scope rule D12: re-apply writes `## Scope changes from review`; Verify: documented = NOTE, undocumented = FAIL | done; on GitHub, Verify correctly failed an inline (non-section) note → 015 | 014 |
| 8c | D12 enforced: `openspec-ops.sh scope-documented` after re-apply (proposal/specs changed → section with `- F<n>` required); literal format in the reapply prompt | done; passed on GitHub in run 43114321202 | 015 |
| 8b | `/reapply [text]` PR comment command (`issue_comment`, owner/member/collaborator only, 👀 ack, bare command dropped from feedback) | done; passed on GitHub (43114321202); a leading space skips it (accepted) | 016 |
| 8d | Settings via API: environment `openspec-archive` (required reviewer), squash-only merges | done | (API, 2026-11-11) |
| 8e | Gated archive: second Verify job (D13), job-level concurrency, Apply/Verify refuse archived | done; on GitHub run 43116149538 (dispatch) → gate approved → archived | 018 |
| 9 | README: lifecycle diagram, layout, setup, triggers + fallbacks, rules (D9–D14), failure summary, troubleshooting, local testing | done | 023 |
| 10 | User: push, add secret, change repo settings | done: pushed, secret set, Actions enabled, create/approve PRs allowed, default perms read (checked 2026-11-11) | |
| 11 | E2E run: Plan → draft PR → Ready → Apply → re-apply → Approve → Verify → archive → squash merge | **done**: PR #1 merged as `2362212` (2026-11-11 23:01Z) | 019 (record) |
| 11b | Fallback repo `arcibardo/openspec_ci` (Plan passed there → its PR #1); back on the old repo after the outage | done | 011 |
| 11c | Apply runs trusted scripts from the workflow commit (`$CI_SCRIPTS`), prompts next to the script | done; Apply + 2 re-applies passed on GitHub (PR #1, spec impact shown for the SHA requirement) | 012 |
| 12 | PR #2 (task-2, opus) Apply failed: Plan wrote a browser-check task CI cannot run → `plan.md` rule (tasks must be doable unattended; visual checks are reviewer notes). PR #2 unblocked by the user with `/reapply` | done (prompt); PR #2 unblocked by `/reapply` run 43173962826 (✅, 33 turns, $0.41) | 020 |
| 13 | Failure-aware run summary: `scripts/run-summary.sh` (failed step, recorded reason, agent's Deviations/Issues, denials, build/lint tail) in the job summary and artifact (`summary.md`) of Plan/Apply/Verify/archive; failed Apply/re-apply posts it as a PR comment; checks record reasons in `$RUNNER_TEMP/openspec-ci-failures.txt` | done (local tests on run 43172704001 data + synthetic cases, actionlint clean); **not yet run on GitHub** | 021 |
| 14 | PR #2 complete: Verify PASS (Approve) → gate → archived → squash merge `930a91b` in 29 min. Verify checkout `fetch-depth: 0` + diff hint in `verify.md` (the agent could not diff vs base) | done; fetch-depth **not yet run on GitHub** | 022 |
| 15 | Trampoline (D15): `openspec-events.yml` dispatches Apply (`mode=apply/reapply`) / Verify (`approved_sha`) on main; Apply/Verify lose PR-event triggers; Apply `mode` input; Verify stale check via `approved_sha` | done (routing simulated, actionlint clean); **not yet run on GitHub** | 024 |
| 16 | Third run: PR #4 (task-3) + PR #3 (task-4) in parallel, sonnet; trampoline, 020 rule, 022 checkout proven; both archives failed (new capability without delta `## Purpose`) → `new-specs-have-purpose` check (Plan/Apply/Verify), prompt example, archive `validate-all` | done (local tests on the real PR branches); PR #3/#4: Purpose commits + re-approve pending | 025 |
| 17 | Sync + resolve stage (D16): `openspec-sync.yml` (push to main, `/sync`, dispatch), agent `resolve` + `resolve.md`, `guard-resolve`, `spec-preflight` (also in Verify), per-task manifests, Purpose ≥ 50 chars; PR #3 unblocked by a manual merge; tasks 5–7 for the CI test | done; clean path proven on GitHub (Sync 43197508948: PRs #5–#7 in parallel, no agent); resolve path pending | 026 |
| 18 | Tasks 8–12 for manual E2E runs (not planned yet): 8 footer format + 9 footer year (same line and same `app-version-footer` requirement: code + spec conflict for `resolve`), 10 Reset disabled at 0 (review/`/reapply` candidate), 11 unit test without a test runner (expected Apply failure → failure comment), 12 README-only change | done (files only; the user runs Plan by hand) | 027 |
| 19 | Events ignores reviews on draft PRs (comment instead of a dispatch that Verify refuses); `run-name` with stage + task/PR title on every workflow (`label` input passed by the trampoline; Sync matrix `{pr, title}`) | done (actionlint clean, matrix JSON tested); **not yet run on GitHub** | 029 |

## Next action

State (2026-11-12): PR #1 and PR #2 (task-2, opus, 29 min, merged `930a91b`) are complete. **The full lifecycle is proven on GitHub.** PR #1 went Plan → Apply → re-apply ×5
(incl. `/reapply`) → Verify PASS → gated archive → squash merge `2362212`. `main` holds
`openspec/specs/app-version-footer/spec.md` and `openspec/changes/archive/2026-11-11-task-1-version-footer/`.
Full record for the presentation: `memory/repo/poc-results.md` (update it in every commit).

Step 9 (README, 023), the trampoline (024), the third run's fixes (025) and Sync (026) are done; PR #3/#4 merged. The user resumes with:
1. **CI test of 026 (sonnet)**: Plan task-5, task-6, task-7 → Ready ×3 → Approve + archive + merge
   **task-5 first**. The push to main starts Sync: task-6 should conflict on `src/App.tsx` → `resolve`
   agent (expected `Clicks: <strong>{count}</strong>`, delta rebased onto task-5's spec), task-7 should
   sync clean (no agent). Then re-approve 6 and 7 → Verify → gate → merge. Record in `poc-results.md`.
2. **Presentation** from `poc-results.md` (outline or deck on request).
3. Cleanup: delete `probe/007` on the old repo; optionally retire `arcibardo/openspec_ci`.

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
