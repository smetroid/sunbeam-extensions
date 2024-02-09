#!/bin/bash

set -eu

if [ $# -eq 0 ]; then
    jq -n '{
        title: "Base64 ",
        description: "Encode or decode base64 clipboard item",
        commands: [
            {
                name: "base64-encode",
                title: "Encode clipboard item",
                mode: "tty"
            },
            {
                name: "base64-decode",
                title: "Decode clipboard item",
                mode: "tty"
            }
        ]
    }'
    exit 0
fi

ITEM=`sunbeam paste`
COMMAND=$(echo "$1" | jq -r '.command')
if [ "$COMMAND" = "base64-encode" ]; then
    echo $ITEM | base64 | sunbeam copy
elif [ "$COMMAND" = "base64-decode" ]; then
    echo $ITEM | base64 -d | sunbeam copy
fi


