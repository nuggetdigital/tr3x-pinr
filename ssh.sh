#!/bin/bash

set -eEu

source ./.secret.env
source ./.env

stack="$(aws cloudformation describe-stacks --stack-name $STACK_NAME)"

public_ip="$( \
  jq -r ".Stacks[] | select(.StackName == \"$STACK_NAME\") | .Outputs[] | select(.OutputKey == \"InstancePublicIp\") | .OutputValue" <<< "$stack" \
)"

ssh -i $HOME/.ssh/$SSH_PRIVATE_KEY_NAME $SSH_USERNAME@$public_ip
