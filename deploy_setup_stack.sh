#!/bin/bash

if [[ "$1" != "test" && "$1" != "prod" ]]; then
  echo "\$1 must be either \"test\" or \"prod\"" 1>&2
  exit 1
fi

aws cloudformation deploy \
  --stack-name tr3x-pinr-$1-setup \
  --template-file ./setup_stack.yml \
  --capabilities CAPABILITY_IAM