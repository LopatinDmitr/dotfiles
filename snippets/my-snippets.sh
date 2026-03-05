#!/usr/bin/env bash

SNIPPET_FILE="${HOME}/k8s/snippets.sh"

if [[ ! -f "$SNIPPET_FILE" ]]; then
    echo "No file: $SNIPPET_FILE"
    exit 1
fi

descriptions=()
commands=()

current_description=""

while IFS= read -r line || [ -n "$line" ]; do
    if [[ -z "$line" ]]; then
        continue
    fi

    if [[ $line =~ ^# ]]; then
        current_description="${line/#"# "/}"
        continue
    fi

    if [[ -n "$current_description" ]]; then
        descriptions+=("$current_description")
        commands+=("$line")
        current_description=""
    else
        descriptions+=("$line")
        commands+=("$line")
    fi
done < "$SNIPPET_FILE"

selected=$(printf '%s\n' "${descriptions[@]}" | rofi -dmenu -i -p "Choose your snippet" -fixed-num-lines -lines 50)

if [[ -z "$selected" ]]; then
    exit 0
fi

index=-1
for i in "${!descriptions[@]}"; do
    if [[ "${descriptions[$i]}" == "$selected" ]]; then
        index=$i
        break
    fi
done

if [[ $index -ne -1 ]]; then
    command_to_run="${commands[$index]}"
    xdotool type --delay 0 "$command_to_run"
fi

