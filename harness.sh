#!/usr/bin/env bash
# Tmux script that sets up a regtest harness.

#
# Development
#
export PATH=$PATH:~/monero-x86_64-linux-gnu-v0.18.3.3

################################################################################
# Start
################################################################################

set -ex

SESSION="xmr-harness"
export RPC_USER="user"
export RPC_PASS="pass"
export WALLET_PASS=abc

# --listen and --rpclisten ports for alpha and beta nodes.
# The ports are exported for use by create-wallet.sh.
export ALPHA_NODE_PORT=""
export ALPHA_NODE_RPC_PORT=""
export BETA_NODE_PORT=""
export BETA_NODE_RPC_PORT=""

ALPHA_WALLET_SEED=""
ALPHA_MINING_ADDR=""
export ALPHA_WALLET_RPC_PORT=""

BETA_WALLET_SEED=""
BETA_MINING_ADDR=""
BETA_WALLET_RPC_PORT=""

# WAIT can be used in a send-keys call along with a `wait-for donexmr` command to
# wait for process termination.
WAIT="; tmux wait-for -S donexmr"

export SHELL=$(which bash)

NODES_ROOT=~/dextest/xmr
export NODES_ROOT
DATA_DIR="$NODES_ROOT/data"
export DATA_DIR
WALLET_DIR="${DATA_DIR}/wallet"
export WALLET_DIR

if [ -d "${NODES_ROOT}" ]; then
  rm -fR "${NODES_ROOT}"
fi
mkdir -p "${NODES_ROOT}/alpha"
mkdir -p "${NODES_ROOT}/beta"
mkdir -p "${NODES_ROOT}/harness-ctl"
mkdir -p "${DATA_DIR}"
mkdir -p "${WALLET_DIR}"

# MINE=1
# # Bump sleep up to 3 if we have to mine a lot of blocks, because dcrwallet
# # doesn't always keep up.
# MINE_SLEEP=3
# if [ -f ./harnesschain.tar.gz ]; then
#   echo "Seeding blockchain from compressed file"
#   MINE=0
#   MINE_SLEEP=0.5
#   mkdir -p "${NODES_ROOT}/alpha/data"
#   mkdir -p "${NODES_ROOT}/beta/data"
#   tar -xzf ./harnesschain.tar.gz -C ${NODES_ROOT}/alpha/data
#   cp -r ${NODES_ROOT}/alpha/data/simnet ${NODES_ROOT}/beta/data/simnet
# fi

# # Background watch mining in window 8 by default:  
# # 'export NOMINER="1"' or uncomment this line to disable
# #NOMINER="1"

################################################################################
# Control Scripts
################################################################################
echo "Writing ctl scripts"

echo "TODO:"

################################################################################
# Configuration Files
################################################################################
echo "Writing node config files"

echo "TODO:"

################################################################################
# Start harness
################################################################################
echo "Starting harness"

# tmux new-session -d -s $SESSION $SHELL
# tmux rename-window -t $SESSION:0 'harness-ctl'
# tmux send-keys -t $SESSION:0 "set +o history" C-m
# tmux send-keys -t $SESSION:0 "cd ${NODES_ROOT}/harness-ctl" C-m

echo "TODO:"

################################################################################
# monerod nodes
################################################################################

#
# ----------------------- For now we just start a daemon -----------------------
#



################################################################################
# monero wallets
################################################################################
################################################################################
# Prepare the wallets
################################################################################

echo 'harness done'
