# counter-reset Specification

## Purpose
Lets users return the main page counter to 0 in place, without reloading the page.

## Requirements

### Requirement: Reset button rendered next to the counter
The main page SHALL render a button whose text is exactly "Reset", placed immediately after the "Clicks: N" counter button, and it SHALL use the existing `counter` class.

#### Scenario: Reset button present
- **WHEN** the main page is rendered
- **THEN** a `<button>` with text "Reset" and class `counter` is rendered directly after the counter button

### Requirement: Reset sets the count to zero
Clicking the "Reset" button SHALL set the counter to 0, and the counter button text SHALL then read "Clicks: 0".

#### Scenario: Reset after counting
- **WHEN** the count is 3 and the user clicks "Reset"
- **THEN** the counter button reads "Clicks: 0"

#### Scenario: Reset at zero
- **WHEN** the count is 0 and the user clicks "Reset"
- **THEN** the count remains 0 and the counter button reads "Clicks: 0"

### Requirement: Build and lint succeed
The project MUST still build with `pnpm build` and pass `pnpm lint` after this change, and no stylesheet is modified.

#### Scenario: Quality gates pass
- **WHEN** `pnpm build` and `pnpm lint` are run
- **THEN** both complete successfully

### Requirement: Counter button label reads "Clicks: N"
The counter button on the main page SHALL display the text "Clicks: N", where N is the current count, instead of "Count is N".

#### Scenario: Label on load
- **WHEN** the main page is rendered
- **THEN** the counter button reads "Clicks: 0"

#### Scenario: Label after clicking
- **WHEN** the user clicks the counter button 3 times
- **THEN** the counter button reads "Clicks: 3"

#### Scenario: Old label removed
- **WHEN** the main page is rendered
- **THEN** the text "Count is" appears nowhere in `src/App.tsx` or the built page

### Requirement: Label change is isolated
Renaming the counter button MUST NOT change any other visible text, the Reset button, or any stylesheet.

#### Scenario: Other text and styling untouched
- **WHEN** the label change is applied
- **THEN** only the counter button's text differs from before, the Reset button is unchanged, and no stylesheet is modified

#### Scenario: Quality gates pass
- **WHEN** `pnpm build` and `pnpm lint` are run
- **THEN** both complete successfully
