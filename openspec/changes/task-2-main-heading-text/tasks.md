# Tasks

## 1. Heading text

- [x] 1.1 In `src/App.tsx`, change `<h1>Get started</h1>` to `<h1>OpenSpec CI POC</h1>`. Verify that `src/App.tsx` contains exactly one `<h1>`, that its text is exactly `OpenSpec CI POC`, and that `Get started` no longer appears in `src/` (spec: "Main page heading names the project", both scenarios).
- [x] 1.2 Verify that `git diff --stat` shows only `src/App.tsx` changed (outside `openspec/`) and that `git diff src/App.tsx` shows a single changed line, the `<h1>` line. `index.html` (title `openspec-ci-poc`) and all CSS files must be unmodified (spec: "Other page text is unchanged", both scenarios).

## 2. Verification

- [x] 2.1 Run `pnpm build` and `pnpm lint` and verify that both exit 0 (spec: "Build and lint succeed").
- [x] 2.2 After the build, search `dist/` and verify that it contains "OpenSpec CI POC" and no longer contains "Get started" (specs: "Main page heading names the project", "Other page text is unchanged"). The visual check in a browser (`pnpm preview`/`pnpm dev`) cannot run in CI. It is left to the reviewer as a note in the re-apply report (F1).

## 3. Review follow-ups

- [x] 3.1 F1: Reword task 2.2 so it only covers the CI-runnable `dist/` search check (no `pnpm preview`/`pnpm dev`), keep the visual browser check as a reviewer note in the re-apply report, update the matching line in design.md, and tick 2.2 once the `dist/` check passes.
