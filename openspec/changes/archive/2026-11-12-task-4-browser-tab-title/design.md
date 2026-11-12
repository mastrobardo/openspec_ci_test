## Context

`index.html` line 7 has `<title>openspec-ci-poc</title>`. The `main-page-heading` spec currently requires the title to remain `openspec-ci-poc`.

## Goals / Non-Goals

**Goals:** static title reads exactly "OpenSpec CI POC"; build and lint pass; only `index.html` changes outside `openspec/`.

**Non-Goals:** favicon changes; setting the title from React.

## Decisions

- Edit the static `<title>` only; no runtime code, so no tests are needed beyond a source/dist text search.
- Modify the `main-page-heading` requirement rather than leave it contradictory. The title assertion is dropped from that capability and owned by the new `browser-tab-title` capability.

## Risks / Trade-offs

- Forgetting the delta would leave two specs in conflict; mitigated by the MODIFIED delta.
