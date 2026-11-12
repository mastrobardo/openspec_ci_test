#!/usr/bin/env bash
# Agent execution adapter: runs one lifecycle stage with Claude Code in headless mode.
#
# Usage: scripts/run-agent.sh <plan|apply|reapply|verify> <task-id> [change-id]
#
# Inputs
#   task-id     e.g. task-1 (reads tasks/<task-id>.txt)
#   change-id   OpenSpec change name; required for apply, reapply and verify
# Env
#   CLAUDE_CODE_OAUTH_TOKEN  subscription token (CI). Locally, the logged-in session is used.
#   CLAUDE_MODEL             optional model override
#   OPENSPEC_CI_OUT          output dir (default .openspec-ci/runs)
#   OPENSPEC_CI_FEEDBACK     reapply only: review feedback file (scripts/pr-feedback.sh output)
#   OPENSPEC_CI_FAILURES     file that collects failure reasons for scripts/run-summary.sh
#                            (default $RUNNER_TEMP/openspec-ci-failures.txt in CI, unset locally)
# Outputs (in $OPENSPEC_CI_OUT)
#   <stage>.json   raw `claude --output-format json` result (cost, turns, session id)
#   <stage>.md     the agent's final message (report)
# Exit codes
#   0 ok | 1 usage/setup error | 2 agent error | 3 verify FAIL | 4 verify INCONCLUSIVE
set -euo pipefail

stage="${1:-}"; task_id="${2:-}"; change_id="${3:-}"
# Prompts come from next to this script, so CI can run trusted scripts copied from the workflow's
# commit against a PR branch checkout (which may carry older scripts).
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(git rev-parse --show-toplevel)"
cd "$root"

failures="${OPENSPEC_CI_FAILURES:-${RUNNER_TEMP:+$RUNNER_TEMP/openspec-ci-failures.txt}}"
record() { [[ -n "$failures" ]] && printf '%s\n' "$@" >> "$failures"; return 0; }
die() { echo "run-agent: $*" >&2; record "run-agent $stage: $*"; exit 1; }

[[ "$stage" =~ ^(plan|apply|reapply|verify)$ ]] || die "stage must be plan|apply|reapply|verify"
[[ "$task_id" =~ ^task-[0-9]+$ ]] || die "task-id must look like task-N"
[[ -f "tasks/$task_id.txt" ]] || die "tasks/$task_id.txt not found"
if [[ "$stage" != plan && -z "$change_id" ]]; then die "change-id required for $stage"; fi
feedback="${OPENSPEC_CI_FEEDBACK:-}"
if [[ "$stage" == reapply ]]; then
  [[ -s "$feedback" ]] || die "OPENSPEC_CI_FEEDBACK must point to a non-empty file for reapply"
  [[ "$feedback" =~ ^[A-Za-z0-9._/-]+$ ]] || die "unsafe OPENSPEC_CI_FEEDBACK path"
fi

command -v claude >/dev/null || die "claude CLI not installed"
command -v jq >/dev/null || die "jq not installed"
if [[ -n "${CI:-}" && -z "${CLAUDE_CODE_OAUTH_TOKEN:-}" ]]; then
  die "CLAUDE_CODE_OAUTH_TOKEN is not set"
fi
# A token pasted from `claude setup-token` often carries a terminal line wrap. Never print it.
if [[ "${CLAUDE_CODE_OAUTH_TOKEN:-}" =~ [[:space:]] ]]; then
  die "CLAUDE_CODE_OAUTH_TOKEN contains whitespace/line breaks; re-set the secret as one line"
fi
# Backstop for local runs; in CI the workflow dropdown already restricts the value.
if [[ -n "${CLAUDE_MODEL:-}" && ! "$CLAUDE_MODEL" =~ ^[A-Za-z0-9._-]+$ ]]; then
  die "invalid CLAUDE_MODEL: '$CLAUDE_MODEL'"
fi

# Per-stage tool allowances. Planning may only write under openspec/; verify is read-only.
# The workflow additionally checks the resulting diff (scripts/openspec-ops.sh).
common_ro=(Read Glob Grep Skill "Bash(openspec:*)" "Bash(git diff:*)" "Bash(git log:*)" "Bash(git status:*)" "Bash(ls:*)")
case "$stage" in
  plan)   tools=("${common_ro[@]}" "Write(openspec/**)" "Edit(openspec/**)") ;;
  apply|reapply) tools=("${common_ro[@]}" Write Edit "Bash(pnpm build)" "Bash(pnpm lint)" "Bash(pnpm install:*)") ;;
  verify) tools=("${common_ro[@]}" "Bash(pnpm build)" "Bash(pnpm lint)") ;;
esac

prompt="$(sed -e "s|{{TASK_ID}}|$task_id|g" -e "s|{{CHANGE_ID}}|$change_id|g" \
  -e "s|{{FEEDBACK_FILE}}|$feedback|g" \
  "$script_dir/prompts/$stage.md")"

out="${OPENSPEC_CI_OUT:-.openspec-ci/runs}"
mkdir -p "$out"

# --setting-sources project: ignore user-level settings/hooks so local runs behave like CI.
args=(-p "$prompt" --output-format json --permission-mode dontAsk --setting-sources project
      --allowedTools "${tools[@]}")
[[ -n "${CLAUDE_MODEL:-}" ]] && args+=(--model "$CLAUDE_MODEL")

echo "run-agent: stage=$stage task=$task_id change=${change_id:-<new>} claude=$(claude --version)" >&2
set +e
claude "${args[@]}" > "$out/$stage.json"
rc=$?
set -e

jq -r '.result // empty' "$out/$stage.json" > "$out/$stage.md" 2>/dev/null || true
jq -r '"run-agent: turns=\(.num_turns // "?") cost_usd=\(.total_cost_usd // "?") is_error=\(if .is_error == null then "?" else .is_error end)"' \
  "$out/$stage.json" >&2 2>/dev/null || true

if [[ $rc -ne 0 ]] || [[ "$(jq -r '.is_error // false' "$out/$stage.json" 2>/dev/null)" == true ]]; then
  echo "run-agent: agent failed (exit $rc)" >&2
  record "run-agent $stage: agent failed (claude exit $rc, is_error=$(jq -r '.is_error // "?"' "$out/$stage.json" 2>/dev/null || echo '?'))"
  exit 2
fi

if [[ "$stage" == verify ]]; then
  # `|| true`: no match must mean "missing verdict" (exit 4), not a pipefail abort (exit 1).
  verdict="$( { grep -Eo 'VERDICT: (PASS|FAIL|INCONCLUSIVE)' "$out/verify.md" || true; } | tail -1 | cut -d' ' -f2)"
  echo "run-agent: verdict=${verdict:-missing}" >&2
  [[ "$verdict" == PASS ]] || record "run-agent verify: verdict ${verdict:-missing} (see ## Issues in verify.md)"
  case "$verdict" in
    PASS) exit 0 ;;
    FAIL) exit 3 ;;
    *)    exit 4 ;;  # INCONCLUSIVE or missing verdict never counts as success
  esac
fi
