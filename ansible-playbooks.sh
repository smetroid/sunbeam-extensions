#!/bin/bash

set -eu

cd ~/projects/ansible_fedora
source .env/bin/activate

if [ $# -eq 0 ]; then
    jq -n '{
        title: "Ansible Playbooks",
        description: "Run ansible_fedora playbooks",
        commands: [
            {
                name: "ansible-options",
                title: "Select OS and Roles",
                mode: "filter"
            },
            {
                name: "run-ansible",
                title: "run ansible playbooks",
                mode: "tty"
            }
        ],
    }'
    exit 0
fi

COMMAND=$(echo "$1" | jq -r '.command')
# to be retrieved from the values playbook
OPTIONS='["linux-all","macos-all","linux-tools","macos-tools","linux-common","macos-common"]'

if [ "$COMMAND" = "ansible-options" ]; then
    echo $OPTIONS | jq '{
            "items": map({
            "title": .,
            "subtitle": (" ... run "+ (. | split("-")[1]) +  " roles on a " + (. | split("-")[0]) + " localhost"),
                "actions": [
                    {
                        "type": "run",
                        "title": ("Run Ansible Playbook for " + .),
                        "command": "run-ansible",
                        "params": {
                            "os": . | split("-")[0],
                            role: . | split("-")[1],
                        }
                    }
                ]
            })
        }'
        exit 0
fi

if [ "$COMMAND" = "run-ansible" ]; then
    OS=$(echo "$1" | jq -r '.params.os')
    ROLE=$(echo "$1" | jq -r '.params.role')

    if [ $ROLE = "all" ]; then
        ansible-playbook -i inventories/localhost/localhost playbook/site.yml -e OS="$OS"
    elif [ -z "$ROLE" ]  && [ -z "$OS" ]; then
        ansible-playbook -i inventories/localhost/localhost playbook/site.yml -t $ROLE -e OS="$OS"
    fi
fi

