#!/bin/bash
set -e

if [ -z $1 ]; then
  echo "Usage: ./password.sh <password>"
  exit 0
fi

output=$(cd scripts; ./password_scriptable.sh $1)
passwordHash=$(echo -e "$output" | grep 'Password hash' | cut -d ' ' -f 3 | tr -d '\r')
passwordSalt=$(echo -e "$output" | grep 'Password salt' | cut -d ' ' -f 3 | tr -d '\r')

jq --null-input \
   --arg passwordHash "$passwordHash" \
   --arg passwordSalt "$passwordSalt" \
   '{"passwordHash": $passwordHash, "passwordSalt": $passwordSalt}'