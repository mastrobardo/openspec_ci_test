## 1. Implement

- [x] 1.1 In `index.html`, change `<title>openspec-ci-poc</title>` to `<title>OpenSpec CI POC</title>`; confirm with a search that exactly one `<title>` exists with that text.

## 2. Verify

- [x] 2.1 Run `pnpm build` and confirm it succeeds.
- [x] 2.2 Search `dist/index.html` for `<title>OpenSpec CI POC</title>`.
- [x] 2.3 Run `pnpm lint` and confirm it succeeds.
- [x] 2.4 Run `git diff --name-only` and confirm that, outside `openspec/`, only `index.html` changed (no favicon or React changes).
