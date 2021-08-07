#!/bin/bash

source ./.secret.env
source ./.env
source ./util.sh

change_set_name=$CHANGE_SET_BASE_NAME-$(date +%s)

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
  --change-set-name $change_set_name \
  --change-set-type $change_set_type \
  --template-body file://stack.yml \
  --parameters \
    ParameterKey=Environment,ParameterValue=${ENVIRONMENT:-test} \
    ParameterKey=Domain,ParameterValue=$DOMAIN \
    ParameterKey=HostedZoneId,ParameterValue=$HOSTED_ZONE_ID \
    ParameterKey=CertificateArn,ParameterValue=$CERTIFICATE_ARN \
    ParameterKey=CdnDefaultTtl,ParameterValue=$CDN_DEFAULT_TTL \
    ParameterKey=CdnMaxTtl,ParameterValue=$CDN_MAX_TTL \
    ParameterKey=CdnMinTtl,ParameterValue=$CDN_MIN_TTL \
    ParameterKey=CdnDefaultRootObject,ParameterValue=$CDN_DEFAULT_ROOT_OBJECT \
    ParameterKey=InstanceImage,ParameterValue=$INSTANCE_IMAGE \
    ParameterKey=SshPublicKeyName,ParameterValue=$SSH_PUBLIC_KEY_NAME \
    ParameterKey=ServiceUsername,ParameterValue=$SSH_USERNAME \
    ParameterKey=IpfsPath,ParameterValue=$IPFS_PATH \
    ParameterKey=IpfsBinaryUrl,ParameterValue=$IPFS_BINARY_URL \
    ParameterKey=PrxyBinaryUrl,ParameterValue=$PRXY_BINARY_URL \
    ParameterKey=InstanceType,ParameterValue=$INSTANCE_TYPE \
    ParameterKey=TrafficPort,ParameterValue=$TRAFFIC_PORT \
    ParameterKey=PseudoRandomness,ParameterValue=$(tr -dc 'a-f0-9' < /dev/urandom | head -c16) \
  --capabilities CAPABILITY_NAMED_IAM

aws cloudformation wait change-set-create-complete \
  --stack-name $STACK_NAME \
  --change-set-name $change_set_name

change_set="$( \
  aws cloudformation describe-change-set \
    --stack-name $STACK_NAME \
    --change-set-name $change_set_name \
)"

echo "$change_set"

read -n 1 -p "execute the change set? (y/n) " answer

echo

if [[ "${answer,,}" != "y" ]]; then exit 0; fi

echo "executin the change set"

aws cloudformation execute-change-set \
  --stack-name $STACK_NAME \
  --change-set-name $change_set_name

echo "awaitin the stack rollout"

if [[ $existed -eq 0 ]]; then
  aws cloudformation wait stack-update-complete --stack-name $STACK_NAME
else
  aws cloudformation wait stack-create-complete --stack-name $STACK_NAME
fi

echo "$STACK_NAME stack deployed"