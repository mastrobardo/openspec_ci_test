# OpenSpec in CI

A proof of concept: an [OpenSpec](https://github.com/Fission-AI/OpenSpec) change lifecycle driven end
to end by Claude Code running in GitHub Actions, authenticated with a Claude subscription. Humans
gate every stage with ordinary PR actions (Ready for review, Request changes, Approve, a deployment
approval). The agent does the judgment work. Deterministic scripts check structure, so nothing an agent
gets wrong is pushed.

The app is a minimal Vite + React + TypeScript page. It only exists to give the agents something to change.
Two changes went through the full lifecycle on GitHub (PR #1 and PR #2). The run logs, costs and problems
are in [`memory/repo/poc-results.md`](memory/repo/poc-results.md).

## Lifecycle

```
 tasks/task-N.txt
        │
        │  Actions → "OpenSpec Plan" (task, model)
        ▼
 ┌──────────────┐  agent: explore + /opsx:propose (writes openspec/ only)
 │    Plan      │  checks: guard-plan-diff, openspec validate --strict
 └──────┬───────┘  → branch openspec/task-N + draft PR, manifest
        │  human: review the proposal, click "Ready for review"
        ▼
 ┌──────────────┐  agent: /opsx:apply (works through tasks.md)
 │    Apply     │  checks: guard-diff, all tasks ticked, validate, pnpm build + lint
 └──────┬───────┘  → commit + push to the PR branch, report comment
        │
        │  human: "Request changes"  or a comment "/reapply <text>"
        │      ┌──────────────┐  agent classifies feedback: requirement → /opsx:update,
        ├────► │   Re-apply   │  implementation → new tasks; then /opsx:apply
        │      └──────┬───────┘  checks: as Apply + scope-documented (D12)
        │ ◄───────────┘          → push, report with a Spec impact table
        │
        │  human: "Approve"
        ▼
 ┌──────────────┐  agent: /opsx:verify (read-only), build + lint
 │    Verify    │  checks: stale approval, validate, tasks, guard (no file changed)
 └──────┬───────┘  → verdict comment PASS / FAIL / INCONCLUSIVE
        │  only on PASS; human: approve the "openspec-archive" deployment
        ▼
 ┌──────────────┐  no agent: openspec archive -y, validate --all --strict
 │   Archive    │  → archive commit on the PR branch, comment "Ready to squash merge"
 └──────┬───────┘
        │  human: squash merge
        ▼
 main: code + openspec/specs/<capability>/ + openspec/changes/archive/<date>-<change>/
        │
        │  push to main (or a "/sync" comment)
        ▼
 ┌──────────────┐  every other open OpenSpec PR that is behind main: git merge main
 │    Sync      │  clean → no agent; conflict → agent "resolve" (both sides kept)
 └──────────────┘  checks: guard-resolve, validate, spec preflight, build + lint
                   → merge commit pushed, comment; the reviewer re-approves (→ Verify)
```

## Repository layout

| Path | What it is |
|---|---|
| `tasks/task-N.txt` | The input: a small task with acceptance criteria and an out-of-scope list (stand-in for a ticket). |
| `.github/workflows/openspec-{plan,apply,verify}.yml` | Orchestration only: checkouts, permissions, calls into `scripts/`. Started by dispatch (and `/reapply` comments), so they always run from `main`. |
| `.github/workflows/openspec-sync.yml` | Sync: after every push to `main` (or `/sync`), merges `main` into each open OpenSpec PR that is behind it; conflicts go to the `resolve` agent. |
| `.github/workflows/openspec-events.yml` | Trampoline: turns Ready for review, Request changes and Approve into dispatches of Apply/Verify on `main`. |
| `scripts/run-agent.sh` | Runs one stage with `claude -p`: per-stage tool allowlist, model, output files, exit codes. |
| `scripts/prompts/{plan,apply,reapply,verify,resolve}.md` | The stage prompts. |
| `scripts/openspec-ops.sh` | Deterministic checks: `change-id`, `validate`, `tasks-complete`, `guard-plan-diff`, `guard-diff`, `scope-documented`, `manifest`. |
| `scripts/pr-feedback.sh` | Collects review feedback for re-apply (write-access users only, newer than the last apply). |
| `scripts/run-summary.sh` | The run summary: job summary, `summary.md` in the artifact, the failure comment. |
| `.openspec-ci/manifests/<task>.json` | Per-task audit trail: change, stage, model, run ids, SHAs, `applied_at`, sync results. One file per task, so parallel PRs never conflict on it. |
| `.openspec-ci/runs/` | Per-run agent output (gitignored; uploaded as the run artifact). |
| `openspec/`, `.claude/` | OpenSpec project, `/opsx:*` commands and skills (from `openspec init --tools claude`). |
| `docs/PLAN.md`, `docs/PROGRESS.md` | Decisions D1–D14 and the step-by-step progress map. |
| `memory/` | Repo memory: results, CI gotchas, environment, session logs. |

## Setup (once per repository)

1. **Claude token.** Run `claude setup-token` locally, then store the token **as one line**. Terminal
   wrapping breaks it otherwise:
   ```sh
   pbpaste | tr -d ' \r\n' | gh secret set CLAUDE_CODE_OAUTH_TOKEN -R <owner>/<repo>
   ```
2. **Actions settings** (Settings → Actions → General): Actions enabled, and tick
   **Allow GitHub Actions to create and approve pull requests**. The default workflow permission can stay
   **read**, because every workflow declares its own `permissions:`.
3. **Archive gate**: Settings → Environments → create `openspec-archive` with yourself as a
   **required reviewer**. Leave "prevent self-review" off if you are the only reviewer. Add no
   branch policy, because review events run on `refs/pull/N/merge`.
4. **Squash-only merges** (Settings → General → Pull Requests): allow only squash merging, with the
   commit message "Pull request title and description". The per-stage bot commits disappear, and
   the PR body describes the change.
5. **Up to date before merging** (Settings → Branches → `main`): branch protection with
   "Require branches to be up to date before merging" and no required checks. GitHub then holds the
   merge button until Sync has merged the latest `main` into the PR, so no PR reaches `main` unsynced (031).
   Admins can still bypass it; don't.

Steps 3–5 can also be done through the API (`gh api -X PUT repos/<owner>/<repo>/environments/openspec-archive …`,
`gh api -X PATCH repos/<owner>/<repo> -F allow_merge_commit=false -F allow_rebase_merge=false …`,
`gh api -X PUT repos/<owner>/<repo>/branches/main/protection` with
`{"required_status_checks":{"strict":true,"contexts":[]},"enforce_admins":false,"required_pull_request_reviews":null,"restrictions":null}`).

## Running a change

| Stage | Trigger (the human gate) | Fallback | Result |
|---|---|---|---|
| Plan | Actions → **OpenSpec Plan** → `task` (e.g. `task-2`), `model` | – | Draft PR `OpenSpec: <change>` on `openspec/task-N` |
| Apply | **Ready for review** on the draft PR | `gh workflow run "OpenSpec Apply" -f pr=N` | Implementation pushed + report comment |
| Re-apply | **Request changes** review, or a comment starting with `/reapply` | `gh workflow run "OpenSpec Apply" -f pr=N` (re-applies if there is new feedback) | Fixes pushed + report with **Spec impact** |
| Verify | **Approve** | `gh workflow run "OpenSpec Verify" -f pr=N` | Verdict comment; the job fails unless PASS |
| Archive | Approve the **openspec-archive** deployment in the Verify run (**Review deployments**) | `gh workflow run "OpenSpec Verify" -f pr=N` (verifies again, then waits at the gate) | Archive commit; "Ready to squash merge" |
| Merge | **Squash and merge** | – | Code, main specs and the archived change land together |
| Sync | Any push to `main`, or a comment starting with `/sync` | `gh workflow run "OpenSpec Sync" [-f pr=N]` | Other open PRs merged with `main`; conflicts resolved by the agent; comment asking to re-approve |

Notes:

- **Run names.** Every run is titled with its stage and task, e.g. `Apply · OpenSpec: task-5-counter-button-label`,
  `Verify · …`, `Plan · task-5 (sonnet)`, `sync PR #7 · …`. A review on a **draft** PR does nothing except post a
  comment asking you to mark it Ready for review first.
- **How PR actions start a stage.** `openspec-events.yml` receives the PR event and runs
  `gh workflow run` for Apply or Verify on `main`, passing `pr`, the `mode`, or the approved sha. The real
  workflows therefore always run the current version from `main`. A PR event alone would run them from
  the PR's merge ref, which GitHub rebuilds lazily (D15). Each dispatched run appears under its own
  workflow in the Actions tab.

- **Model.** Pick it once, in the Plan dropdown (`sonnet`, `opus` or `fable`: the latest model of that
  family). It is saved as `model` in the manifest, and every later stage uses it (D9).
- **`/reapply [text]`.** The comment must **start** with `/reapply`. A leading space or newline
  skips it, because GitHub expressions have no trim. Only owners, members and collaborators can use it.
  The text after the command is the feedback. A bare `/reapply` only triggers the run, using the feedback
  posted since the last apply (the run fails if there is none). The run reacts with 👀. Comments run from `main`, so `/reapply` always uses the current workflow.
- **Which feedback counts.** Re-apply reads review bodies, inline comments and PR comments newer
  than the last apply (`applied_at`), from write-access users only, never from bots. The prompt
  treats the text as data, never as instructions (D10).
- **Scope changes (D11, D12).** The re-apply agent classifies each item:
  - A **requirement** item changes the plan through `/opsx:update` and must be recorded in `proposal.md` under
    `## Scope changes from review` (`- F<n> (@reviewer, link): …`). CI checks this before pushing.
  - An **implementation** item becomes a new task.

  Verify reports a documented scope change as a NOTE, and an undocumented difference from the task as a FAIL.
- **Verify never pushes.** It checks out the exact approved commit and fails if the approval is
  stale (for an older head). Re-approve after any new push.
- **Archive (D13).** Archive is a second job in the Verify run. It runs only after PASS and waits for the environment
  approval. Its concurrency group is separate, so a waiting gate never blocks Apply on the same PR.
- **Sync and resolve (D16).** After a merge, every other open OpenSpec PR is merged with `main`.
  A clean merge is checked and pushed without an agent. On a conflict, the `resolve` agent combines
  both sides: `main` is law, and this change is adapted on top of it, including its own delta specs if they
  quote text that `main` changed. `guard-resolve` allows edits only to conflicted files and the
  change's own folder. A **spec preflight** (archive into a scratch copy, then `validate --all`) proves
  the change still applies to `main`'s specs. The push makes any approval stale, so re-approve to run
  Verify. Conflicts on an already archived PR are left to a human. A PR merged or closed while Sync
  is running is skipped quietly (031).
- **New capabilities need a Purpose.** A delta spec for a new capability starts with `## Purpose`
  (at least 50 characters). Otherwise the archived main spec fails `validate --strict`. This is checked at Plan,
  Apply and Verify.
- **Tasks must be doable unattended.** Plan only writes tasks the CI agent can finish and check
  (edit, build, lint, search the source or `dist/`). Visual checks become notes for the reviewer.

## When a run fails

Every run writes a summary to the job page and to `summary.md` in the run artifact (`openspec-<stage>-…`).
For a failed run, it adds **Why it failed**:

- the failed step and the reason recorded by the check (e.g. the unticked task line),
- the agent's own explanation (`## Deviations` for Apply/Re-apply, `## Issues` for Verify) or its error message,
- every command the CI sandbox refused (permission denials),
- the last lines of `pnpm build` / `pnpm lint` output, if those failed.

A failed Apply, Re-apply or Sync also posts this as a **PR comment**, saying whether anything was pushed and how to retry.
So does a Verify that stops before a verdict (draft, stale approval, failed checks; 031); a verdict
(PASS, FAIL, INCONCLUSIVE) is always posted as its own comment.
The full agent output is `<stage>.json` / `<stage>.md` in the artifact
(`gh run download <run-id> -R <owner>/<repo> -D <new-dir>`; use a fresh directory per attempt).

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| A PR action (Ready, Approve, Request changes) starts **no run** | The PR was opened before `openspec-events.yml` existed (PR events run from the PR's merge ref) | Use the dispatch fallback above |
| Agent run: 1 turn, $0, `is_error` | Token has a line break | Re-set the secret with `tr -d ' \r\n'` (setup step 1) |
| `/reapply` did nothing | The comment did not start with `/reapply` | Post it again with `/reapply` at the very start |
| Verify fails "approval is stale" | New commits after the approval | Re-approve |
| Apply fails at `tasks-complete` | The agent could not finish a task (see Why it failed) | `/reapply <what to change>`, e.g. reword a task CI cannot run |
| Merge button says the branch is **out of date** | `main` moved; Sync has not pushed yet | Wait for the Sync run (don't use "Update branch": it bypasses Sync's checks) |
| PR shows merge conflicts | `main` moved after the PR was opened | Wait for the Sync run (it starts on every push to `main`), or comment `/sync` |
| Runs stuck `queued` or `startup_failure` everywhere | GitHub incident | Check githubstatus.com; re-run a known-good commit before blaming the code |

More, with the evidence behind each: [`memory/repo/ci-gotchas.md`](memory/repo/ci-gotchas.md).

## Running and testing locally

```sh
pnpm install
pnpm build && pnpm lint                     # what every stage checks
scripts/run-agent.sh plan task-3            # a real agent run with your local Claude login
scripts/openspec-ops.sh validate <change>   # any deterministic check; exit 0 ok, 1 setup, 2 failed
```

- `run-agent.sh` passes `--setting-sources project`, so your user-level settings and hooks do not leak into the
  agent run. Your global `CLAUDE.md` still loads locally. CI has none.
- To test the scripts without using quota, put a stub `claude` first on `PATH` that prints a result JSON.
  `PR_FEEDBACK_INPUT=<json>` makes `pr-feedback.sh` read a file instead of the API.
- Lint the workflows:
  `docker run --rm -v "$PWD":/repo:ro -w /repo rhysd/actionlint:1.7.7 -oneline`.

## Further reading

- [`docs/PLAN.md`](docs/PLAN.md): goal, lifecycle and decisions D1–D14.
- [`docs/PROGRESS.md`](docs/PROGRESS.md): what is done, what is next.
- [`memory/repo/poc-results.md`](memory/repo/poc-results.md): run logs, costs, problems found, guardrails, lessons.
