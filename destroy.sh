#!/bin/bash

source ./.env
source ./util.sh

if ! stack_exists $STACK_NAME; then exit 0; fi

read -n 1 -p "destroy the $STACK_NAME stack - are you sure? (y/n) " answer1

echo

if [[ "${answer1,,}" != "y" ]]; then exit 0; fi

read -n 1 -p "should we really delete the ebs volume that is 🏠 to all data? (y/n) " answer2

echo

if [[ "${answer2,,}" != "y" ]]; then 
  aws cloudformation delete-stack --stack-name $STACK_NAME --retain-resources Volume
else
  aws cloudformation delete-stack --stack-name $STACK_NAME
fi

echo "destroyin the $STACK_NAME stack..."

aws cloudformation wait stack-delete-complete --stack-name $STACK_NAME
