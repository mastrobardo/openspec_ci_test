## ADDED Requirements

### Requirement: Browser tab title names the project
`index.html` SHALL contain a single `<title>` element whose text is exactly "OpenSpec CI POC".

#### Scenario: Title present in source
- **WHEN** `index.html` is inspected
- **THEN** it contains `<title>OpenSpec CI POC</title>` and no other `<title>` element

#### Scenario: Title present in build output
- **WHEN** `pnpm build` completes
- **THEN** `dist/index.html` contains `<title>OpenSpec CI POC</title>`

### Requirement: Title change is isolated
Setting the title MUST NOT change any file other than `index.html` (outside `openspec/`), and MUST NOT change the favicon or set the title dynamically from React.

#### Scenario: Only index.html modified
- **WHEN** the change is applied
- **THEN** `git diff --name-only` outside `openspec/` lists only `index.html`

### Requirement: Build and lint succeed
The project MUST build with `pnpm build` and pass `pnpm lint` after the title change.

#### Scenario: Quality gates pass
- **WHEN** `pnpm build` and `pnpm lint` are run
- **THEN** both complete successfully
