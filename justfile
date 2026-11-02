[positional-arguments]
act workflow *args:
    #!/usr/bin/env bash
    set -euo pipefail
    workflow="$1"
    shift

    message=""
    if [[ "${1:-}" == "skip" ]]; then
        message="[skip ${workflow}]"
        shift
    fi

    event_json=$(jq --arg message "${message}" '.head_commit.message = $message' .github/act-event.json)

    act push -j "${workflow}" --eventpath <(printf '%s\n' "${event_json}") "$@"
