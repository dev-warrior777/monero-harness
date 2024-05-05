#!/usr/bin/env bash
# Tmux script that sets up an XMR regtest harness.

source monero_functions.inc

SHELL=$(which bash)
export ${SHELL}

SESSION="xmr-harness"
# WAIT can be used in a send-keys call along with a `wait-for donexmr` command to
# wait for process termination.
WAIT="; tmux wait-for -S donexmr"

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

LOCALHOST="127.0.0.1"

# --listen and --rpclisten ports for alpha and beta nodes.
# The ports are exported for use by create-wallet.sh 
export ALPHA_NODE_PORT="28080"
export ALPHA_NODE_RPC_PORT="28081"
export BETA_NODE_PORT="38080"
export BETA_NODE_RPC_PORT="38081"

ALPHA_NODE="${LOCALHOST}:${ALPHA_NODE_PORT}"
BETA_NODE="${LOCALHOST}:${BETA_NODE_PORT}"

# ALPHA_WALLET_SEED="sequence atlas unveil summon pebbles tuesday beer rudely snake rockets different fuselage woven tagged bested dented vegan hover rapid fawns obvious muppet randomly seasons randomly"
# ALPHA_MINING_ADDR=""
export ALPHA_WALLET_RPC_PORT="" # change to a valid alpha wallet rpc port

# Test only address (from Mastering Monero) -- TODO: remove this
MINE_ADDRESS="4BKjy1uVRTPiz4pHyaXXawb82XpzLiowSDd8rEQJGqvN6AD6kWosLQ6VJXW9sghopxXgQSh1RTd54JdvvCRsXiF41xvfeW5"

# BETA_WALLET_SEED="deftly large tirade gumball android leech sidekick opened iguana voice gels focus poaching itches network espionage much jailed vaults winter oatmeal eleven science siren winter"
BETA_MINING_ADDR=${MINE_ADDRESS} # change to a valid beta wallet address
BETA_WALLET_RPC_PORT=""          # change to valid beta wallet rpc port


NODES_ROOT=~/dextest/xmr
HARNESS_CTL_DIR="$NODES_ROOT/harness-ctl"
ALPHA_DATA_DIR="$NODES_ROOT/alpha"
ALPHA_TESTNET_CFG="${ALPHA_DATA_DIR}/alpha.conf"
ALPHA_WALLET_DIR="${ALPHA_DATA_DIR}/wallet"
BETA_DATA_DIR="$NODES_ROOT/beta"
BETA_WALLET_DIR="${BETA_DATA_DIR}/wallet"
BETA_TESTNET_CFG="${BETA_DATA_DIR}/beta.conf"

if [ -d "${NODES_ROOT}" ]; then
  rm -fR "${NODES_ROOT}"
fi
mkdir -p "${HARNESS_CTL_DIR}"
mkdir -p "${ALPHA_DATA_DIR}"
mkdir -p "${ALPHA_WALLET_DIR}"
touch    "${ALPHA_TESTNET_CFG}"           # currently empty
mkdir -p "${BETA_DATA_DIR}"
mkdir -p "${BETA_WALLET_DIR}"
touch    "${BETA_TESTNET_CFG}"            # currently empty

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

# # Background watch mining in window 777 by default:  
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
# https://github.com/moneroexamples/private-testnet
#
# Start first node (alpha) in private testnet mode
monerod \
--detach \
   --testnet \
   "--config-file=${ALPHA_TESTNET_CFG}" \
   "--data-dir=${ALPHA_DATA_DIR}" \
   "--pidfile=${ALPHA_DATA_DIR}/monerod.pid" \
   --no-igd \
   --hide-my-port \
   --p2p-bind-ip 127.0.0.1 \
   --add-exclusive-node ${BETA_NODE} \
   --fixed-difficulty 1 \
   --disable-rpc-ban \
   --log-level 0

sleep 5

# Start second node (beta) in private testnet mode - connected to alpha
monerod \
--detach \
   --testnet \
   "--config-file=${BETA_TESTNET_CFG}" \
   "--data-dir=${BETA_DATA_DIR}" \
   "--pidfile=${BETA_DATA_DIR}/monerod.pid" \
   --no-igd \
   --hide-my-port  \
   --p2p-bind-port 38080 \
   --rpc-bind-port 38081 \
   --zmq-rpc-bind-port 38082 \
   --p2p-bind-ip 127.0.0.1 \
   --add-exclusive-node ${ALPHA_NODE} \
   --fixed-difficulty 1 \
   --disable-rpc-ban \
   --log-level 0

sleep 5

################################################################################
# monero wallets
################################################################################
################################################################################
# Prepare the wallets
################################################################################

echo 'harness done'
