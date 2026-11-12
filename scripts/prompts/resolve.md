You are running unattended in CI. Run each shell command as its own Bash call, without chaining
(`&&`, `;`, `|`) or wrapper commands, otherwise it is denied. Nobody can answer questions: when
something is unclear, make the most conservative assumption and record it.

This branch implements the OpenSpec change `{{CHANGE_ID}}` (from `tasks/{{TASK_ID}}.txt`). While it was
in review, other changes were merged into `main`. CI has started `git merge origin/main` on this
branch, and it stopped with conflicts. The conflicted files are listed in `{{CONFLICTS_FILE}}`, one per line.

Source of truth:
- `main` is already merged and reviewed. Its code, its main specs in `openspec/specs/` and its
  archived changes in `openspec/changes/archive/` are law. Never drop or weaken what they require.
- This change (`openspec/changes/{{CHANGE_ID}}/`) must still deliver what it promises, on top of `main`.

1. Read `{{CONFLICTS_FILE}}`, this change's proposal.md, design.md, specs and tasks.md, and the main specs
   of every capability the conflicted code touches. `git log --oneline -15 origin/main` and
   `git diff HEAD...origin/main -- <path>` show what `main` changed.
2. Resolve every conflicted file: edit it so that it contains no conflict markers and keeps the
   behaviour of BOTH sides. Combine them; do not pick one side wholesale unless the other side's
   change is already contained in it.
3. Edit only the conflicted files and, if needed, files under `openspec/changes/{{CHANGE_ID}}/`. Do not
   touch any other file, `openspec/specs/`, other changes, CI files or scripts.
4. If this change's delta specs or tasks contradict the main specs as they are now on `main` (for
   example a scenario that quotes text `main` has changed), update this change's delta specs and
   tasks.md so that they describe the combined behaviour, and list each such edit in the report.
   A MODIFIED requirement must use the requirement header exactly as it is now in `openspec/specs/`.
   If both sides cannot be satisfied together, stop, leave the file as close to `main` as possible,
   and explain under `## Deviations`.
5. Run `openspec validate {{CHANGE_ID}} --strict`, `pnpm build` and `pnpm lint`. All must pass.

Your final message is a resolve report in Markdown with sections `## Summary`, `## Conflicts`
(a table with columns `File | Ours (this change) | Theirs (main) | Resolution`, one row per
conflicted file), `## Spec impact` (edits to this change's artifacts and why; write "None" if there
are none), `## Checks` (validate, build and lint results), and `## Deviations` (write "None" if there
are none).
