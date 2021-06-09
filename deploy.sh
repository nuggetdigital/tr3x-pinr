#!/bin/bash

source ./.secret.env
source ./.env
source ./util.sh

stack_exists $STACK_NAME
existed=$?

if [[ $existed -eq 0 ]]; then
  change_set_type=UPDATE
else
  change_set_type=CREATE
fi

set -eE

echo "creatin the change set"

aws cloudformation create-change-set \
  --stack-name $STACK_NAME \
  --change-set-name $CHANGE_SET_NAME \
  --change-set-type $change_set_type \
  --template-body file://stack.yml \
  --parameters \
    ParameterKey=Environment,ParameterValue=${ENVIRONMENT:-test} \
    ParameterKey=Subdomain,ParameterValue=$SUBDOMAIN \
    ParameterKey=HostedZoneId,ParameterValue=$HOSTED_ZONE_ID \
    ParameterKey=ACMCertARN,ParameterValue=$ACM_CERT_ARN \
    ParameterKey=CDNDefaultTTL,ParameterValue=$CDN_DEFAULT_TTL \
    ParameterKey=CDNMaxTTL,ParameterValue=$CDN_MAX_TTL \
    ParameterKey=CDNMinTTL,ParameterValue=$CDN_MIN_TTL \
    ParameterKey=CDNDefaultRootObject,ParameterValue=$CDN_DEFAULT_ROOT_OBJECT \
    ParameterKey=InstanceImage,ParameterValue=$INSTANCE_IMAGE \
    ParameterKey=SSHPublicKeyName,ParameterValue=$SSH_PUBLIC_KEY_NAME \
    ParameterKey=ServiceUsername,ParameterValue=$SSH_USERNAME \
    ParameterKey=IPFSPath,ParameterValue=$IPFS_PATH \
    ParameterKey=IPFSBinaryURL,ParameterValue=$IPFS_BINARY_URL \
    ParameterKey=PRXYBinaryURL,ParameterValue=$PRXY_BINARY_URL \
    ParameterKey=InstanceType,ParameterValue=$INSTANCE_TYPE \
    ParameterKey=TrafficPort,ParameterValue=$TRAFFIC_PORT \
    ParameterKey=PseudoRandomness,ParameterValue=$(tr -dc 'a-f0-9' < /dev/urandom | head -c16) \
  --capabilities CAPABILITY_NAMED_IAM

aws cloudformation wait change-set-create-complete \
  --stack-name $STACK_NAME \
  --change-set-name $CHANGE_SET_NAME

change_set="$( \
  aws cloudformation describe-change-set \
    --stack-name $STACK_NAME \
    --change-set-name $CHANGE_SET_NAME \
)"

echo "$change_set"

read -n 1 -p "execute the change set? (y/n) " answer

echo

if [[ "${answer,,}" != "y" ]]; then exit 0; fi

echo "executin the change set"

aws cloudformation execute-change-set \
  --stack-name $STACK_NAME \
  --change-set-name $CHANGE_SET_NAME

echo "awaitin the stack rollout"

if [[ $existed -eq 0 ]]; then
  aws cloudformation wait stack-update-complete --stack-name $STACK_NAME
else
  aws cloudformation wait stack-create-complete --stack-name $STACK_NAME
fi

echo "$STACK_NAME stack deployed"