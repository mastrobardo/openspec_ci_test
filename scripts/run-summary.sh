#!/usr/bin/env bash
# Run summary for a lifecycle stage: what ran, and, if the run failed, why.
# Used for the job summary, the artifact (summary.md) and the failure comment on the PR.
#
# Usage: scripts/run-summary.sh <plan|apply|reapply|verify|archive|sync|resolve> <title> [label=value]...
#
# Inputs (all optional, so a run that failed early still gets a summary)
#   label=value                 extra "- label: value" lines (empty values print n/a)
#   STEPS_JSON                  ${{ toJSON(steps) }}: steps with an id whose outcome is failure
#   CLAUDE_MODEL                the model alias requested (shown next to the model used)
#   OPENSPEC_CI_OUT             run dir (default .openspec-ci/runs): <stage>.json, <stage>.md,
#                               build.log, spec-impact.txt
#   OPENSPEC_CI_FAILURES        reasons written by openspec-ops.sh, run-agent.sh and the
#                               workflows' inline checks (default $RUNNER_TEMP/openspec-ci-failures.txt)
# Output: Markdown on stdout. Never fails (exit 0), so it cannot turn a green run red.
set -uo pipefail

stage="${1:-}"; title="${2:-OpenSpec}"; shift 2 2>/dev/null || shift $#
out="${OPENSPEC_CI_OUT:-.openspec-ci/runs}"
failures="${OPENSPEC_CI_FAILURES:-${RUNNER_TEMP:+$RUNNER_TEMP/openspec-ci-failures.txt}}"
json="$out/$stage.json"; report="$out/$stage.md"

# Section of the agent's report that explains a problem, per stage.
case "$stage" in
  apply|reapply|resolve) section="Deviations" ;;
  verify)        section="Issues" ;;
  *)             section="" ;;
esac

steps_json="${STEPS_JSON:-}"; [[ -n "$steps_json" ]] || steps_json='{}'
failed_steps="$(jq -r 'to_entries[] | select(.value.outcome == "failure") | .key' \
  <<<"$steps_json" 2>/dev/null | paste -sd, - | sed 's/,/, /g')"
reasons=""
[[ -n "$failures" && -s "$failures" ]] && reasons="$(sed 's/^::error:://' "$failures")"
failed=false
[[ -n "$failed_steps" || -n "$reasons" ]] && failed=true

# Print lines 1..n of a file as a fenced block, noting when it was cut.
fenced() { # <file|-> <max-lines>
  local text; text="$(cat "$1")"; local n; n="$(grep -c '' <<<"$text")"
  echo '```text'
  head -n "$2" <<<"$text"
  [[ "$n" -gt "$2" ]] && echo "… ($((n - $2)) more lines in the artifact)"
  echo '```'
}

{
  echo "### OpenSpec ${title}"
  if $failed; then echo "**Result: ❌ failed**"; else echo "**Result: ✅ passed**"; fi
  echo
  for kv in "$@"; do
    label="${kv%%=*}"; value="${kv#*=}"
    echo "- ${label}: ${value:-n/a}"
  done
  if [[ -s "$out/spec-impact.txt" ]]; then
    echo "- **spec impact:** $(paste -sd, "$out/spec-impact.txt" | sed 's/,/, /g')"
  fi
  if [[ -f "$json" ]]; then
    jq -r --arg req "${CLAUDE_MODEL:-}" \
      '"- model: \(.modelUsage // {} | keys | join(", ") | if . == "" then "n/a" else . end)" +
         (if $req != "" then " (requested: \($req))" else "" end),
       "- turns: \(.num_turns // "?"), cost_usd: \(.total_cost_usd // "?"), denials: \(.permission_denials // [] | length)"' \
      "$json" 2>/dev/null
  fi

  if $failed; then
    echo
    echo "#### Why it failed"
    [[ -n "$failed_steps" ]] && echo "- failed step: \`${failed_steps}\`"
    if [[ -n "$reasons" ]]; then
      echo "- reason:"
      echo
      fenced - 40 <<<"$reasons"
    elif [[ -s "$out/build.log" && ", $failed_steps, " == *", check, "* ]]; then
      echo "- reason: \`pnpm build\` or \`pnpm lint\` failed (output below)."
    elif [[ -n "$failed_steps" ]]; then
      echo "- reason: not recorded by a check (setup or tool failure); see the step log."
    fi

    if [[ -f "$json" && "$(jq -r '.is_error // false' "$json" 2>/dev/null)" == true ]]; then
      echo
      echo "**Agent error** (\`is_error\`):"
      echo
      jq -r '.result // "(no message)"' "$json" 2>/dev/null | fenced - 15
    elif [[ -n "$section" && -s "$report" ]]; then
      # $(...) drops trailing blank lines; the sed drops leading ones.
      text="$(awk -v h="## $section" '$0 == h {f=1; next} /^## / {f=0} f' "$report" \
              | grep -v '^VERDICT: ' | sed '/./,$!d')"
      if [[ -n "$text" && ! "$text" =~ ^[Nn]one\.?$ ]]; then
        echo
        echo "**Agent's explanation** (\`## $section\` in \`$stage.md\`):"
        echo
        echo "$text"
      fi
    fi

    if [[ -f "$json" ]]; then
      denials="$(jq -r '.permission_denials // [] | .[] |
        "- `\(.tool_name)`: `\(.tool_input.command // .tool_input.file_path // .tool_input.pattern // (.tool_input | tostring) | gsub("`"; "'"'"'") | .[0:160])`"' \
        "$json" 2>/dev/null)"
      if [[ -n "$denials" ]]; then
        echo
        echo "**Permission denials** (the agent tried these and the CI sandbox refused):"
        echo
        echo "$denials"
      fi
    fi

    if [[ -s "$out/build.log" && ", $failed_steps, " == *", check, "* ]]; then
      echo
      echo "**Last lines of build/lint output:**"
      echo
      tail -n 30 "$out/build.log" | fenced - 30
    fi
  fi
} 2>/dev/null
exit 0
