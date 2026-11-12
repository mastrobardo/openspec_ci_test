## 1. Implement

- [x] 1.1 In `src/App.tsx`, add `<button type="button" className="counter" onClick={() => setCount(0)}>Reset</button>` immediately after the existing counter button inside `<section id="center">`. Do not edit any CSS file.
- [x] 1.2 Verify by search that `src/App.tsx` contains exactly one `Reset` button, that it follows the "Count is" button, uses `className="counter"` and calls `setCount(0)`.

## 2. Verify

- [x] 2.1 Run `pnpm build` and confirm it succeeds.
- [x] 2.2 Run `pnpm lint` and confirm it succeeds.
- [x] 2.3 Search `dist/assets/*.js` for the string `Reset` to confirm it is in the build output.
- [x] 2.4 Confirm with `git diff --stat` that only `src/App.tsx` changed (besides `openspec/` files) and no `.css` file is modified.
