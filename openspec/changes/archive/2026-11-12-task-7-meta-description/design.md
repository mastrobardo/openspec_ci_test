## Context

`index.html` is a static Vite entry file. Its head has charset, icon, viewport, and title.

## Goals / Non-Goals

**Goals:** add one static meta description to `index.html`.
**Non-Goals:** Open Graph or social tags; any change to `src/`; dynamic setting from React.

## Decisions

- Insert the tag directly after the `<title>` line, so existing lines stay untouched. Vite copies it unchanged into `dist/index.html`.
- Use the exact content string from the task, with the same self-closing style as the other tags.
