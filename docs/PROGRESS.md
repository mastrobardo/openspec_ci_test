# Progress map

Resume rule: read `docs/PLAN.md`, this file, and `memory/repo/*.md`, then continue from the first
unchecked step. **Every step needs explicit user approval before it is committed.**

| # | Step | Status | Commit |
|---|------|--------|--------|
| 1 | `openspec init --tools claude` (openspec/, .claude/commands/opsx, .claude/skills/openspec-*) | done | 80603ac |
| 2 | Plan, progress map, repo memory, session log | done | 953d591 (user) |
| 3 | `tasks/task-1.txt` sample task | done | 002 (4316fed) |
| 3b | `tasks/task-{2,3,4}.txt` (heading text, counter reset, tab title) | done | 003 (8ed97f3) |
| 4 | `scripts/run-agent.sh` + `scripts/prompts/{plan,apply,verify}.md` (plan stage verified locally) | done | 004 |
| 5 | `scripts/openspec-ops.sh` (change-id, validate, tasks-complete, guard-plan-diff, manifest); `.openspec-ci/runs/` gitignored | done | 006 |
| 6 | `.github/workflows/openspec-plan.yml` | done | 007 |
| 6b | Plan workflow: `model` dropdown (sonnet/opus/fable), token whitespace check, model + attempt in manifest | done | 008 |
| 7a | `openspec-apply.yml` first apply (`ready_for_review` + dispatch `pr`), `guard-diff`, manifest `model` alias | done (static + local tests); **not yet run on GitHub** (see Next action) | 009 |
| 7b | Re-apply with review feedback (`changes_requested`), `pr-feedback.sh`, `reapply` prompt/stage | done (static + simulated); **not yet run on GitHub** | 010 |
| 8 | `openspec-verify.yml` (Approve + dispatch; read-only, no commit; verdict comment; stale-approval check), `guard-diff verify`, per-PR concurrency `openspec-pr-N` shared with Apply | done; ran on GitHub (dispatch; the approval event saw a stale merge ref) → FAIL for scope (→ D12) | 013 |
| 8a | Scope rule D12: re-apply writes `## Scope changes from review`; Verify: documented = NOTE, undocumented = FAIL | done; on GitHub, Verify correctly failed an inline (non-section) note → 015 | 014 |
| 8c | D12 enforced: `openspec-ops.sh scope-documented` after re-apply (proposal/specs changed → section with `- F<n>` required); literal format in the reapply prompt | done (7 local cases); not yet exercised on GitHub (run 43108778620 used the 014 workflow); PR #1 reached Verify PASS (43108985466) | 015 |
| 8b | `/reapply [text]` PR comment command (`issue_comment`, owner/member/collaborator only, 👀 ack, bare command dropped from feedback) | done (local tests); **not yet run on GitHub** | 016 |
| 8d | Settings via API: environment `openspec-archive` (required reviewer), squash-only merges | done | (API, 2026-11-11) |
| 8e | Gated archive: second Verify job (D13) | todo | 017 |
| 9 | README: setup + run instructions | todo | |
| 10 | User: push, add secret, change repo settings | done: pushed, secret set, Actions enabled, create/approve PRs allowed, default perms read (checked 2026-11-11) | |
| 11 | E2E run: Plan → draft PR → Ready → Apply → Approve → Verify | plan passed in CI on the old repo (run 43091589972 → PR #1); GitHub outage 20:20–21:05Z; apply/verify todo | |
| 11b | Fallback repo `arcibardo/openspec_ci` (Plan passed there → its PR #1); back on the old repo after the outage | done | 011 |
| 11c | Apply runs trusted scripts from the workflow commit (`$CI_SCRIPTS`), prompts next to the script | done; Apply + 2 re-applies passed on GitHub (PR #1, spec impact shown for the SHA requirement) | 012 |

## Next action

State: PR #1 (`mastrobardo/openspec_ci_test`) is approved with Verify PASS (43108985466), not archived,
not merged. The full record for the presentation is in `memory/repo/poc-results.md`: **update it in
every commit.**

1. **Test 016 (the user does this):** comment on PR #1 `/reapply the version text should be "v0.0.0"`.
   Expect a 👀 reaction, an Apply run (event `issue_comment`, from main), a requirement →
   `/opsx:update`, the new "Check scope changes are documented" step passing (this also exercises
   015), and a push. Then re-approve → Verify.
2. **Step 8e, commit `017`: gated archive (D13)** (show the plan/diff first):
   - In `openspec-verify.yml`, move concurrency to job level: `verify` → `openspec-pr-N`,
     `archive` → `openspec-archive-N`, so a waiting archive never blocks Apply.
   - Job `archive`: `needs: verify`, `if: needs.verify.outputs.verdict == 'PASS'`,
     `environment: openspec-archive`, `contents: write` + `pull-requests: write`, no Claude secret.
     Steps: resolve the PR and refuse if the head ≠ the verified sha; trusted scripts; checkout head;
     `openspec archive -y <change>`; `openspec validate --all --strict` (or `--specs`); guard
     (`guard-plan-diff`: only `openspec/` + manifest); manifest `stage=archived`; commit/push; comment
     "archived, ready to squash merge".
   - Expose `verdict` and `sha` as `verify` job outputs.
   - Test: run `openspec archive -y` locally on a worktree of PR #1 (no push) to see the exact file
     moves and main spec creation; actionlint.
3. **Step 9: README** (setup, lifecycle incl. archive + squash, triggers + fallbacks, model dropdown,
   D12, troubleshooting) and presentation material from `poc-results.md`.

Leftovers on the old repo: branch `probe/007` (safe to delete) and uncancellable `startup_failure`
runs from the outage.

## Facts for the next session

- Agreed decisions D9–D11 are in `docs/PLAN.md` (single model choice; re-apply trigger; spec changes
  through `/opsx:update` + Spec impact table).
- Manifest keys: `task change stage status model plan_model plan_run_id plan_run_attempt base_sha
  apply_run_id apply_run_attempt applied_at apply_count created_at updated_at`.
  `stage` is `plan`, `apply` or `reapply`; `applied_at` = start of the last (re)apply run and the
  cutoff for the next feedback collection.
  `model` = the alias picked at Plan, read by every later stage.
- `openspec-ops.sh` contract: exit 0 ok, 1 usage/setup error, 2 check failed.
  `guard-diff <apply|reapply> <change> <base-sha>` compares the working tree and untracked files
  against base-sha.
- Actions: checkout/setup-node/upload-artifact `@v7`, pnpm/action-setup `@v6` (pnpm 10); openspec
  `1.14.1`, claude-code `2.1.322`. Workflows are validated with PyYAML, `bash -n` on each `run:`,
  no `${{ }}` inside `run:`, and step-order checks for `steps.X` refs. actionlint and shellcheck
  are not installed.
- `scripts/pr-feedback.sh <pr> <since|-> <out>` prints the item count. `PR_FEEDBACK_INPUT=<json>`
  is a test hook that skips the API. The workflow writes feedback to `.openspec-ci/runs/feedback.md`
  (gitignored) and the guard's spec impact to `.openspec-ci/runs/spec-impact.txt`.
- PR #1 was authored by `github-actions`, so the owner can Approve or Request changes on it.
- Conventions: commits are numbered `NNN:` (`memory/repo/conventions.md`); every step waits for
  user approval before commit; re-confirm whenever the plan changes.

## Open questions

- Should Verify also run on `pull_request: synchronize` so it can be a required check? (step 8)
- Should archival be added after a passing verify? (out of scope for now)
