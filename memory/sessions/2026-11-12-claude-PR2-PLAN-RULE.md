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
