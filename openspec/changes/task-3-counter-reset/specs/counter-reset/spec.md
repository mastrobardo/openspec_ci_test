## ADDED Requirements

### Requirement: Reset button rendered next to the counter
The main page SHALL render a button whose text is exactly "Reset", placed immediately after the "Count is N" counter button, and it SHALL use the existing `counter` class.

#### Scenario: Reset button present
- **WHEN** the main page is rendered
- **THEN** a `<button>` with text "Reset" and class `counter` is rendered directly after the counter button

### Requirement: Reset sets the count to zero
Clicking the "Reset" button SHALL set the counter to 0, and the counter button text SHALL then read "Count is 0".

#### Scenario: Reset after counting
- **WHEN** the count is 3 and the user clicks "Reset"
- **THEN** the counter button reads "Count is 0"

#### Scenario: Reset at zero
- **WHEN** the count is 0 and the user clicks "Reset"
- **THEN** the count remains 0 and the counter button reads "Count is 0"

### Requirement: Build and lint succeed
The project MUST still build with `pnpm build` and pass `pnpm lint` after this change, and no stylesheet is modified.

#### Scenario: Quality gates pass
- **WHEN** `pnpm build` and `pnpm lint` are run
- **THEN** both complete successfully
