#!/bin/sh

#Surpresses errors from the shell, disable when debugging
#set -eu

OUTPUT="/tmp/memos.json"

if [ $# -eq 0 ]; then
    jq -n '{
        title: "Memos",
        description: "Search memo code blocks",
        preferences: [
            {
                name: "memo_token",
                title: "Memo Personal Access Token",
                type: "string"
            },
            {
                name: "memo_url",
                title: "Memo API URL",
                type: "string"
            }
        ],
        commands: [
            {
                name: "memo-cmds",
                title: "Memo cmds blocks",
                mode: "filter"
            },
            {
                name: "memo-snippets",
                title: "Memo snippets blocks",
                mode: "filter"
            },
            {
                name: "memos",
                title: "ALL memos",
                mode: "filter"
            },
            {
                name: "run-command",
                title: "execute command",
                mode: "tty",
                exit: "true"
            },
            {
                name: "view-command",
                title: "view command",
                mode: "detail",
                exit: "false"
            }
        ]
    }'
    exit 0
fi

COMMAND=$(echo "$1" | jq -r '.command')
FILTER=$(echo "$1" | jq -r '.command | split("-")[1]' )
if [ "$COMMAND" = "memo-cmds" ]; then
  echo $(date) >> $OUTPUT
  MEMOS=$(~/projects/goscripts/memo/get-memos -tags "${FILTER}")
  echo "Debug: MEMOS output:" >> $OUTPUT
  echo "$FILTER" >> $OUTPUT
  echo "$MEMOS" >> $OUTPUT
  # it seems to fail because get-memos is not fast enough
  #~/projects/goscripts/get-memos | tee ./debug_output.json | jq '{
  echo "$MEMOS" | jq '{
        "items": map({
            "title": .cmd,
            "subtitle": .tags,
            "actions": [{
                "type": "run",
                "title": "Run cmd ",
                "command": "run-command",
                "params": {
                    "exec": .cmd,
                }
                },{
                  "type": "run",
                  "title": "view cmd ",
                  "command": "view-command",
                  "params": {
                      "exec": .cmd,
                  },
            }]
        }),
        "actions": [{
          "title": "Refresh items",
          "type": "reload",
          "exit": "true"
      }]
  }'
  exit 0
fi

if [ "$COMMAND" = "memo-snippets" ]; then
  MEMOS=$(~/projects/goscripts/memo/get-memos -tags "${FILTER}")
  # it seems to fail because get-memos is not fast enough
  #~/projects/goscripts/get-memos | tee ./debug_output.json | jq '{
  echo "$MEMOS" | jq '{
        "items": map({
            "title": .cmd,
            "subtitle": .tags,
            "actions": [{
                  "type": "run",
                  "title": "view cmd ",
                  "command": "view-command",
                  "params": {
                      "exec": .cmd,
                  },
            }]
        }),
        "actions": [{
          "title": "Refresh items",
          "type": "reload",
          "exit": "true"
      }]
  }'
  exit 0
fi


if [ "$COMMAND" = "run-command" ]; then
  CMD=$(echo "$1"| jq -r '.params.exec')
  konsole -e bash -c "$CMD; exec bash"
elif [ "$COMMAND" = "view-command" ]; then
    cmd=$(echo "$1"| jq -r '.params.exec')
    jq -n --arg cmd "$cmd" '{
        "text": $cmd,
        "actions": [{
            title: "Copy to clipboard",
            type: "copy",
            text: $cmd,
            exit: false,
        }],
    }'
fi
