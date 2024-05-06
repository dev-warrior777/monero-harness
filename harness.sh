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
# The ports are exported for use by create-wallet.sh ..maybe
export ALPHA_NODE_PORT="48080"
export ALPHA_NODE_RPC_PORT="48081"
export BETA_NODE_PORT="58180"
export BETA_NODE_RPC_PORT="58181"

ALPHA_NODE="${LOCALHOST}:${ALPHA_NODE_PORT}"
BETA_NODE="${LOCALHOST}:${BETA_NODE_PORT}"

# wallet seeds, ports & mining
ALPHA_WALLET_SEED="sequence atlas unveil summon pebbles tuesday beer rudely snake rockets different fuselage woven tagged bested dented vegan hover rapid fawns obvious muppet randomly seasons randomly"
# ALPHA_MINING_ADDR=""
export ALPHA_WALLET_RPC_PORT="" # change to a valid alpha wallet rpc port
BETA_WALLET_SEED="deftly large tirade gumball android leech sidekick opened iguana voice gels focus poaching itches network espionage much jailed vaults winter oatmeal eleven science siren winter"
export BETA_WALLET_RPC_PORT=""  # change to valid beta wallet rpc port
# Test only address (from Mastering Monero) -- TODO: remove this
MINING_ADDRESS="4BKjy1uVRTPiz4pHyaXXawb82XpzLiowSDd8rEQJGqvN6AD6kWosLQ6VJXW9sghopxXgQSh1RTd54JdvvCRsXiF41xvfeW5"
BETA_MINING_ADDR=${MINING_ADDRESS}

# data
NODES_ROOT=~/dextest/xmr
HARNESS_CTL_DIR="$NODES_ROOT/harness-ctl"
ALPHA_DATA_DIR="$NODES_ROOT/alpha"
ALPHA_REGTEST_CFG="${ALPHA_DATA_DIR}/alpha.conf"
ALPHA_WALLET_DIR="${ALPHA_DATA_DIR}/wallet"
BETA_DATA_DIR="$NODES_ROOT/beta"
BETA_WALLET_DIR="${BETA_DATA_DIR}/wallet"
BETA_REGTEST_CFG="${BETA_DATA_DIR}/beta.conf"

if [ -d "${NODES_ROOT}" ]; then
  rm -fR "${NODES_ROOT}"
fi
mkdir -p "${HARNESS_CTL_DIR}"
mkdir -p "${ALPHA_DATA_DIR}"
mkdir -p "${ALPHA_WALLET_DIR}"
touch    "${ALPHA_REGTEST_CFG}"           # currently empty
mkdir -p "${BETA_DATA_DIR}"
mkdir -p "${BETA_WALLET_DIR}"
touch    "${BETA_REGTEST_CFG}"            # currently empty

# # Background watch mining in window ? by default: 
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
# ------------------------------ Start 2 daemons -------------------------------
#
# --regtest --no-igd --no-zmq --hide-my-port --data-dir node1 --p2p-bind-ip 127.0.0.1 --p2p-bind-port 48080 --rpc-bind-ip 127.0.0.1 --rpc-bind-port 48081 --add-exclusive-node 127.0.0.1:58080
# Start first node (alpha) in private regtest mode
monerod \
 --detach \
 "--pidfile=${ALPHA_DATA_DIR}/monerod.pid" \
   --regtest \
   "--data-dir=${ALPHA_DATA_DIR}" \
   "--config-file=${ALPHA_REGTEST_CFG}" \
   --no-igd \
   --no-zmq \
   --p2p-bind-ip 127.0.0.1 \
   --p2p-bind-port 48080 \
   --rpc-bind-ip 127.0.0.1 \
   --rpc-bind-port 48081 \
   --add-exclusive-node 127.0.0.1:58080 \
   --fixed-difficulty 1 \
   --disable-rpc-ban \
   --log-level 1

sleep 5

#--regtest --no-igd --no-zmq --hide-my-port --data-dir node2 --p2p-bind-ip 127.0.0.1 --p2p-bind-port 58080 --rpc-bind-ip 127.0.0.1 --rpc-bind-port 58081 --add-exclusive-node 127.0.0.1:48080
# Start second node (beta) in private regtest mode - connected to alpha
monerod \
 --detach \
 "--pidfile=${BETA_DATA_DIR}/monerod.pid" \
   --regtest \
   "--data-dir=${BETA_DATA_DIR}" \
   "--config-file=${BETA_REGTEST_CFG}" \
   --no-igd \
   --no-zmq \
   --p2p-bind-ip 127.0.0.1 \
   --p2p-bind-port 58080 \
   --rpc-bind-ip 127.0.0.1 \
   --rpc-bind-port 58081 \
   --add-exclusive-node 127.0.0.1:48080 \
   --fixed-difficulty 1 \
   --disable-rpc-ban \
   --log-level 1

# sleep 5

################################################################################
# monero wallets
################################################################################
################################################################################
# Prepare the wallets
################################################################################

echo 'harness done'
