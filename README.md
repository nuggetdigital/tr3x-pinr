# ipfs-pinr

![gbedem kingdom](./gbedema21.PNG)

***

## setup

deploy the setup stack...

```bash
aws cloudformation deploy \
  --stack-name ipfs-pinr-setup \
  --template-file ./stack_setup.yml \
  --capabilities CAPABILITY_IAM
```

...get the generated access key id and secret access key from the setup stack outputs and add them to a local `.env` with the following contents:

```
AWS_ACCESS_KEY_ID=AKIARQ4PXOL6GEXAMPLE
AWS_SECRET_ACCESS_KEY=FzEXAMPLEUE9v0Xsg04MdaSnyhMJ72pMHEXAMPLE
AWS_DEFAULT_REGION=us-east-1

STACK_NAME=ipfs-pinr
CHANGE_SET_NAME=$STACK_NAME-change-set-$(date +%s)

SSH_USERNAME=ubuntu
SSH_PRIVATE_KEY_NAME=id_rsa_ipfs_pinr
```

then run `./keygen.sh` to generate a fresh ssh key pair and push it to ec2

***

## ops

### `./deploy.sh`

deploys the stack

*to enable `snapshot.sh` grab the `VolumeId` stack output and add it to the `.env` file:*

```
--snip--

VOLUME_ID=vol-07c7b528247418b5f
```

### `./ssh.sh`

sshs into the instance

### `./destroy.sh`

destroys the stack

## api

**gateway docs**

`http://$PUBLIC_IP:8080/ipfs/QmS4ustL54uo8FzR9455qaxZwuMiUhyvMcX9Ba8nUH4uVv`