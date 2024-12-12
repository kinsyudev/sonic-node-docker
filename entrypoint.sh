#!/bin/bash

set -euo pipefail

DATA_DIR=/var/sonic
GENESIS_DIR=/tmp/genesis

if [ ! -d $DATA_DIR/chaindata ]; then
  mkdir $GENESIS_DIR
  cd $GENESIS_DIR
  wget https://genesis.soniclabs.com/sonic-mainnet/genesis/sonic.g
  wget https://genesis.soniclabs.com/sonic-mainnet/genesis/sonic.g.md5
  md5sum --check sonic.g.md5

  sonictool --datadir $DATA_DIR --cache 16000 genesis sonic.g
fi

cmd_args=( $RUN_CMD_ARGS )
sonicd --datadir=/var/sonic ${cmd_args[@]}