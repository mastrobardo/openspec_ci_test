# Session 2026-11-12 (claude): PR #2 Apply failure → plan prompt rule (020)

- Resumed per `docs/PROGRESS.md` resume rule; proposed the README outline (step 9), then paused:
  the user asked to check run 43172704001 (PR #2, task-2, model opus, Apply on "Ready for review").
- Diagnosis: Apply failed at `tasks-complete` — task 2.2 required opening the page with
  `pnpm preview`/`pnpm dev`. Two permission denials (background server; `vite build --outDir /tmp`).
  The agent grepped `dist/` instead and correctly left 2.2 unticked. Guards, build, lint OK;
  nothing pushed. Root cause: Plan prompt had no "CI-doable tasks only" rule.
- Decision (user): Claude adds the plan rule (020); the user unblocks PR #2 with `/reapply` (2a).
  Checked first: `/reapply` with no `applied_at` collects all feedback and runs mode=reapply, which
  applies every unticked task (so the unpushed `<h1>` edit is redone).
- Changed: `scripts/prompts/plan.md` (rule), `memory/repo/ci-gotchas.md`, `memory/repo/poc-results.md`
  (§3b PR #2 run log, problem row), `docs/PROGRESS.md` (row 12, next action; README becomes 021).
- Skills: `debugging-and-error-recovery` (root cause from the run artifact: result text +
  `permission_denials`); `documentation-and-adrs` listed for the README (not used yet).

## 021: failure-aware run summary (user request after 020)
- User: the job summary (model, turns, cost, denials) is fine for a pass but says nothing about why
  a run failed. Agreed: shared `scripts/run-summary.sh` for all stages; PR comment on failure for
  Apply and re-apply only (Verify already comments its verdict).
- Built: `run-summary.sh`; `record`/`detail` in `openspec-ops.sh` and `run-agent.sh`; inline
  `::error::` lines `tee -a` the same file; step ids everywhere; build/lint → `build.log`; summary
  step before upload (`summary.md` in the artifact); "Comment on failure" step in Apply; archive
  job gets a failure summary.
- Tested locally: real `apply.json` from run 43172704001 + the real `tasks-complete` failure
  reproduce the expected block (failed step, unticked line, Deviations, both denials); synthetic
  Verify FAIL, agent `is_error`, build failure, early inline failure; ops exit codes unchanged.
  YAML parse, `bash -n` per `run:`, no `${{ }}` in `run:`, actionlint (only old style notes).
- Skills: `ci-cd-and-automation` (workflow changes), `test-driven-development` not used formally
  (scenario tests with real run data instead).

## 022: PR #2 complete + Verify full-history checkout
- `/reapply` 43173962826 ✅ (33 turns, $0.41); Verify 43175121120 ✅ PASS from a real Approve
  (22 turns, $0.38, 1 denial `git fetch --depth=2 origin main`); gate → archive (13 s) → squash
  merge `930a91b` at 07:28Z. PR #2 total 29 min.
- Fix: Verify checkout `fetch-depth: 0`, `verify.md` hint `git diff origin/main...HEAD`.
- Records: poc-results §3b (rows, PR #2 final), §5 problem row, §9; PROGRESS row 14 and next action
  (README → 023); ci-gotchas.

## 023: README (step 9)
- Replaced the Vite template README: summary, lifecycle diagram, layout, setup (token one-liner,
  Actions settings, `openspec-archive` environment, squash-only), triggers + dispatch fallbacks,
  rules (D9–D13, CI-doable tasks), failure summary (021), troubleshooting, local testing.
- Facts checked against the code: `/reapply` bare = trigger only (pr-feedback drops it; fails with
  no feedback since `applied_at`); archive fallback = dispatch Verify.
- Skill: `documentation-and-adrs` (README structure: what/why first, setup, usage, troubleshooting).

## 024: trampoline (D15)
- `openspec-events.yml`: ready_for_review → Apply mode=apply; changes_requested → Apply
  mode=reapply; approved → Verify approved_sha=review.commit_id; on the default branch.
- Apply: no PR-event triggers, `mode` input (auto/apply/reapply; comments force reapply).
  Verify: no review trigger, `approved_sha` input drives the stale-approval check.
- Tested: routing of 4 event cases with a stub `gh`; Apply mode selection for 8 cases; YAML,
  `bash -n`, no `${{ }}` in `run:`, actionlint (only old style notes).
- Skill: `ci-cd-and-automation`.

