# Design

## Context

The heading is a hard-coded JSX string in `src/App.tsx` (`<h1>Get started</h1>`, line 19), inside `<section id="center">`. It is the page's only `<h1>`. The other headings are `<h2>` elements. The project has no unit or component test runner. Its quality gates are `pnpm build` (`tsc -b && vite build`) and `pnpm lint` (`eslint .`). See proposal.md (Why) for motivation and `specs/main-page-heading/spec.md` for the requirements.

## Goals / Non-Goals

**Goals:**
- Replace the heading string in place, keeping the diff to one line.

**Non-Goals:**
- Adding a test framework just for this change.
- Extracting the heading into a constant, config, or i18n resource.
- Touching CSS, `index.html`, or any other element.

## Decisions

- **Edit the JSX literal directly.** Change `<h1>Get started</h1>` to `<h1>OpenSpec CI POC</h1>`. Alternatives considered: deriving the text from `package.json` `name` (`openspec-ci-poc`) at build time, as the footer does with the version. Rejected because the casing and spacing differ from the required text, and it adds build plumbing for a static string.
- **Verify by inspecting source and built output, not with a new test.** The repo has no test runner, so the checks are `git diff` (one changed line in `src/App.tsx`), grepping the built bundle for "OpenSpec CI POC" with no "Get started" left, and `pnpm build` and `pnpm lint`. Alternative: add Vitest and Testing Library. Rejected as out of proportion and outside the task's scope.

## Risks / Trade-offs

- [The longer heading wraps differently at narrow widths with the existing `h1` styling] → Accepted. Styling changes are out of scope. A visual check in `pnpm dev` is part of the tasks.
- [An accidental edit to nearby text] → The diff check in the tasks confirms that only the `<h1>` line changed.
