#!/bin/bash

set -eE

source ./.env

stack="$(aws cloudformation describe-stacks --stack-name $STACK_NAME)"

public_ip="$( \
  jq -r ".Stacks[] | select(.StackName == \"$STACK_NAME\") | .Outputs[] | select(.OutputKey == \"PublicIp\") | .OutputValue" <<< "$stack" \
)"

ssh -i $HOME/.ssh/$SSH_PRIVATE_KEY_NAME $EC2_USERNAME@$public_ip