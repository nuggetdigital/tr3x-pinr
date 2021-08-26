#!/bin/bash

set -eEu

source ./.secret.env

if [[ "$1" != "test" && "$1" != "prod" ]]; then
  echo "\$1 must be either \"test\" or \"prod\"" 1>&2
  exit 1
fi

stack_name=tr3x-pinr-$1

stack="$(aws cloudformation describe-stacks --stack-name $stack_name)"

public_ip="$( \
  jq -r ".Stacks[] | select(.StackName == \"$stack_name\") | .Outputs[] | select(.OutputKey == \"InstancePublicIp\") | .OutputValue" <<< "$stack" \
)"

ssh -i $HOME/.ssh/$SSH_PRIVATE_KEY_NAME $SSH_USERNAME@$public_ip
