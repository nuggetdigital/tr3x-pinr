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
    Environment=$ENVIRONMENT \
    Subdomain=$SUBDOMAIN \
    HostedZoneId=$HOSTED_ZONE_ID \
    ACMCertARN=$ACM_CERT_ARN \
    CDNDefaultTTL=$CDN_DEFAULT_TTL \
    CDNMaxTTL=$CDN_MAX_TTL \
    CDNMinTTL=$CDN_MIN_TTL \
    CDNDefaultRootObject=$CDN_DEFAULT_ROOT_OBJECT \
    InstanceImage=$INSTANCE_IMAGE \
    SSHPublicKeyName=$SSH_PUBLIC_KEY_NAME \
    ServiceUserName=$SSH_USERNAME \
    IPFSPath=$IPFS_PATH \
    IPFSBinaryURL=$IPFS_BINARY_URL \
    PRXYBinaryURL=$PRXY_BINARY_URL \
    InstanceType=$INSTANCE_TYPE \
    TrafficPort=$TRAFFIC_PORT \
    PseudoRandomness=$(tr -dc 'a-f0-9' < /dev/urandom | head -c16) \
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