#!/bin/bash

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
  --capabilities CAPABILITY_NAMED_IAM

change_set="$( \
  aws cloudformation describe-change-set \
    --stack-name $STACK_NAME \
    --change-set-name $CHANGE_SET_NAME \
)"

echo "$change_set"

read -n 1 -p "execute the change set? (y/n) " answer

echo

if [[ "${answer,,}" != "y" ]]; then exit 0; fi

instance="$( \
  jq -r '.Changes[] | select(.ResourceChange.LogicalResourceId == "Instance")' <<< "$change_set" \
)"

instance_replacement="$(jq -r '.ResourceChange.Replacement' <<< "$instance")"

if [[ "$instance_replacement" == "True" ]]; then
  echo "detachin the ebs volume"

  stack="$( \
    aws cloudformation describe-stacks \
      --stack-name $STACK_NAME \
  )"

  volume_id="$( \
    jq -r ".Stacks[] | select(.StackName == \"$STACK_NAME\") | .Outputs[] | select(.OutputKey == \"VolumeId\") | .OutputValue" <<< "$stack" \
  )"

  instance_id="$(jq -r '.ResourceChange.PhysicalResourceId' <<< "$instance")"

  aws ec2 detach-volume \
    --device /dev/xvdh \
    --instance-id $instance_id \
    --volume-id $volume_id
fi

echo "awaitin the change set creation"

aws cloudformation wait change-set-create-complete \
  --stack-name $STACK_NAME \
  --change-set-name $CHANGE_SET_NAME

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

stacks="$(aws cloudformation describe-stacks --stack-name $STACK_NAME)"

bucket_name="$( \
  jq -r ".Stacks[] | select(.StackName == \"$STACK_NAME\") | .Outputs[] | select(.OutputKey == \"BucketName\") | .OutputValue" <<< "$stacks" \
)"

temp_file=$(mktemp)

echo '
<!doctype html>
<html lang=en>
<head>
<meta charset=utf-8>
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>ipfs-pinr</title>
</head>
<body>
<p>
    ██╗██████╗ ███████╗███████╗      ██████╗ ██╗███╗   ██╗██████╗ 
    ██║██╔══██╗██╔════╝██╔════╝      ██╔══██╗██║████╗  ██║██╔══██╗
    ██║██████╔╝█████╗  ███████╗█████╗██████╔╝██║██╔██╗ ██║██████╔╝
    ██║██╔═══╝ ██╔══╝  ╚════██║╚════╝██╔═══╝ ██║██║╚██╗██║██╔══██╗
    ██║██║     ██║     ███████║      ██║     ██║██║ ╚████║██║  ██║
    ╚═╝╚═╝     ╚═╝     ╚══════╝      ╚═╝     ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝
    saucy serverlite ipfs service stashin a s3 datastore 🌍🌒🛸🪐
</p>
</body>
</html>
' > $temp_file

aws s3 cp $temp_file s3://$bucket_name/index.html

rm $temp_file

echo "$STACK_NAME stack deployed"