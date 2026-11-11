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
(`tasks/task-1.txt`: version footer), 2026-11-11: Plan → Apply → 4 re-applies driven by review
feedback (including a reviewer-driven scope change) → Verify PASS. Archive (gated) is next (017).

## 2. Lifecycle (as built)
| Stage | Trigger (human gate) | Agent? | Deterministic checks | Output |
|---|---|---|---|---|
| Plan | Actions tab: task + model dropdown | yes (`/opsx:propose`) | guard-plan-diff (only `openspec/`), change-id, validate --strict | branch `openspec/task-N`, draft PR, manifest |
| Apply | "Ready for review" (or dispatch `pr`) | yes (`/opsx:apply`) | guard-diff apply (code + tasks.md only), tasks-complete, validate, build, lint | commit on PR, report comment |
| Re-apply | "Request changes", `/reapply [text]` comment (016), or dispatch | yes (classify → `/opsx:update` → `/opsx:apply`) | pr-feedback (owner/member/collab, since last apply), guard-diff reapply (+ spec impact), scope-documented (015), checks | commit, comment with ⚠️ Spec impact box |
| Verify | "Approve" (or dispatch) | yes (`/opsx:verify`, read-only) | stale-approval check, change-id, validate, tasks-complete, guard-diff verify (no changes) | ✅/❌/⚠️ verdict comment, job fails unless PASS; never commits |
| Archive (017) | Environment `openspec-archive` approval after PASS | no (`openspec archive -y`) | verified sha == head, guard (only `openspec/`), validate | archive commit, then squash merge |

Layers (D6): workflows orchestrate only; `scripts/run-agent.sh` (agent adapter, per-stage tool
allowlist), `scripts/prompts/*.md` (stage prompts), `scripts/openspec-ops.sh` (deterministic checks),
`scripts/pr-feedback.sh` (review feedback). Audit trail: `.openspec-ci/manifest.json` on the PR branch,
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

PR #1 final: open, approved, 6 commits, 10 files, +181/−0. Not yet archived or merged.
Totals (11 agent runs incl. fallback): 198 turns, $1.55 notional (`total_cost_usd`, charged to the
subscription quota, not billed). Per stage on CI with Sonnet: Plan 18–21 turns (~$0.13–0.20),
Apply 28 (~$0.19), Re-apply 12–32 (~$0.09–0.19), Verify 11–16 (~$0.11–0.14). Local plan runs before
CI: 21–41 turns on Fable ($0.46–1.92). Every CI run used `claude-sonnet-5-5` (dropdown default
`sonnet`) with 0 permission denials.

## 4. Decisions (full table in docs/PLAN.md)
D1 POC in this repo · D2 tasks as text files (stand-in for Jira) · D3 subscription token
(`claude setup-token`) · D4 raw `claude -p`, not claude-code-action · D5 Actions only, no `act` · D6 layer
separation · D7 manifest audit trail · D8 initial scope · D9 single model choice at Plan (dropdown
sonnet/opus/fable) · D10 re-apply on Request changes, commenter filter · D11 the agent classifies
feedback; requirement → `/opsx:update` + Spec impact · D12 the amended change is the source of truth;
scope changes must be documented in `## Scope changes from review`, else Verify FAILs · D13 archive
as a separate Verify job behind the `openspec-archive` environment (manual approval) · D14 squash-only
merges (PR title + body).

## 5. Problems found and fixes (good slide material)
| Problem | Symptom | Root cause | Fix (commit) |
|---|---|---|---|
| Token line break | 1 turn, $0, "Invalid Authorization header" | `setup-token` output wrapped when pasted | `tr -d` when setting the secret; run-agent rejects whitespace (008) |
| Local hooks leaking into `claude -p` | every Bash call denied | user-level `rtk` hook and chained commands | `--setting-sources project`; prompts say one command per call (004) |
| PR events start nothing | no run, no error | PR workflows come from the merge ref, rebuilt lazily | dispatch `pr=N` fallback; `/reapply` runs from main (016) |
| GitHub outage | `startup_failure`, uncancellable "queued" runs | GitHub incident 20:20–21:05Z | proven with a byte-identical known-good commit; wait it out |
| Scripts older than the workflow | `pr-feedback.sh: No such file` | scripts ran from the PR branch | trusted scripts from the workflow commit (`$CI_SCRIPTS`), also a security fix (012) |
| Verify FAIL on a reviewer-approved scope change | SHA "out of scope" per the ticket | no source-of-truth rule | D12 (014) |
| Scope note in the wrong place | Verify FAIL a stage later | a structural rule was left to agent judgment | deterministic `scope-documented` + literal format (015) |
| Comment posted seconds after the review | not considered | feedback cutoff = run start | it rolls to the next run; `/reapply` command (016) |
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
- Explicit workflow `permissions:` (repo default read); Verify has `contents: read`; stale-approval
  check; archive behind a required-reviewer environment.

## 7. Lessons (for the closing slide)
- Gate agents with human PR actions plus deterministic checks; use the LLM for judgment, scripts for
  structure.
- PR-event workflows depend on the merge ref: keep a dispatch fallback or trigger from main.
- Before blaming code, re-run a known-good commit and check githubstatus.com; let queued runs finish.
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
- The 015 `scope-documented` step on GitHub (the run that fixed PR #1 used the 014 workflow).
- `/reapply` (016) and gated archive (017) on GitHub.
- Concurrency of several PRs in parallel, other tasks (task-2..4), the Opus/Fable models in CI.
