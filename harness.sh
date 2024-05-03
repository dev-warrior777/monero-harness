#!/usr/bin/env bash
# Tmux script that sets up an XMR regtest harness.

source monero_functions.inc

SESSION="xmr-harness"

export SHELL=$(which bash)

###############################################################################
# Development
#
export PATH=$PATH:~/monero-x86_64-linux-gnu-v0.18.3.3
myip

################################################################################
# Start
################################################################################

set -ex

export RPC_USER="user"
export RPC_PASS="pass"
export WALLET_PASS=abc

# --listen and --rpclisten ports for alpha and beta nodes.
# The ports are exported for use by create-wallet.sh.
export ALPHA_NODE_PORT="28081"
export ALPHA_NODE_RPC_PORT="38083"
# export BETA_NODE_PORT="38081"
# export BETA_NODE_RPC_PORT="38084"

# ALPHA_WALLET_SEED="sequence atlas unveil summon pebbles tuesday beer rudely snake rockets different fuselage woven tagged bested dented vegan hover rapid fawns obvious muppet randomly seasons randomly"
# ALPHA_MINING_ADDR=""
export ALPHA_WALLET_RPC_PORT="28087"

# Test only address (from Mastering Monero)
MINE_ADDRESS="4BKjy1uVRTPiz4pHyaXXawb82XpzLiowSDd8rEQJGqvN6AD6kWosLQ6VJXW9sghopxXgQSh1RTd54JdvvCRsXiF41xvfeW5"

# BETA_WALLET_SEED=""
BETA_MINING_ADDR=${MINE_ADDRESS}
BETA_WALLET_RPC_PORT="28088"

# WAIT can be used in a send-keys call along with a `wait-for donexmr` command to
# wait for process termination.
WAIT="; tmux wait-for -S donexmr"

NODES_ROOT=~/dextest/xmr
HARNESS_CTL_DIR="$NODES_ROOT/harness-ctl"
ALPHA_DATA_DIR="$NODES_ROOT/alpha"
BETA_DATA_DIR="$NODES_ROOT/beta"
ALPHA_WALLET_DIR="${ALPHA_DATA_DIR}/wallet"
BETA_WALLET_DIR="${BETA_DATA_DIR}/wallet"

if [ -d "${NODES_ROOT}" ]; then
  rm -fR "${NODES_ROOT}"
fi
mkdir -p "${HARNESS_CTL_DIR}"
mkdir -p "${ALPHA_DATA_DIR}"
mkdir -p "${BETA_DATA_DIR}"
mkdir -p "${ALPHA_WALLET_DIR}"
mkdir -p "${BETA_WALLET_DIR}"

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
# tmux send-keys -t $SESSION:0 "cd ${HARNESS_CTL_DIR}" C-m

echo "TODO:"

################################################################################
# monerod nodes
################################################################################

#
# ----------------------- For now we just start a daemon -----------------------
#
# # Start monerod in regtest mode
# monerod \
# 	--detach \
# 	--regtest \
# 	"--data-dir=${DATA_DIR}/monerod" \
# 	"--pidfile=${DATA_DIR}/monerod.pid" \
# 	--fixed-difficulty=1 \
# 	--rpc-bind-ip=127.0.0.1 \
# 	"--rpc-bind-port=${ALPHA_NODE_RPC_PORT}"
# sleep 5

monerod \
--detach \
   --testnet \
   --no-igd \
   --hide-my-port \
   "--data-dir=${ALPHA_DATA_DIR}" \
   "--pidfile=${ALPHA_DATA_DIR}/monerod.pid" \
   --p2p-bind-ip 127.0.0.1 \
   --log-level 0 \
   --add-exclusive-node 127.0.0.1:38081 \
   --fixed-difficulty 1 \
   --disable-rpc-ban
sleep 5

################################################################################
# monero wallets
################################################################################
################################################################################
# Prepare the wallets
################################################################################

echo 'harness done'
