# Tasks

## 1. Build-time version injection

- [ ] 1.1 In `vite.config.ts`, read `version` from `package.json` and expose it via `define` as `__APP_VERSION__`; verify `pnpm build` succeeds (spec: version resolved at build time).
- [ ] 1.2 Declare `__APP_VERSION__: string` in a `src/*.d.ts` file; verify `tsc -b` (via `pnpm build`) reports no type errors.

## 2. Footer

- [ ] 2.1 Append `<footer>Version {__APP_VERSION__}</footer>` as the last element of `App` in `src/App.tsx`; verify with `pnpm dev`/`pnpm preview` that a footer shows "Version 0.0.0" at the bottom of the page (specs: footer rendered, shows package version).
- [ ] 2.2 Add minimal readable styling for the footer in `src/App.css`; verify the text is legible in the rendered page.

## 3. Verification

- [ ] 3.1 Temporarily set `package.json` version to `1.2.3`, run `pnpm build`, confirm "Version 1.2.3" appears in the built output (e.g. grep `dist/assets`), then revert to `0.0.0` (spec: version bump and rebuild).
- [ ] 3.2 Run `pnpm build` and `pnpm lint`; verify both exit 0 (spec: build and lint succeed).
