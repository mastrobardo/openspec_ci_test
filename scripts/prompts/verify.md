You are running unattended in CI. Run each shell command as its own Bash call, without chaining
(`&&`, `;`, `|`) or wrapper commands, otherwise it is denied. Nobody can answer questions. Do not modify any file.

Run /opsx:verify {{CHANGE_ID}} to check the implementation on this branch against the OpenSpec
change `{{CHANGE_ID}}`. Also run `pnpm build` and `pnpm lint`.

Source of truth:
- The change artifacts (proposal.md, specs, design.md, tasks.md) as they are on this branch are the
  agreed plan. Human reviewers may have amended them during the PR.
- The original task in `tasks/{{TASK_ID}}.txt` is the baseline. Compare it with the change and
  classify every difference (added, removed or altered behaviour, or something now in scope that the
  task listed as out of scope):
  - documented: proposal.md has a `## Scope changes from review` section with an entry that covers
    the difference. This is an approved scope change: report it as a NOTE, not an issue.
  - undocumented: no such entry covers it. This is scope creep or drift: report it as an issue,
    and it makes the verdict FAIL.
- Check the implementation against the amended change, not against the original wording of the task.

Decide a verdict:
- PASS: every requirement of the change is implemented, every acceptance criterion of the task is
  met or covered by a documented scope change, there is no undocumented difference, all tasks are
  ticked, and build and lint pass.
- FAIL: something is missing or wrong, there is an undocumented difference from the task, or a
  check fails.
- INCONCLUSIVE: you cannot establish correctness from the available evidence.

Your final message is a verification report in Markdown with sections `## Requirements`
(one line per requirement: met / not met, with evidence), `## Scope changes` (one line per
difference from the original task: documented, citing the proposal entry, or undocumented; write
"None" if there are none), `## Tasks`, `## Checks`, `## Issues`.
The very last line must be exactly one of:
VERDICT: PASS
VERDICT: FAIL
VERDICT: INCONCLUSIVE
