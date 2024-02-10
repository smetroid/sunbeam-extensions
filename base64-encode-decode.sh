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
                mode: "detail"
            },
            {
                name: "base64-decode",
                title: "Decode clipboard item",
                mode: "detail"
            }
        ]
    }'
    exit 0
fi

ITEM=`sunbeam paste`
COMMAND=$(echo "$1" | jq -r '.command')
if [ "$COMMAND" = "base64-encode" ]; then
    encode=$(echo $ITEM | base64)
    jq -n --arg encode "$encode" '{
        text: "Base64 Encoding!",
        actions: [{
            title: "Copy to clipboard",
            type: "copy",
            text: $encode,
            exit: true,
        }],
    }'
elif [ "$COMMAND" = "base64-decode" ]; then
    decode=$(echo $ITEM | base64 -d)
    jq -n --arg decode "$decode" '{
        "text": "Base64 Decoding",
        "actions": [{
            title: "Copy to clipboard",
            type: "copy",
            text: $decode,
            exit: true,
        }],
    }'
fi

