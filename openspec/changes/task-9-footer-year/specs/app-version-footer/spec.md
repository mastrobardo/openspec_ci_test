## ADDED Requirements

### Requirement: Footer shows the current year
The footer SHALL end with " · " followed by the four-digit current year, computed in the browser when the page renders. The rest of the footer text (version and commit SHA) MUST remain unchanged.

#### Scenario: Year appended
- **WHEN** the main page is rendered in the year 2026 with version `0.0.0` and SHA `abc1234`
- **THEN** the footer text is "v0.0.0 (abc1234) · 2026"

#### Scenario: Year computed at render time
- **WHEN** the source of the footer is inspected
- **THEN** the year comes from a runtime call such as `new Date().getFullYear()` and not from a build-time constant

#### Scenario: Existing footer text unchanged
- **WHEN** the main page is rendered
- **THEN** the footer text before the final " · <year>" is exactly "v<version> (<sha>)" as before

#### Scenario: Quality gates pass
- **WHEN** `pnpm build` and `pnpm lint` are run after the change
- **THEN** both complete successfully
