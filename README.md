```nofmt
████████╗██████╗ ██████╗ ██╗  ██╗     ██████╗ ██╗███╗   ██╗██████╗ 
╚══██╔══╝██╔══██╗╚════██╗╚██╗██╔╝     ██╔══██╗██║████╗  ██║██╔══██╗
   ██║   ██████╔╝ █████╔╝ ╚███╔╝█████╗██████╔╝██║██╔██╗ ██║██████╔╝
   ██║   ██╔══██╗ ╚═══██╗ ██╔██╗╚════╝██╔═══╝ ██║██║╚██╗██║██╔══██╗
   ██║   ██║  ██║██████╔╝██╔╝ ██╗     ██║     ██║██║ ╚████║██║  ██║
   ╚═╝   ╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝     ╚═╝     ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝
saucy serverlite ipfs service stashin a s3 datastore 🌍🌒🛸🪐
```

## ops

check the code to see what is actually happenin, tldr:

### `./keygen.sh`

generate a fresh ssh key pair and push its public key to ec2

needs to be run before any deployment

`tr3x-pinr` deployments should ideally run through a pipeline triggered by `git push`

consider all below scripts for debugging measures only

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