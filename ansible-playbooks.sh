#!/bin/bash

set -eu

cd ~/projects/ansible_fedora
source .env/bin/activate

if [ $# -eq 0 ]; then
    jq -n '{
        title: "Ansible",
        description: "Run ansible_fedora playbooks",
        commands: [
            {
                name: "all",
                title: "run all roles",
                mode: "tty",
                params: [
                    {
                        name: "OS",
                        title: "Linux or MacOs",
                        type: "string"
                    }
                ]
            },
            {
                name: "common",
                title: "common role",
                mode: "tty",
                params: [
                    {
                        name: "OS",
                        title: "Linux or MacOS",
                        type: "string"
                    }
                ]
            },
            {
                name: "tools",
                title: "tools role",
                mode: "tty",
                params: [
                    {
                        name: "OS",
                        title: "Linux or MacOS",
                        type: "string"
                    }
                ]
            }
        ],
    }'
    exit 0
fi

ITEM=`sunbeam paste`
COMMAND=$(echo "$1" | jq -r '.command')
OS=$(echo "$1" | jq -r '.params.OS')
if [ "$COMMAND" = "tools" ]; then
    ansible-playbook -i inventories/localhost/localhost playbook/site.yml -t $COMMAND -e OS="$OS"
elif [ "$COMMAND" = "common" ]; then
    ansible-playbook -i inventories/localhost/localhost playbook/site.yml -t $COMMAND -K -e OS="$OS"
elif [ "$COMMAND" = "all" ]; then
    ansible-playbook -i inventories/localhost/localhost playbook/site.yml -t tools,common -K -e OS="$OS"
fi

