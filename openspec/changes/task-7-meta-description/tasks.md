## 1. Implement

- [ ] 1.1 In `index.html`, add `<meta name="description" content="Proof of concept: OpenSpec changes driven by Claude Code in GitHub Actions." />` inside `<head>` after the `<title>` line, leaving all other lines unchanged.

## 2. Verify

- [ ] 2.1 Search `index.html` and confirm exactly one `name="description"` meta with the exact content, no `og:` tags, and that title, charset, viewport and icon lines are unchanged (`git diff index.html` shows only an added line).
- [ ] 2.2 Run `pnpm build`, then search `dist/index.html` for the meta description (once).
- [ ] 2.3 Run `pnpm lint` and confirm it succeeds.
- [ ] 2.4 Run `git diff --name-only` and confirm that outside `openspec/` only `index.html` changed (nothing in `src/`).
