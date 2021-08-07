```nofmt
████████╗██████╗ ██████╗ ██╗  ██╗     ██████╗ ██╗███╗   ██╗██████╗ 
╚══██╔══╝██╔══██╗╚════██╗╚██╗██╔╝     ██╔══██╗██║████╗  ██║██╔══██╗
   ██║   ██████╔╝ █████╔╝ ╚███╔╝█████╗██████╔╝██║██╔██╗ ██║██████╔╝
   ██║   ██╔══██╗ ╚═══██╗ ██╔██╗╚════╝██╔═══╝ ██║██║╚██╗██║██╔══██╗
   ██║   ██║  ██║██████╔╝██╔╝ ██╗     ██║     ██║██║ ╚████║██║  ██║
   ╚═╝   ╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝     ╚═╝     ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝
saucy serverlite ipfs service stashin a s3 datastore 🌍🌒🛸🪐
```

## setup

deploy the setup stack...

```bash
aws cloudformation deploy \
  --stack-name tr3x-pinr-setup \
  --template-file ./stack_setup.yml \
  --capabilities CAPABILITY_IAM
```

...get the generated access key id and secret access key from the setup stack outputs and add them to local `*.env` files with the following contents:

**`.secret.env`**

```
AWS_ACCESS_KEY_ID=AKIARQ4PXOL6GEXAMPLE
AWS_SECRET_ACCESS_KEY=FzEXAMPLEUE9v0Xsg04MdaSnyhMJ72pMHEXAMPLE

SSH_USERNAME=ubuntu
SSH_PRIVATE_KEY_NAME=id_rsa_ipfs_pinr

HOSTED_ZONE_ID=TODO
ACM_CERT_ARN=TODO
```

**`.env`**

```
AWS_DEFAULT_REGION=us-east-1

SUBDOMAIN=TODO
STACK_NAME=tr3x-pinr
CHANGE_SET_BASE_NAME=$STACK_NAME-change-set
CDN_DEFAULT_TTL=604800
CDN_MAX_TTL=31536000
CDN_MIN_TTL=3600
CDN_DEFAULT_ROOT_OBJECT=index.html
INSTANCE_IMAGE=ami-0c3086222d6e0e623 # ubuntu 21.04
SSH_PUBLIC_KEY_NAME=$SSH_PRIVATE_KEY_NAME.pub
IPFS_PATH=/home/$SSH_USERNAME/ipfs
IPFS_BINARY_URL=https://github.com/nuggetdigital/tr3x-pinr/releases/download/v0.8.0/go-ipfs-v0.8.0+dss3-v0.7.0-x86_64-unknown-linux-gnu.gz
PRXY_BINARY_URL=https://github.com/nuggetdigital/tr3x-pinr/releases/download/v0.8.0/tr3x-pinr-prxy-v0.8.0-x86_64-unknown-linux-gnu.gz
INSTANCE_TYPE=t3.nano
TRAFFIC_PORT=5000

GO111MODULE=auto
DSS3_VERSION=v0.7.0

PRXY_FROM_PORT=5000
PRXY_TO_PORT=5001
```

then run `./keygen.sh` to generate a fresh ssh key pair and push its public key to ec2

note that the corresponding private key remains in your machine's `~/.ssh`

## ops

check the code to see what is actually happenin, tldr:

### `./deploy.sh`

deploys the stack

### `./ssh.sh`

sshs into the instance

### `./destroy.sh`

destroys the stack

## docs

dss3 help

https://github.com/ipfs/go-ds-s3/issues/17#issuecomment-521410390

self ipfs 

https://talk.fission.codes/t/a-loosely-written-guide-to-hosting-an-ipfs-node-on-aws/234

http ipfs

https://docs.ipfs.io/reference/http/api/#http-commands