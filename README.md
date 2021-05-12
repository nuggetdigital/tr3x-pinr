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

then run `./keygen.sh` to generate a fresh ssh key pair and push its public key to ec2

note that the corresponding private key remains in your machine's `~/.ssh`

***

## ops

### `./deploy.sh`

deploys the stack

### `./ssh.sh`

sshs into the instance

### `./destroy.sh`

destroys the stack

***

std `datastore_spec`

```json
{"mounts":[{"mountpoint":"/blocks","path":"blocks","shardFunc":"/repo/flatfs/shard/v1/next-to-last/2","type":"flatfs"},{"mountpoint":"/","path":"datastore","type":"levelds"}],"type":"mount"}
```

custom `datastore_spec`

```json
{"mounts":[{"child":{"type":"s3ds","region":"${AWS::Region}","bucket":"${IpfsDatastoreBucket}","rootDirectory":"data","accessKey":"","secretKey":""},"mountpoint":"/blocks","prefix":"s3.datastore","type":"measure"},{"child":{"type":"s3ds","region":"${AWS::Region}","bucket":"${IpfsDatastoreBucket}","rootDirectory":"meta","accessKey":"","secretKey":""},"mountpoint":"/","prefix":"s3.datastore","type":"measure"}],"type":"mount"}
```

custom ipfs config

```json
{
  "Identity": {
    "PeerID": "12D3KooWNVgg1mAsxNFePKHR3uM77S6vd8nMDkWAWfrVqgejz2b5",
    "PrivKey": "$PRIV_KEY"
  },
  "Datastore": {
    "StorageMax": "10GB",
    "StorageGCWatermark": 90,
    "GCPeriod": "1h",
    "Spec": {
      "mounts": [
        {
          "child": {
            "type": "s3ds",
            "region": "${AWS::Region}",
            "bucket": "${IpfsDatastoreBucket}",
            "rootDirectory": "data",
            "accessKey": "",
            "secretKey": ""
          },
          "mountpoint": "/blocks",
          "prefix": "s3.datastore",
          "type": "measure"
        },
        {
          "child": {
            "type": "s3ds",
            "region": "${AWS::Region}",
            "bucket": "${IpfsDatastoreBucket}",
            "rootDirectory": "meta",
            "accessKey": "",
            "secretKey": ""
          },
          "mountpoint": "/",
          "prefix": "s3.datastore",
          "type": "measure"
        }
      ],
      "type": "mount"
    },
    "HashOnRead": false,
    "BloomFilterSize": 0
  },
  "Addresses": {
    "Swarm": [
      "/ip4/0.0.0.0/tcp/4001",
      "/ip6/::/tcp/4001",
      "/ip4/0.0.0.0/udp/4001/quic",
      "/ip6/::/udp/4001/quic"
    ],
    "Announce": [],
    "NoAnnounce": [
      "/ip4/10.0.0.0/ipcidr/8",
      "/ip4/100.64.0.0/ipcidr/10",
      "/ip4/169.254.0.0/ipcidr/16",
      "/ip4/172.16.0.0/ipcidr/12",
      "/ip4/192.0.0.0/ipcidr/24",
      "/ip4/192.0.0.0/ipcidr/29",
      "/ip4/192.0.0.8/ipcidr/32",
      "/ip4/192.0.0.170/ipcidr/32",
      "/ip4/192.0.0.171/ipcidr/32",
      "/ip4/192.0.2.0/ipcidr/24",
      "/ip4/192.168.0.0/ipcidr/16",
      "/ip4/198.18.0.0/ipcidr/15",
      "/ip4/198.51.100.0/ipcidr/24",
      "/ip4/203.0.113.0/ipcidr/24",
      "/ip4/240.0.0.0/ipcidr/4",
      "/ip6/100::/ipcidr/64",
      "/ip6/2001:2::/ipcidr/48",
      "/ip6/2001:db8::/ipcidr/32",
      "/ip6/fc00::/ipcidr/7",
      "/ip6/fe80::/ipcidr/10"
    ],
    "API": "/ip4/127.0.0.1/tcp/5001",
    "Gateway": "/ip4/127.0.0.1/tcp/8080"
  },
  "Mounts": {
    "IPFS": "/ipfs",
    "IPNS": "/ipns",
    "FuseAllowOther": false
  },
  "Discovery": {
    "MDNS": {
      "Enabled": false,
      "Interval": 10
    }
  },
  "Routing": {
    "Type": "dht"
  },
  "Ipns": {
    "RepublishPeriod": "",
    "RecordLifetime": "",
    "ResolveCacheSize": 128
  },
  "Bootstrap": [
    "/dnsaddr/bootstrap.libp2p.io/p2p/QmNnooDu7bfjPFoTZYxMNLWUQJyrVwtbZg5gBMjTezGAJN",
    "/dnsaddr/bootstrap.libp2p.io/p2p/QmQCU2EcMqAqQPR2i9bChDtGNJchTbq5TbXJJ16u19uLTa",
    "/dnsaddr/bootstrap.libp2p.io/p2p/QmbLHAnMoJPWSCR5Zhtx6BHJX9KiKNN6tpvbUcqanj75Nb",
    "/dnsaddr/bootstrap.libp2p.io/p2p/QmcZf59bWwK5XFi76CZX8cbJ4BhTzzA3gU1ZjYZcYW3dwt",
    "/ip4/104.131.131.82/tcp/4001/p2p/QmaCpDMGvV2BGHeYERUEnRQAwe3N8SzbUtfsmvsqQLuvuJ",
    "/ip4/104.131.131.82/udp/4001/quic/p2p/QmaCpDMGvV2BGHeYERUEnRQAwe3N8SzbUtfsmvsqQLuvuJ"
  ],
  "Gateway": {
    "HTTPHeaders": {
      "Access-Control-Allow-Headers": [
        "X-Requested-With",
        "Range",
        "User-Agent"
      ],
      "Access-Control-Allow-Methods": [
        "GET"
      ],
      "Access-Control-Allow-Origin": [
        "*"
      ]
    },
    "RootRedirect": "",
    "Writable": false,
    "PathPrefixes": [],
    "APICommands": [],
    "NoFetch": false,
    "NoDNSLink": false,
    "PublicGateways": null
  },
  "API": {
    "HTTPHeaders": {}
  },
  "Swarm": {
    "AddrFilters": [
      "/ip4/10.0.0.0/ipcidr/8",
      "/ip4/100.64.0.0/ipcidr/10",
      "/ip4/169.254.0.0/ipcidr/16",
      "/ip4/172.16.0.0/ipcidr/12",
      "/ip4/192.0.0.0/ipcidr/24",
      "/ip4/192.0.0.0/ipcidr/29",
      "/ip4/192.0.0.8/ipcidr/32",
      "/ip4/192.0.0.170/ipcidr/32",
      "/ip4/192.0.0.171/ipcidr/32",
      "/ip4/192.0.2.0/ipcidr/24",
      "/ip4/192.168.0.0/ipcidr/16",
      "/ip4/198.18.0.0/ipcidr/15",
      "/ip4/198.51.100.0/ipcidr/24",
      "/ip4/203.0.113.0/ipcidr/24",
      "/ip4/240.0.0.0/ipcidr/4",
      "/ip6/100::/ipcidr/64",
      "/ip6/2001:2::/ipcidr/48",
      "/ip6/2001:db8::/ipcidr/32",
      "/ip6/fc00::/ipcidr/7",
      "/ip6/fe80::/ipcidr/10"
    ],
    "DisableBandwidthMetrics": false,
    "DisableNatPortMap": true,
    "EnableRelayHop": false,
    "EnableAutoRelay": false,
    "Transports": {
      "Network": {},
      "Security": {},
      "Multiplexers": {}
    },
    "ConnMgr": {
      "Type": "basic",
      "LowWater": 600,
      "HighWater": 900,
      "GracePeriod": "20s"
    }
  },
  "AutoNAT": {},
  "Pubsub": {
    "Router": "",
    "DisableSigning": false
  },
  "Peering": {
    "Peers": null
  },
  "Provider": {
    "Strategy": ""
  },
  "Reprovider": {
    "Interval": "12h",
    "Strategy": "all"
  },
  "Experimental": {
    "FilestoreEnabled": false,
    "UrlstoreEnabled": false,
    "ShardingEnabled": false,
    "GraphsyncEnabled": false,
    "Libp2pStreamMounting": false,
    "P2pHttpProxy": false,
    "StrategicProviding": false
  },
  "Plugins": {
    "Plugins": null
  },
  "Pinning": {
    "RemoteServices": {}
  }
}
```