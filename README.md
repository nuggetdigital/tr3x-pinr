```nofmt
██╗██████╗ ███████╗███████╗      ██████╗ ██╗███╗   ██╗██████╗ 
██║██╔══██╗██╔════╝██╔════╝      ██╔══██╗██║████╗  ██║██╔══██╗
██║██████╔╝█████╗  ███████╗█████╗██████╔╝██║██╔██╗ ██║██████╔╝
██║██╔═══╝ ██╔══╝  ╚════██║╚════╝██╔═══╝ ██║██║╚██╗██║██╔══██╗
██║██║     ██║     ███████║      ██║     ██║██║ ╚████║██║  ██║
╚═╝╚═╝     ╚═╝     ╚══════╝      ╚═╝     ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝
saucy serverlite ipfs service stashin a s3 datastore 🌍🌒🛸🪐
```

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