## MODIFIED Requirements

### Requirement: Footer shows the package version
The footer SHALL display the text "Version " followed by the `version` field of `package.json`, without a "v" prefix. The footer text SHALL read "Version <version> · <short sha>", with a middle dot (U+00B7) surrounded by single spaces between the version and the SHA.

#### Scenario: Current version displayed
- **WHEN** `package.json` has version `0.0.0` and the main page is rendered
- **THEN** the footer text starts with "Version 0.0.0 · "
- **AND** the footer text does not contain "v0.0.0" or parentheses

#### Scenario: No other page text changes
- **WHEN** the main page is rendered after this change
- **THEN** all visible text outside the footer is identical to before the change

### Requirement: Footer shows the commit SHA
The footer SHALL also display the short git commit SHA of the build, resolved at build time, after the middle dot separator, or "unknown" when it cannot be determined.

#### Scenario: SHA displayed
- **WHEN** the app is built from a git checkout and the main page is rendered
- **THEN** the footer text includes the short commit SHA of HEAD, e.g. "Version 0.0.0 · abc1234"

#### Scenario: SHA unavailable
- **WHEN** the app is built where git information is unavailable
- **THEN** the footer shows "unknown" as the SHA, e.g. "Version 0.0.0 · unknown", and the build still succeeds

### Requirement: Version is resolved at build time
The displayed version and SHA MUST be read from `package.json` and git at build time, so that changing the version and rebuilding changes the footer text with no other code change.

#### Scenario: Version bump and rebuild
- **WHEN** the `version` in `package.json` is changed to `1.2.3` and the app is rebuilt
- **THEN** the footer shows "Version 1.2.3" without any other source change

### Requirement: Build and lint succeed
The project MUST still build with `pnpm build` and pass `pnpm lint` after the footer format is changed.

#### Scenario: Quality gates pass
- **WHEN** `pnpm build` and `pnpm lint` are run
- **THEN** both complete successfully
