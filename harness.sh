#!/usr/bin/env bash
# Tmux script that sets up an XMR regtest harness.

source monero_functions.inc

SHELL=$(which bash)
export ${SHELL}

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
export BETA_NODE_PORT="58080"
export BETA_NODE_RPC_PORT="58081"

ALPHA_NODE="${LOCALHOST}:${ALPHA_NODE_PORT}"
BETA_NODE="${LOCALHOST}:${BETA_NODE_PORT}"

# wallet seeds, ports & mining
FRED_WALLET_SEED="sequence atlas unveil summon pebbles tuesday beer rudely snake rockets different fuselage woven tagged bested dented vegan hover rapid fawns obvious muppet randomly seasons randomly"
# ALPHA_MINING_ADDR=""
export FRED_WALLET_RPC_PORT="28884" # change to a valid FRED wallet rpc port
BILL_WALLET_SEED="deftly large tirade gumball android leech sidekick opened iguana voice gels focus poaching itches network espionage much jailed vaults winter oatmeal eleven science siren winter"
export BILL_WALLET_RPC_PORT="28084"  # change to valid BILL wallet rpc port
# Test only address (from Mastering Monero) -- TODO: remove change this for Bill's address
MINING_ADDRESS="4BKjy1uVRTPiz4pHyaXXawb82XpzLiowSDd8rEQJGqvN6AD6kWosLQ6VJXW9sghopxXgQSh1RTd54JdvvCRsXiF41xvfeW5"
BILL_MINING_ADDR=${MINING_ADDRESS}

# data
NODES_ROOT=~/dextest/xmr
WALLETS_DIR="${NODES_ROOT}/wallets"
HARNESS_CTL_DIR="${NODES_ROOT}/harness-ctl"
ALPHA_DATA_DIR="${NODES_ROOT}/alpha"
ALPHA_REGTEST_CFG="${ALPHA_DATA_DIR}/alpha.conf"
BETA_DATA_DIR="$NODES_ROOT/beta"
BETA_REGTEST_CFG="${BETA_DATA_DIR}/beta.conf"

if [ -d "${NODES_ROOT}" ]; then
  rm -fR "${NODES_ROOT}"
fi
mkdir -p "${WALLETS_DIR}"
mkdir -p "${HARNESS_CTL_DIR}"
mkdir -p "${ALPHA_DATA_DIR}"
touch    "${ALPHA_REGTEST_CFG}"           # currently empty
mkdir -p "${BETA_DATA_DIR}"
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
# Start tmux harness
################################################################################
echo "Starting harness"

SESSION="xmr-harness"
# WAIT can be used in a send-keys call along with a `wait-for donexmr` command to
# wait for process termination.
WAIT="; tmux wait-for -S donexmr"

# tmux new-session -d -s $SESSION $SHELL
# tmux rename-window -t $SESSION:0 'harness-ctl'
# tmux send-keys -t $SESSION:0 "set +o history" C-m
# tmux send-keys -t $SESSION:0 "cd ${HARNESS_CTL_DIR}" C-m

echo "TODO:"

################################################################################
# monerod nodes
################################################################################

# TODO: Remove --detach and --pidfile when tmux is up
#
# ------------------------------ Start 2 daemons -------------------------------
#
# why not 3 or more local nodes: https://github.com/monero-project/monero/issues/5683
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
   --hide-my-port \
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
   --hide-my-port \
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

# Start the Fred wallet client
# --detach \
# --pidfile="${WALLETS_DIR}/fred-wallet-rpc.pid" \
monero-wallet-rpc \
  --daemon-address 127.0.0.1:58081 \
	--rpc-bind-ip 127.0.0.1 \
	--rpc-bind-port "${FRED_WALLET_RPC_PORT}" \
	--log-file="${WALLETS_DIR}/fred-wallet-rpc.log" \
	--disable-rpc-login \
  --allow-mismatched-daemon-version \
	--wallet-dir "${WALLETS_DIR}"
sleep 2

################################################################################
# Prepare the wallets
################################################################################

echo 'harness done'
