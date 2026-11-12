## 1. Implementation
- [x] 1.1 In `src/App.tsx`, change `Count is {count}` to `Count is <strong>{count}</strong>` (keep the space; do not touch the Reset button or any CSS). Covers: number in strong, text preserved, Reset/styles untouched.

## 2. Verification
- [x] 2.1 Search `src/App.tsx` for `<strong>{count}</strong>` and confirm "Count is" is outside it and no CSS file changed (`git diff --stat` shows only `src/App.tsx`). Covers: text preserved, Reset/styles untouched.
- [x] 2.2 Run `pnpm build` and confirm it succeeds; search `dist/` JS for a `strong` element created around the count. Covers: number in strong, number updates.
- [x] 2.3 Run `pnpm lint` and confirm it succeeds. Covers: quality gates.
