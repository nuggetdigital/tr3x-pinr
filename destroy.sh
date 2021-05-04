#!/bin/bash

source ./.env
source ./util.sh

if ! stack_exists $STACK_NAME; then exit 0; fi

read -n 1 -p "destroy the $STACK_NAME stack - are you sure? (y/n) " answer

echo

if [[ "${answer,,}" != "y" ]]; then exit 0; fi

set -eE

echo "destroyin the $STACK_NAME stack..."

aws cloudformation delete-stack --stack-name $STACK_NAME

aws cloudformation wait stack-delete-complete --stack-name $STACK_NAME
