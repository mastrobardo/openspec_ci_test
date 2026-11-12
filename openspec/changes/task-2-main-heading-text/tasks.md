# Tasks

## 1. Heading text

- [ ] 1.1 In `src/App.tsx`, change `<h1>Get started</h1>` to `<h1>OpenSpec CI POC</h1>`. Verify that `src/App.tsx` contains exactly one `<h1>`, that its text is exactly `OpenSpec CI POC`, and that `Get started` no longer appears in `src/` (spec: "Main page heading names the project", both scenarios).
- [ ] 1.2 Verify that `git diff --stat` shows only `src/App.tsx` changed (outside `openspec/`) and that `git diff src/App.tsx` shows a single changed line, the `<h1>` line. `index.html` (title `openspec-ci-poc`) and all CSS files must be unmodified (spec: "Other page text is unchanged", both scenarios).

## 2. Verification

- [ ] 2.1 Run `pnpm build` and `pnpm lint` and verify that both exit 0 (spec: "Build and lint succeed").
- [ ] 2.2 After the build, grep `dist/assets` and verify that it contains "OpenSpec CI POC" and no longer contains "Get started". Then open the page with `pnpm preview` or `pnpm dev` and verify that the heading reads "OpenSpec CI POC" and the other text (paragraph, counter button, Documentation and Connect with us sections, version footer) is unchanged (specs: "Main page heading names the project", "Other page text is unchanged").
