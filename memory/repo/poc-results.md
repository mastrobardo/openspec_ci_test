---
name: poc-results
description: Running record of the OpenSpec-in-CI POC for the final presentation (lifecycle, runs, metrics, decisions, problems, lessons)
---

Purpose: source material for the POC presentation (PPT). Keep it factual and update it in the same
commit as the work. Repo: `mastrobardo/openspec_ci_test` (fallback: `arcibardo/openspec_ci`).
Related: [[environment]] [[ci-gotchas]] [[conventions]]; decisions in `docs/PLAN.md`.

## 1. What the POC proves
An OpenSpec change can be driven end to end by Claude Code (`claude -p`, subscription token) in
GitHub Actions, with humans gating every stage through normal PR actions. Proven on PR #1
(`tasks/task-1.txt`: version footer), 2026-11-11: Plan → Apply → 5 re-applies driven by review
feedback (including a reviewer-driven scope change and a `/reapply` comment) → Verify PASS → gated
archive (human approval) → squash merge `2362212` at 23:01Z. **Complete lifecycle proven.**

## 2. Lifecycle (as built)
| Stage | Trigger (human gate) | Agent? | Deterministic checks | Output |
|---|---|---|---|---|
| Plan | Actions tab: task + model dropdown | yes (`/opsx:propose`) | guard-plan-diff (only `openspec/`), change-id, validate --strict | branch `openspec/task-N`, draft PR, manifest |
| Apply | "Ready for review" (or dispatch `pr`) | yes (`/opsx:apply`) | guard-diff apply (code + tasks.md only), tasks-complete, validate, build, lint | commit on PR, report comment |
| Re-apply | "Request changes", `/reapply [text]` comment (016), or dispatch | yes (classify → `/opsx:update` → `/opsx:apply`) | pr-feedback (owner/member/collab, since last apply), guard-diff reapply (+ spec impact), scope-documented (015), checks | commit, comment with ⚠️ Spec impact box |
| Verify | "Approve" (or dispatch) | yes (`/opsx:verify`, read-only) | stale-approval check, change-id, validate, tasks-complete, guard-diff verify (no changes) | ✅/❌/⚠️ verdict comment, job fails unless PASS; never commits |
| Archive (018) | Second job of the Verify run: after PASS, waits for the `openspec-archive` environment reviewer ("Review deployments → Approve and deploy") | no (`openspec archive -y`, no Claude secret) | verified sha == PR head, validate before, `validate --all --strict` after, guard (only `openspec/`) | archive commit on the PR branch (change → `openspec/changes/archive/<date>-<change>/`, delta → `openspec/specs/<cap>/spec.md`), 📦 comment, then squash merge |
| Sync (026) | Any push to `main`, `/sync` comment, or dispatch | only on conflict (`resolve`) | merge `main`; guard-resolve (conflicted files + own change only, no markers), validate, Purpose, tasks, spec preflight, build, lint | merge commit on the PR branch + comment (approval now stale → re-approve → Verify) |

Layers (D6): workflows orchestrate only; `scripts/run-agent.sh` (agent adapter, per-stage tool
allowlist), `scripts/prompts/*.md` (stage prompts), `scripts/openspec-ops.sh` (deterministic checks),
`scripts/pr-feedback.sh` (review feedback), `scripts/prompts/resolve.md` + `openspec-ops.sh guard-resolve`/`spec-preflight` (sync, 026), `scripts/run-summary.sh` (run summary: on failure the failed step, the recorded reason, the agent's own explanation, permission denials, build/lint tail; 021). Audit trail: `.openspec-ci/manifest.json` on the PR branch,
plus a per-run artifact (`<stage>.json` with turns, cost, model, denials).

## 3. Run log, PR #1 (UTC, 2026-11-11)
| Time | Run | Stage / event | Result | Agent stats |
|---|---|---|---|---|
| 19:54 | 43091589972 #1 | Plan dispatch | fail: token had a line break | 1 turn, $0 |
| 19:57 | 43091589972 #2 | Plan dispatch | ✅ draft PR #1 | 21 turns, $0.20 |
| 20:19 | – | "Ready for review" | no run: stale merge ref (Apply did not exist when the PR opened) | – |
| 20:23–20:46 | 5 runs | Apply/Plan dispatch | `startup_failure`: GitHub Actions outage (critical incident from 20:48) | none (no jobs) |
| 20:54 | 43098756576 (fallback repo) | Plan dispatch | ✅ (queued ~5 min during the outage) | 18 turns, $0.13 |
| 21:10 | 43100829053 | Apply dispatch | fail: PR branch carried old scripts → fix 012 | – |
| 21:15 | 43101481397 | Apply dispatch | ✅ footer implemented | 28 turns, $0.19 |
| 21:21 | 43102302078 | Re-apply (Request changes) | ✅ inline nit → task 4.1 (CSS variable) | 12 turns, $0.09 |
| 21:24 | 43102810824 | Re-apply (Request changes) | ✅ "show commit SHA" → requirement → `/opsx:update`, Spec impact | 32 turns, $0.19 |
| 21:49 | – | Approve | no Verify: stale merge ref | – |
| 21:51 | 43106699322 | Verify dispatch | ❌ FAIL: SHA contradicts the task's out-of-scope → D12 (014) | 11 turns, $0.11 |
| 21:56 | 43107494205 | Verify dispatch (014 rule) | ❌ FAIL: scope change undocumented (as predicted) | 14 turns, $0.13 |
| 21:58 | 43107702755 | Re-apply | ✅ but scope note written inline, not in the section | 16 turns, $0.12 |
| 21:59 | 43107919479 | Verify (Approve, auto) | ❌ FAIL: section missing → 015 deterministic check | 16 turns, $0.14 |
| 22:05 | 43108778620 | Re-apply (ran the 014 workflow: merge ref 23 s older than 015) | ✅ section written | 15 turns, $0.12 |
| 22:06 | 43108985466 | Verify (Approve, auto) | ✅ **PASS** | 15 turns, $0.13 |
| 22:41 | 43113921088 | `/reapply` comment (016) | skipped: the comment began with a space (`startsWith` has no trim) | – |
| 22:44 | 43114321202 | `/reapply` comment (016) | ✅ 👀 ack, 2 items (incl. the skipped comment), requirement → `/opsx:update`, **015 scope check passed** | 24 turns, $0.14 |
| 22:46 | 43114589446 | Verify (Approve, auto) | ✅ PASS (ran the pre-018 workflow: no archive job) | 14 turns, $0.13 |
| 22:55 | 43115763455 | Verify (re-Approve, auto) | ✅ PASS, again no archive job: stale merge ref (built on 016) | 16 turns, $0.10 |
| 22:58 | 43116149538 | Verify dispatch (from main) | ✅ PASS → `archive` job waited for the `openspec-archive` reviewer (approved after 18 s) → archived in 17 s | 14 turns, $0.07 |
| 23:01 | – | Squash merge PR #1 | ✅ `2362212` on main: `openspec/specs/app-version-footer/spec.md` + `openspec/changes/archive/2026-11-11-task-1-version-footer/` | – |

PR #1 final: archived and squash merged (`2362212`); `main` has no active change.
Totals (15 agent runs incl. fallback): 266 turns, $1.99 notional (`total_cost_usd`, charged to the
subscription quota, not billed). Per stage on CI with Sonnet: Plan 18–21 turns (~$0.13–0.20),
Apply 28 (~$0.19), Re-apply 12–32 (~$0.09–0.19; `/reapply` 24, $0.14), Verify 11–16 (~$0.07–0.14), Archive no agent
(~17 s job, behind a human gate). Wall clock for PR #1: 19:57 → 23:01 (≈3 h), including building
and debugging the pipeline itself and a 45-min GitHub outage. Local plan runs before
CI: 21–41 turns on Fable ($0.46–1.92). Every CI run used `claude-sonnet-5-5` (dropdown default
`sonnet`) with 0 permission denials.

## 3b. Run log, PR #2 (task-2, model `opus`, UTC, 2026-11-12)
| Time | Run | Stage / event | Result | Agent stats |
|---|---|---|---|---|
| 06:59 | 43171970139 | Plan dispatch (task-2, opus) | ✅ draft PR #2 (planned before the 020 rule: task 2.2 needed a browser) | 28 turns, $0.50 |
| 07:05 | 43172704001 | Apply ("Ready for review") | ❌ `tasks-complete`: task 2.2 (browser check) unticked; 2 permission denials (`pnpm preview` in background, `vite build --outDir /tmp`); guards, build, lint OK | 28 turns, $0.36 |
| 07:15 | 43173962826 | `/reapply` (reword 2.2 to the CI-runnable `dist/` check) | ✅ F1 = implementation; 2.2 reworded and ticked, design.md Risks line aligned (spec impact: `design.md`), browser check became a reviewer note; `<h1>` edit redone | 33 turns, $0.41, 0 denials |
| 07:25 | 43175121120 | Verify (Approve, auto; ran from the merge ref, pre-021) | ✅ **PASS**; 1 denial: `git fetch --depth=2 origin main` (shallow checkout, could not diff vs base for task 1.2) → fetch-depth 0 (022) | 22 turns, $0.38 |
| 07:27 | 43175121120 | `archive` job (gate approved) | ✅ archived as `2026-11-12-task-2-main-heading-text`, main spec `main-page-heading` (13 s job) | – |
| 07:28 | – | Squash merge PR #2 | ✅ `930a91b` | – |

PR #2 final: Plan 06:59 → merge 07:28 (**29 min** wall clock, all event-driven except Plan; no stale merge ref,
because the PR was opened after every workflow existed). 4 agent runs on `claude-opus-5-5`: Plan (28 turns,
$0.50), Apply (failed on an un-runnable task), `/reapply`, Verify. Total **111 turns, $1.65 notional**.
Opus costs about 2× Sonnet per stage on this repo.

## 3c. Run log, PR #4 (task-3) and PR #3 (task-4) in parallel (model `sonnet`, UTC, 2026-11-12)
| Time | Run | Stage / event | Result | Agent stats |
|---|---|---|---|---|
| 08:15 | 43181472012 / 43181476952 | Plan dispatch ×2 (first run of the 020 rule) | ✅ draft PRs #4 / #3; every task CI-doable; task-4 spotted that PR #2's `main-page-heading` spec pinned the `<title>` and added a MODIFIED delta handing it to `browser-tab-title` | 15 turns $0.12 / 18 turns $0.12 (1 harmless denial: `mkdir -p`) |
| 08:26 | 43182884838 / 43182891027 → 43182896535 / 43182901989 | Ready for review ×2 → **trampoline** (first run, 024) → dispatched Apply ×2 | ✅ Events → Apply ~5 s later; both Applies ran **in parallel** (~1 min each); only `src/App.tsx` / `index.html` changed | 14 turns $0.11 / 14 turns $0.10 (1 denial: `sed -i` to tick tasks) |
| 08:34 | 43184039573 / 43184062098 → 43184049952 / 43184073218 | Approve ×2 → trampoline → Verify with `approved_sha` | ✅ PASS ×2 (~50 s each); 0 denials: the 022 full-history checkout let Verify diff against main | 11 turns $0.10 / 11 turns $0.10 |
| 08:40 | same runs, `archive` job | gate approved ×2 | ❌ both: `validate --all --strict` rejected the new main spec's placeholder `## Purpose` → 025 | – |

Sonnet plans for new capabilities omitted the delta `## Purpose` (the Opus plans for PR #1/#2 had
included it by chance). Nothing catches this before the archive: the change validates, Verify passes.

## 3d. Sync stage (026, D16): PRs #5 (task-7), #6 (task-5), #7 (task-6), model `sonnet`, UTC, 2026-11-12
Why it exists: parallel PRs drift from `main` as soon as one of them merges. PR #3 conflicted after
PR #4 merged and needed a manual merge. GitHub's merge queue only re-tests; it never resolves.

| Time | Run | Stage / event | Result | Agent stats |
|---|---|---|---|---|
| 09:58 | 43192908031 | Sync on the push of 026 (first run) | ✅ no-op: no open OpenSpec PR behind main | – |
| 09:58 | 43192908545 / 43192914312 / 43192919931 | Plan dispatch ×3 (task-5, -6, -7) | ✅ draft PRs #6 / #7 / #5; new capabilities carry a `## Purpose` (025 rule); task-5 MODIFIED every spec that pinned "Count is" | 16 turns $0.13 / 14 turns $0.11 / 12 turns $0.09, 0 denials |
| 10:07 | 43197508948 | **Sync on the push of 027** (main moved: tasks 8–12) | ✅ `find` (4 s) → 3 parallel matrix jobs, each `git merge main` **clean, no agent**: checks (validate, Purpose, spec preflight, build, lint) → merge commit `openspec(task-N): merge main 1f65841 (clean)` + 🔄 comment; 20–35 s per PR | none ($0) |

Pending (user drives by hand): Ready ×3 → merge task-5 → Sync should send PR #7 (task-6, same line
in `src/App.tsx`) through the **resolve** agent and keep PR #5 (task-7) on the clean path.

Slide points:
- Sync is event-driven from `main` (push), so it never runs a stale workflow; its own pushes use
  `GITHUB_TOKEN` and cannot trigger it again (no loop).
- Cost scales with conflicts, not with PRs: a clean sync is deterministic and free; the agent
  runs only for a conflicted PR, and its edits are fenced by `guard-resolve`.
- Correctness beyond text: `spec-preflight` archives the change into a scratch copy of the
  updated main specs, so a delta that no longer applies fails here, not at the archive gate.
- The human gate is preserved: the sync push makes approvals stale; re-approve → Verify.

## 4. Decisions (full table in docs/PLAN.md)
D1 POC in this repo · D2 tasks as text files (stand-in for Jira) · D3 subscription token
(`claude setup-token`) · D4 raw `claude -p`, not claude-code-action · D5 Actions only, no `act` · D6 layer
separation · D7 manifest audit trail · D8 initial scope · D9 single model choice at Plan (dropdown
sonnet/opus/fable) · D10 re-apply on Request changes, commenter filter · D11 the agent classifies
feedback; requirement → `/opsx:update` + Spec impact · D12 the amended change is the source of truth;
scope changes must be documented in `## Scope changes from review`, else Verify FAILs · D13 archive
as a separate Verify job behind the `openspec-archive` environment (manual approval) · D14 squash-only
merges (PR title + body) · D15 PR events only dispatch the stage workflows on main (trampoline).

## 5. Problems found and fixes (good slide material)
| Problem | Symptom | Root cause | Fix (commit) |
|---|---|---|---|
| Token line break | 1 turn, $0, "Invalid Authorization header" | `setup-token` output wrapped when pasted | `tr -d` when setting the secret; run-agent rejects whitespace (008) |
| Local hooks leaking into `claude -p` | every Bash call denied | user-level `rtk` hook and chained commands | `--setting-sources project`; prompts say one command per call (004) |
| PR events start nothing | no run, no error | PR workflows come from the merge ref, rebuilt lazily | dispatch `pr=N` fallback; `/reapply` runs from main (016); trampoline `openspec-events.yml` dispatches every stage on main (024) |
| GitHub outage | `startup_failure`, uncancellable "queued" runs | GitHub incident 20:20–21:05Z | proven with a byte-identical known-good commit; wait it out |
| Scripts older than the workflow | `pr-feedback.sh: No such file` | scripts ran from the PR branch | trusted scripts from the workflow commit (`$CI_SCRIPTS`), also a security fix (012) |
| Verify FAIL on a reviewer-approved scope change | SHA "out of scope" per the ticket | no source-of-truth rule | D12 (014) |
| Scope note in the wrong place | Verify FAIL a stage later | a structural rule was left to agent judgment | deterministic `scope-documented` + literal format (015) |
| Comment posted seconds after the review | not considered | feedback cutoff = run start | it rolls to the next run; `/reapply` command (016) |
| `/reapply` with a leading space | run skipped | expression `startsWith` without trim | type it at the start (feedback is not lost: it rolls to the next run); optional gate job with a bash regex |
| Gate missing after a re-approve | Verify PASS but no `archive` job | the review event ran an older Verify from the stale merge ref | dispatch from main; fix: trampoline (PR events only start the main-branch workflow) |
| Plan wrote an un-runnable task (PR #2) | Apply fail at `tasks-complete`, 1 task unticked, nothing pushed | task 2.2 "open the page with `pnpm preview` and check visually"; the CI sandbox denies servers | plan prompt: only tasks an unattended agent can do and check; visual checks → reviewer note (020); PR #2 unblocked via `/reapply` |
| Verify could not diff against the base | 1 denial (`git fetch --depth=2`), task 1.2 checked from the source only | `actions/checkout` defaults to depth 1; network git is not allowed | `fetch-depth: 0` + prompt hint `git diff origin/main...HEAD` (022) |
| Archive fails at the gate (PR #3, #4) | `✗ spec/<new-cap>`: Purpose is a placeholder | a new capability's delta had no `## Purpose`, so `openspec archive` wrote a placeholder that `validate --all --strict` rejects; Opus happened to write one, Sonnet did not | `new-specs-have-purpose` check at Plan, Apply and Verify + literal example in `plan.md`/`reapply.md`; archive uses `validate-all` (records why) (025) |
| Second parallel PR conflicts (PR #3 after #4) | GitHub "conflicts" on `.openspec-ci/manifest.json` only | every branch wrote the same manifest path; each squash merge put one task's manifest on main | per-task `.openspec-ci/manifests/<task>.json`; PR #3 unblocked by a manual merge (keep ours); Sync stage for real conflicts (026) |
| Missing verdict → wrong exit code | exit 1 instead of 4 | `pipefail` + `grep` with no match | `{ grep || true; }` (013) |

## 6. Guardrails (security slide)
- Agent tool allowlist per stage (`--allowedTools`, `--permission-mode dontAsk`); plan may write only
  `openspec/**`; verify is read-only.
- Deterministic diff guards after every agent run (protected: `.github/`, `scripts/`, `tasks/`, `.claude/`,
  main specs, other changes); nothing is pushed if a guard fails.
- Trusted scripts from the workflow commit, never from the PR branch; the secret is scoped to the agent
  step only; `GH_TOKEN` only on gh steps; PR inputs reach shells via `env:` only (no `${{ }}` in
  `run:`).
- Review feedback only from OWNER/MEMBER/COLLABORATOR and never bots; the prompt treats it as data,
  not instructions; same-repo `openspec/task-N` branches only.
- Failures explain themselves (021): every check (`openspec-ops.sh`, `run-agent.sh`, inline
  `::error::`) appends its reason to `$RUNNER_TEMP/openspec-ci-failures.txt`; the run summary
  (job summary + `summary.md` in the artifact) shows it with the agent's Deviations/Issues and
  denials; a failed Apply/re-apply also posts it as a PR comment.
- Explicit workflow `permissions:` (repo default read); Verify has `contents: read`; stale-approval
  check; archive behind a required-reviewer environment.

## 7. Lessons (for the closing slide)
- Parallel work needs a sync stage: merge main into every open PR after each merge, deterministic when clean, agent only on conflict, guarded, and re-gated by a human.
- Gate agents with human PR actions plus deterministic checks; use the LLM for judgment, scripts for
  structure.
- PR-event workflows depend on the merge ref: keep a dispatch fallback or trigger from main.
- Before blaming code, re-run a known-good commit and check githubstatus.com; let queued runs finish.
- A structural rule left to the model holds only as long as the model happens to follow it: PR #1/#2 (Opus) wrote a Purpose, PR #3/#4 (Sonnet) did not. Check it deterministically, at the earliest stage.
- A failed run must say why where people look (job summary, PR comment), not only in the step log.
- Make every stage produce an audit trail (manifest, artifacts, PR comments with run links).
- Cost is small per stage (~$0.10–0.20 notional on Sonnet); review rounds dominate.

## 8. Repo settings applied (2026-11-11, via API)
- Actions enabled; default workflow permissions `read`; Actions may create/approve PRs.
- Secret `CLAUDE_CODE_OAUTH_TOKEN`.
- Environment `openspec-archive`: required reviewer `mastrobardo`, prevent self-review off, no branch
  policy (review events run on `refs/pull/N/merge`).
- Merges: squash only (`allow_merge_commit=false`, `allow_rebase_merge=false`); squash commit title =
  PR title, message = PR body.

## 9. Not yet proven (be honest on slides)
- Nothing in the PR #1 or PR #2 lifecycles. PR #2 reached the archive gate from a real Approve (no
  dispatch). The trampoline fix for stale merge refs (024; it hit PR #1 three times, PR #2 never) is built but not yet run on GitHub.
  (`/reapply` and the 015 scope check are proven: run 43114321202.)
- Proven on PR #3/#4: the 024 trampoline (Ready, Approve), the 020 plan rule, the 021 summary (passing runs),
  the 022 full-history Verify checkout, parallel PRs. Proven on PRs #5–#7: the 025 Purpose rule at Plan, the 026 Sync clean path (3 PRs in parallel,
  no agent). Not yet on GitHub: the 021 failure comment (task-11 should trigger it), the 026 resolve
  path (task-5 merge → PR #7), the spec-preflight failing case.
- The Fable model in CI (Opus: PR #2; Sonnet: PR #1, #3, #4).
