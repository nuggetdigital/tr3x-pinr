#!/bin/bash

set -eE

source ./.env

echo "generating a fresh key pair..."

ssh-keygen -t rsa -m PEM -b 4096 -a 10000 -C $STACK_NAME -f $HOME/.ssh/$SSH_PRIVATE_KEY_NAME

echo "pushing the public key to ec2..."

aws ec2 import-key-pair --key-name $SSH_PRIVATE_KEY_NAME.pub --public-key-material "$(<$HOME/.ssh/$SSH_PRIVATE_KEY_NAME.pub)"

echo "generated public key name: $SSH_PRIVATE_KEY_NAME.pub"
