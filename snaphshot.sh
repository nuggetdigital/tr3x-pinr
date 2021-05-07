#!/bin/bash

set -eE

source ./.env

aws rds create-snapshot \
  --description "ipfs data ebs vol snapshot $(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
  --volume-id $VOLUME_ID