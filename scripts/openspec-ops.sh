#!/usr/bin/env bash
# Deterministic OpenSpec checks used by the workflows. No agent logic lives here.
#
# Usage: scripts/openspec-ops.sh <command> [args]
#
# Commands
#   change-id <task-id>        print the single change in openspec/changes/ named <task-id>-*
#   validate <change-id>       openspec validate <change-id> --strict
#   tasks-complete <change-id> fail if tasks.md is missing or has unticked "- [ ]" items
#   guard-plan-diff [base-ref] fail if the working tree (and base-ref...HEAD, if given) touches
#                              anything outside openspec/ (.openspec-ci/ is ignored)
#   guard-diff <apply|reapply|verify> <change-id> <base-sha>
#                              check files changed since base-sha (working tree + untracked):
#                              both modes forbid .github/ scripts/ tasks/ .claude/ openspec/specs/
#                              openspec/config.yaml and other changes; apply also forbids this
#                              change's artifacts except tasks.md. reapply prints the changed
#                              artifacts (spec impact) on stdout. verify is read-only: any
#                              changed file fails.
#   scope-documented <change-id> <impact-file>
#                              after a reapply: if the impact list (guard-diff reapply stdout)
#                              touches proposal.md or specs/, proposal.md must have a
#                              '## Scope changes from review' section with '- F<n>' entries (D12)
#   new-specs-have-purpose <change-id>
#                              every delta spec for a capability that is not yet in openspec/specs/
#                              must have a '## Purpose' of at least 50 characters: `openspec archive` copies it
#                              into the new main spec, else writes a placeholder that
#                              `validate --all --strict` rejects (only at the archive gate)
#   validate-all               openspec validate --all --strict (main specs + changes); on failure
#                              records the failing items and their messages
#   spec-preflight <change-id> archive the change into a scratch copy of openspec/ and run
#                              validate --all --strict there: catches a delta that no longer
#                              applies to the current main specs before the archive gate. An
#                              already archived change only gets validate --all.
#   guard-resolve <change-id> <conflicts-file>
#                              after the resolve agent, during a merge: files it changed (vs the
#                              index) must be conflicted files or under this change's folder,
#                              never .github/ scripts/ tasks/ .claude/; no conflict markers left
#   manifest-path <task-id>    print the task's manifest path (.openspec-ci/manifests/<task>.json;
#                              the pre-026 .openspec-ci/manifest.json if only that one exists)
#   manifest <key=value>...    create/merge the manifest of task=<id> (or $OPENSPEC_CI_TASK); sets
#                              created_at once, updated_at always; moves a pre-026 manifest
# Env
#   OPENSPEC_CI_FAILURES  file that collects failure reasons for scripts/run-summary.sh
#                         (default $RUNNER_TEMP/openspec-ci-failures.txt in CI, unset locally)
# Exit codes
#   0 ok | 1 usage/setup error | 2 check failed
set -euo pipefail

root="$(git rev-parse --show-toplevel)"
cd "$root"

failures="${OPENSPEC_CI_FAILURES:-${RUNNER_TEMP:+$RUNNER_TEMP/openspec-ci-failures.txt}}"
record() { [[ -n "$failures" ]] && printf '%s\n' "$@" >> "$failures"; return 0; }
# detail: evidence lines for the next fail (stderr + failures file, indented).
detail() { echo "$1" >&2; record "$(sed 's/^/    /' <<<"$1")"; }
die()  { echo "openspec-ops: $*" >&2; record "openspec-ops ${command:-}: $*"; exit 1; }
fail() { echo "openspec-ops: FAIL: $*" >&2; record "openspec-ops ${command:-}: FAIL: $*"; exit 2; }
need() { command -v "$1" >/dev/null || die "$1 not installed"; }

valid_change_id() { [[ "$1" =~ ^[a-z0-9][a-z0-9-]*$ ]] || die "invalid change-id: '$1'"; }

cmd_change_id() {
  local task_id="${1:-}"
  [[ "$task_id" =~ ^task-[0-9]+$ ]] || die "task-id must look like task-N"
  need openspec; need jq
  local matches count
  matches="$(openspec list --json --sort name | jq -r --arg p "$task_id-" \
    '.changes[].name | select(startswith($p))')"
  count="$(grep -c . <<<"$matches" || true)"
  case "$count" in
    0) fail "no change named $task_id-* in openspec/changes/" ;;
    1) echo "$matches" ;;
    *) fail "several changes match $task_id-*: $(tr '\n' ' ' <<<"$matches")" ;;
  esac
}

cmd_validate() {
  local change_id="${1:-}"; valid_change_id "$change_id"
  need openspec
  openspec validate "$change_id" --type change --strict --no-interactive || fail "validation of $change_id"
}

cmd_tasks_complete() {
  local change_id="${1:-}"; valid_change_id "$change_id"
  local file="openspec/changes/$change_id/tasks.md"
  [[ -f "$file" ]] || fail "$file not found"
  local open
  open="$(grep -nE '^[[:space:]]*- \[ \]' "$file" || true)"
  if [[ -n "$open" ]]; then
    fail_open="$(grep -c . <<<"$open") unticked task(s) in $file"
    record "openspec-ops tasks-complete: FAIL: $fail_open"
    detail "$open"
    echo "openspec-ops: FAIL: $fail_open" >&2
    exit 2
  fi
  grep -qE '^[[:space:]]*- \[[xX]\]' "$file" || fail "no tasks found in $file"
  echo "openspec-ops: all tasks complete in $file" >&2
}

cmd_guard_plan_diff() {
  local base="${1:-}" paths
  paths="$(git status --porcelain --untracked-files=all | cut -c4- | sed 's/.* -> //')"
  if [[ -n "$base" ]]; then
    git rev-parse --verify --quiet "$base^{commit}" >/dev/null || die "unknown base ref: $base"
    paths+=$'\n'"$(git diff --name-only "$base...HEAD")"
  fi
  local outside
  outside="$(grep -v '^$' <<<"$paths" | sort -u | grep -vE '^(openspec/|\.openspec-ci/)' || true)"
  if [[ -n "$outside" ]]; then
    record "openspec-ops guard-plan-diff: FAIL: planning touched files outside openspec/"
    detail "$outside"
    echo "openspec-ops: FAIL: planning touched files outside openspec/" >&2
    exit 2
  fi
  echo "openspec-ops: plan diff is confined to openspec/" >&2
}

cmd_guard_diff() {
  local mode="${1:-}" change_id="${2:-}" base="${3:-}"
  [[ "$mode" =~ ^(apply|reapply|verify)$ ]] || die "mode must be apply|reapply|verify"
  valid_change_id "$change_id"
  git rev-parse --verify --quiet "$base^{commit}" >/dev/null || die "unknown base sha: '$base'"

  local own="openspec/changes/$change_id/" paths path bad=() impact=()
  paths="$( { git diff --name-only "$base"; git ls-files --others --exclude-standard; } | sort -u)"
  while IFS= read -r path; do
    [[ -z "$path" ]] && continue
    if [[ "$mode" == verify ]]; then
      bad+=("$path (verify is read-only)")
    elif [[ "$path" =~ ^(\.github/|scripts/|tasks/|\.claude/|openspec/specs/|openspec/config\.yaml$) ]]; then
      bad+=("$path (protected)")
    elif [[ "$path" == openspec/changes/* && "$path" != "$own"* ]]; then
      bad+=("$path (another change)")
    elif [[ "$path" == "$own"* && "$path" != "${own}tasks.md" ]]; then
      if [[ "$mode" == apply ]]; then bad+=("$path (approved artifact)"); else impact+=("$path"); fi
    fi
  done <<<"$paths"

  if [[ ${#bad[@]} -gt 0 ]]; then
    record "openspec-ops guard-diff: FAIL: $mode touched files it must not change"
    detail "$(printf '%s\n' "${bad[@]}")"
    echo "openspec-ops: FAIL: $mode touched files it must not change" >&2
    exit 2
  fi
  [[ ${#impact[@]} -gt 0 ]] && printf '%s\n' "${impact[@]}"
  echo "openspec-ops: $mode diff OK ($(grep -c . <<<"$paths" || true) files, ${#impact[@]} artifact changes)" >&2
}

cmd_scope_documented() {
  local change_id="${1:-}" impact="${2:-}"
  valid_change_id "$change_id"
  [[ -f "$impact" ]] || die "impact file not found: '$impact'"
  local own="openspec/changes/$change_id/" requirement
  requirement="$(grep -E "^${own}(proposal\.md|specs/)" "$impact" || true)"
  if [[ -z "$requirement" ]]; then
    echo "openspec-ops: no proposal/spec changes; nothing to document" >&2
    return 0
  fi
  local file="${own}proposal.md" entries
  [[ -f "$file" ]] || fail "$file not found"
  entries="$(awk '/^## Scope changes from review[[:space:]]*$/ {f=1; next} /^## / {f=0}
                  f && /^- F[0-9]+/ {n++} END {print n+0}' "$file")"
  if [[ "$entries" -eq 0 ]]; then
    local msg="proposal/specs changed but $file has no '## Scope changes from review' section with '- F<n>' entries"
    record "openspec-ops scope-documented: FAIL: $msg"
    detail "$requirement"
    echo "openspec-ops: FAIL: $msg" >&2
    exit 2
  fi
  echo "openspec-ops: scope changes documented ($entries entr$( [[ $entries -eq 1 ]] && echo y || echo ies))" >&2
}

cmd_new_specs_have_purpose() {
  local change_id="${1:-}"; valid_change_id "$change_id"
  local dir="openspec/changes/$change_id/specs" f cap text missing=() checked=0
  [[ -d "$dir" ]] || { echo "openspec-ops: no delta specs in $change_id" >&2; return 0; }
  for f in "$dir"/*/spec.md; do
    [[ -f "$f" ]] || continue
    cap="$(basename "$(dirname "$f")")"
    [[ -d "openspec/specs/$cap" ]] && continue   # existing capability: its Purpose is already set
    checked=$((checked + 1))
    text="$(awk '/^## Purpose[[:space:]]*$/ {f=1; next} /^#/ {f=0} f && NF {print}' "$f")"
    # openspec validate --strict also rejects a Purpose under 50 characters.
    if [[ -z "$text" || "$text" =~ ^[[:space:]]*(TBD|TODO) ]]; then missing+=("$f (missing)")
    elif [[ "$(tr -d '\n' <<<"$text" | wc -c)" -lt 50 ]]; then missing+=("$f (under 50 characters)"); fi
  done
  if [[ ${#missing[@]} -gt 0 ]]; then
    local msg="new capability delta spec(s) need a '## Purpose' of at least 50 characters (else the archived main spec fails validate --strict)"
    record "openspec-ops new-specs-have-purpose: FAIL: $msg"
    detail "$(printf '%s\n' "${missing[@]}")"
    echo "openspec-ops: FAIL: $msg" >&2
    exit 2
  fi
  echo "openspec-ops: new capabilities have a Purpose ($checked checked)" >&2
}

cmd_validate_all() {
  need openspec
  local out
  if out="$(openspec validate --all --strict --no-interactive 2>&1)"; then
    echo "$out" >&2
    return 0
  fi
  echo "$out" >&2
  record "openspec-ops validate-all: FAIL: openspec validate --all --strict"
  detail "$(grep -E '✗|⚠|ERROR|WARNING|Details:' <<<"$out" || echo "$out" | tail -n 20)"
  exit 2
}

manifest_path() { # <task-id>
  local task="$1" new=".openspec-ci/manifests/$1.json" old=".openspec-ci/manifest.json"
  [[ "$task" =~ ^task-[0-9]+$ ]] || die "task-id must look like task-N"
  if [[ ! -f "$new" && -f "$old" && "$(jq -r '.task // empty' "$old")" == "$task" ]]; then
    echo "$old"
  else
    echo "$new"
  fi
}

cmd_manifest_path() { need jq; manifest_path "${1:-}"; }

cmd_manifest() {
  [[ $# -gt 0 ]] || die "manifest needs at least one key=value"
  need jq
  local task="${OPENSPEC_CI_TASK:-}" kv key
  for kv in "$@"; do [[ "$kv" == task=* ]] && task="${kv#task=}"; done
  [[ -n "$task" ]] || die "manifest needs task=<id> or OPENSPEC_CI_TASK"
  local file; file="$(manifest_path "$task")"
  # One manifest per task, so parallel PRs never edit the same file (026). Move a pre-026 one.
  local new=".openspec-ci/manifests/$task.json"
  mkdir -p .openspec-ci/manifests
  if [[ "$file" != "$new" ]]; then mv "$file" "$new"; file="$new"; fi
  [[ -f "$file" ]] || echo '{}' > "$file"
  local now; now="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  local args=(--arg now "$now") filter='.'
  local i=0
  for kv in "$@"; do
    [[ "$kv" == *=* ]] || die "expected key=value, got '$kv'"
    key="${kv%%=*}"
    [[ "$key" =~ ^[a-z][a-z0-9_]*$ ]] || die "invalid key: '$key'"
    args+=(--arg "k$i" "$key" --arg "v$i" "${kv#*=}")
    filter+=" | .[\$k$i] = \$v$i"
    i=$((i + 1))
  done
  filter+=' | .created_at //= $now | .updated_at = $now'
  local tmp; tmp="$(mktemp)"
  jq "${args[@]}" "$filter" "$file" > "$tmp" && mv "$tmp" "$file"
  cat "$file"
}

cmd_spec_preflight() {
  local change_id="${1:-}"; valid_change_id "$change_id"
  need openspec
  local tmp out; tmp="$(mktemp -d)"
  cp -R openspec "$tmp/"
  if [[ -d "openspec/changes/$change_id" ]]; then
    if ! out="$(cd "$tmp" && openspec archive -y "$change_id" 2>&1)"; then
      echo "$out" >&2
      record "openspec-ops spec-preflight: FAIL: openspec archive of $change_id does not apply to the current main specs"
      detail "$(tail -n 15 <<<"$out")"
      rm -rf "$tmp"; exit 2
    fi
  fi
  if ! out="$(cd "$tmp" && openspec validate --all --strict --no-interactive 2>&1)"; then
    echo "$out" >&2
    record "openspec-ops spec-preflight: FAIL: main specs after archiving $change_id do not validate"
    detail "$(grep -E '✗|⚠|ERROR|WARNING|Details:' <<<"$out" || tail -n 20 <<<"$out")"
    rm -rf "$tmp"; exit 2
  fi
  rm -rf "$tmp"
  echo "openspec-ops: spec preflight OK ($change_id archives cleanly onto the current main specs)" >&2
}

cmd_guard_resolve() {
  local change_id="${1:-}" conflicts="${2:-}"
  valid_change_id "$change_id"
  [[ -f "$conflicts" ]] || die "conflicts file not found: '$conflicts'"
  local own="openspec/changes/$change_id/" paths path bad=() markers
  paths="$( { git diff --name-only; git ls-files --others --exclude-standard; } | sort -u)"
  while IFS= read -r path; do
    [[ -z "$path" ]] && continue
    if [[ "$path" =~ ^(\.github/|scripts/|tasks/|\.claude/) ]]; then
      bad+=("$path (protected)")
    elif ! grep -qxF "$path" "$conflicts" && [[ "$path" != "$own"* ]]; then
      bad+=("$path (not a conflicted file)")
    fi
  done <<<"$paths"
  if [[ ${#bad[@]} -gt 0 ]]; then
    record "openspec-ops guard-resolve: FAIL: resolve touched files it must not change"
    detail "$(printf '%s\n' "${bad[@]}")"
    echo "openspec-ops: FAIL: resolve touched files it must not change" >&2
    exit 2
  fi
  markers="$(while IFS= read -r path; do
      [[ -f "$path" ]] && grep -nE '^(<<<<<<<|>>>>>>>)( |$)|^=======$' "$path" | sed "s|^|$path:|"
    done < "$conflicts" || true)"
  if [[ -n "$markers" ]]; then
    record "openspec-ops guard-resolve: FAIL: conflict markers left"
    detail "$markers"
    echo "openspec-ops: FAIL: conflict markers left" >&2
    exit 2
  fi
  echo "openspec-ops: resolve diff OK ($(grep -c . <<<"$paths" || true) files changed by the agent, no markers)" >&2
}

command="${1:-}"; shift || true
case "$command" in
  change-id)       cmd_change_id "$@" ;;
  validate)        cmd_validate "$@" ;;
  tasks-complete)  cmd_tasks_complete "$@" ;;
  guard-plan-diff) cmd_guard_plan_diff "$@" ;;
  guard-diff)      cmd_guard_diff "$@" ;;
  scope-documented) cmd_scope_documented "$@" ;;
  new-specs-have-purpose) cmd_new_specs_have_purpose "$@" ;;
  validate-all)    cmd_validate_all "$@" ;;
  spec-preflight)  cmd_spec_preflight "$@" ;;
  guard-resolve)   cmd_guard_resolve "$@" ;;
  manifest-path)   cmd_manifest_path "$@" ;;
  manifest)        cmd_manifest "$@" ;;
  *) die "usage: $0 <change-id|validate|tasks-complete|guard-plan-diff|guard-diff|scope-documented|new-specs-have-purpose|validate-all|spec-preflight|guard-resolve|manifest-path|manifest> [args]" ;;
esac
