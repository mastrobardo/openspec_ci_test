## 1. Implementation
- [ ] 1.1 In `src/App.tsx`, change the counter button text from `Count is {count}` to `Clicks: {count}` (covers: label "Clicks: N", "Clicks: 0" on load).
- [ ] 1.2 Verify by search that `src/App.tsx` has no remaining "Count is" and that the Reset button still uses `onClick={() => setCount(0)}` and is unchanged (covers: Reset yields "Clicks: 0").
- [ ] 1.3 Verify with `git diff --stat` that only `src/App.tsx` (plus `openspec/`) changed, with a one-line text diff, and no stylesheet changed (covers: no other text changes).

## 2. Validation
- [ ] 2.1 Run `pnpm build` and confirm it succeeds; search `dist/` JS for `Clicks: ` and confirm "Count is" is absent.
- [ ] 2.2 Run `pnpm lint` and confirm it succeeds.
