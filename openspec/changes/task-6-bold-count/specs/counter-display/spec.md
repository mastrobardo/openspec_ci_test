## Purpose
Makes the number on the main page counter button stand out so users can read the count at a glance.

## ADDED Requirements

### Requirement: Count number is wrapped in strong
The main page counter button SHALL render its number inside a `<strong>` element, so the markup reads "Clicks: <strong>N</strong>".

#### Scenario: Number in strong element
- **WHEN** the main page is rendered with the count at 3
- **THEN** the counter button contains a `<strong>` element whose text content is exactly "3"

#### Scenario: Number updates inside strong
- **WHEN** the user clicks the counter button
- **THEN** the `<strong>` element inside it shows the new count

### Requirement: Rest of the button is unchanged
Only the number SHALL be inside the `<strong>` element. The button's overall text content MUST remain "Clicks: N", the word "Clicks:" MUST NOT be inside `<strong>`, no CSS rule is added, and the Reset button MUST NOT change.

#### Scenario: Text preserved
- **WHEN** the main page is rendered with the count at 3
- **THEN** the counter button's text content is "Clicks: 3" and "Clicks:" is outside any `<strong>` element

#### Scenario: Reset button and styles untouched
- **WHEN** the change is applied
- **THEN** the Reset button markup is unchanged and no stylesheet is modified

### Requirement: Build and lint succeed
The project MUST still build with `pnpm build` and pass `pnpm lint` after this change.

#### Scenario: Quality gates pass
- **WHEN** `pnpm build` and `pnpm lint` are run
- **THEN** both complete successfully
