#!/usr/bin/env bash
# Script for creating dcr wallets, dcr harness should be running before executing.
set -e

# The following are required script arguments
TMUX_WIN_ID=$1
NAME=$2
SEED=$3
RPC_PORT=$4
USE_SPV=$5
ENABLE_VOTING=$6

WALLET_DIR="${NODES_ROOT}/${NAME}"
mkdir -p ${WALLET_DIR}

export SHELL=$(which bash)

#
# Progress --------------------------------------------------------------------
#
echo 'done'
