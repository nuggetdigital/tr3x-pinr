```nofmt
████████╗██████╗ ██████╗ ██╗  ██╗     ██████╗ ██╗███╗   ██╗██████╗ 
╚══██╔══╝██╔══██╗╚════██╗╚██╗██╔╝     ██╔══██╗██║████╗  ██║██╔══██╗
   ██║   ██████╔╝ █████╔╝ ╚███╔╝█████╗██████╔╝██║██╔██╗ ██║██████╔╝
   ██║   ██╔══██╗ ╚═══██╗ ██╔██╗╚════╝██╔═══╝ ██║██║╚██╗██║██╔══██╗
   ██║   ██║  ██║██████╔╝██╔╝ ██╗     ██║     ██║██║ ╚████║██║  ██║
   ╚═╝   ╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝     ╚═╝     ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝
saucy serverlite ipfs service stashin a s3 datastore 🌍🌒🛸🪐
```

## auto ops

precompilin' [`go-ipfs`](https://github.com/ipfs/go-ipfs) and [`go-ds-s3`](https://github.com/ipfs/go-ds-s3) into a single binary in a [`bundle`](./.github/workflows/bundle.yml) pipeline

`tr3x-pinr` deployments run thru a [pipeline](./.github/workflows/cd.yml) triggered by `git push` on branches `test` and `main`

## manual ops 

*only available to admins*

require below env vars to be set

```bash
# just example values
STACK_NAME=tr3x-pinr-test-stack
SSH_USERNAME=sshusr
SSH_PRIVATE_KEY_NAME=prikey
```

`SSH_USERNAME` and `SSH_PRIVATE_KEY_NAME` must be set identical to the corresponding repo secrets' values

### `./keygen.sh`

generate a fresh ssh key pair and push its public key to ec2

ℹ️ needs to be run before any deployment

### `./ssh.sh`

sshs into the instance

## docs

dss3 help

https://github.com/ipfs/go-ds-s3/issues/17#issuecomment-521410390

self ipfs 

https://talk.fission.codes/t/a-loosely-written-guide-to-hosting-an-ipfs-node-on-aws/234

http ipfs

https://docs.ipfs.io/reference/http/api/#http-commands