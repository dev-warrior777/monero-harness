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

set -evx

export RPC_USER="user"
export RPC_PASS="pass"
export WALLET_PASS=abc

LOCALHOST="127.0.0.1"

# listen and rpc listen ports for alpha node.
# The ports are exported for use by create-wallet.sh ..maybe
export ALPHA_NODE_PORT="18080"
export ALPHA_NODE_RPC_PORT="18081"

# for multinode - not used for singlenode
ALPHA_NODE="${LOCALHOST}:${ALPHA_NODE_PORT}"

# wallet servers' listen rpc ports
export FRED_WALLET_RPC_PORT="28084"
export BILL_WALLET_RPC_PORT="28184"

# wallet account 0 primary address
FRED_WALLET_PRIMARY_ADDRESS=
BILL_WALLET_PRIMARY_ADDRESS=

# # wallet seeds - unused for now as we make random wallets on start up
# FRED_WALLET_SEED="sequence atlas unveil summon pebbles tuesday beer rudely snake rockets different fuselage woven tagged bested dented vegan hover rapid fawns obvious muppet randomly seasons randomly"
# BILL_WALLET_SEED="deftly large tirade gumball android leech sidekick opened iguana voice gels focus poaching itches network espionage much jailed vaults winter oatmeal eleven science siren winter"

# data
NODES_ROOT=~/dextest/xmr
FRED_WALLET_DIR="${NODES_ROOT}/wallets/fred"
BILL_WALLET_DIR="${NODES_ROOT}/wallets/bill"
HARNESS_CTL_DIR="${NODES_ROOT}/harness-ctl"
ALPHA_DATA_DIR="${NODES_ROOT}/alpha"
ALPHA_REGTEST_CFG="${ALPHA_DATA_DIR}/alpha.conf"

if [ -d "${NODES_ROOT}" ]; then
  rm -fR "${NODES_ROOT}"
fi
mkdir -p "${FRED_WALLET_DIR}"
mkdir -p "${BILL_WALLET_DIR}"
mkdir -p "${HARNESS_CTL_DIR}"
mkdir -p "${ALPHA_DATA_DIR}"
touch    "${ALPHA_REGTEST_CFG}"           # currently empty

# Background watch mining in window ??? by default:
# 'export NOMINER="1"' or uncomment this line to disable
#NOMINER="1"

################################################################################
# Control Scripts
################################################################################
echo "Writing ctl scripts"

echo "TODO:"

# Shutdown script
cat > "${NODES_ROOT}/harness-ctl/quit" <<EOF
#!/usr/bin/env bash
tmux send-keys -t $SESSION:3 C-c
sleep 0.05
tmux send-keys -t $SESSION:2 C-c
sleep 0.05
tmux send-keys -t $SESSION:1 C-c
sleep 0.05
# . . . 
tmux kill-session
EOF
chmod +x "${HARNESS_CTL_DIR}/quit"

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

# WAIT can be used in a send-keys call along with a `wait-for donexmr` command
WAIT="; tmux wait-for -S donexmr"

tmux new-session -d -s $SESSION $SHELL
tmux rename-window -t $SESSION:0 'harness-ctl'
tmux send-keys -t $SESSION:0 "set +o history" C-m
tmux send-keys -t $SESSION:0 "cd ${HARNESS_CTL_DIR}" C-m

################################################################################
# SINGLE NODE
################################################################################

tmux new-window -t $SESSION:1 -n 'alpha' $SHELL
tmux send-keys -t $SESSION:1 "set +o history" C-m
tmux send-keys -t $SESSION:1 "cd ${ALPHA_DATA_DIR}" C-m

# start alpha node
tmux send-keys -t $SESSION:1 "monerod \
   --regtest \
   --offline \
   --data-dir ${ALPHA_DATA_DIR} \
   --config-file ${ALPHA_REGTEST_CFG} \
   --rpc-bind-ip 127.0.0.1 \
   --rpc-bind-port ${ALPHA_NODE_RPC_PORT} \
   --fixed-difficulty 1 \
   --log-level 1; tmux wait-for -S alphaxmr" C-m

sleep 3

################################################################################
# WALLET CLIENTS
################################################################################

tmux new-window -t $SESSION:2 -n 'fred' $SHELL
tmux send-keys -t $SESSION:2 "set +o history" C-m
tmux send-keys -t $SESSION:2 "cd ${FRED_WALLET_DIR}" C-m

# Start the first wallet client
tmux send-keys -t $SESSION:2 "monero-wallet-rpc \
   --rpc-bind-ip 127.0.0.1 \
   --rpc-bind-port ${FRED_WALLET_RPC_PORT} \
   --wallet-dir ${FRED_WALLET_DIR} \
   --disable-rpc-login \
   --allow-mismatched-daemon-version; tmux wait-for -S billxmr" C-m 
sleep 2

tmux new-window -t $SESSION:3 -n 'bill' $SHELL
tmux send-keys -t $SESSION:3 "set +o history" C-m
tmux send-keys -t $SESSION:3 "cd ${BILL_WALLET_DIR}" C-m

# Start the second wallet client
tmux send-keys -t $SESSION:3 "monero-wallet-rpc \
   --rpc-bind-ip 127.0.0.1 \
   --rpc-bind-port ${BILL_WALLET_RPC_PORT} \
   --wallet-dir ${BILL_WALLET_DIR} \
   --disable-rpc-login \
   --allow-mismatched-daemon-version; tmux wait-for -S fredxmr" C-m
sleep 2

tmux send-keys -t $SESSION:0 "cd ${HARNESS_CTL_DIR}" C-m

################################################################################
# Create the wallets
################################################################################

create_wallet ${FRED_WALLET_RPC_PORT} "fred" ""
sleep 3

FRED_WALLET_PRIMARY_ADDRESS=$(get_primary_address ${FRED_WALLET_RPC_PORT})
echo "fred wallet primary address is ${FRED_WALLET_PRIMARY_ADDRESS}"

create_wallet ${BILL_WALLET_RPC_PORT} "bill" ""
sleep 3

BILL_WALLET_PRIMARY_ADDRESS=$(get_primary_address ${BILL_WALLET_RPC_PORT})
echo "bill wallet primary address is ${BILL_WALLET_PRIMARY_ADDRESS}"

# ################################################################################
# # Prepare the wallets
# ################################################################################

generate ${BILL_WALLET_PRIMARY_ADDRESS} ${ALPHA_NODE_RPC_PORT} 120
sleep 7

for money in 10000000000000 18000000000000 5000000000000 7000000000000 1000000000000 15000000000000 3000000000000 25000000000000
do
	transfer_simple ${BILL_WALLET_RPC_PORT} ${money} ${FRED_WALLET_PRIMARY_ADDRESS}
	sleep 1 
done

generate ${BILL_WALLET_PRIMARY_ADDRESS} ${ALPHA_NODE_RPC_PORT} 10
sleep 2

# ... any more?

tmux send-keys -t $SESSION:0 "set -o history" C-m
tmux select-window -t $SESSION:0

tmux attach-session -t $SESSION

echo 'harness set up'
