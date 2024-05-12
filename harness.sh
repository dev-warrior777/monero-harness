#!/usr/bin/env bash
# Tmux script that sets up an XMR regtest harness with one node 'alpha' and 2
# wallets 'fred' and 'bill'.

###############################################################################
# Development
################################################################################

export PATH=$PATH:~/monero-x86_64-linux-gnu-v0.18.3.3

################################################################################
# Monero functions
################################################################################

source monero_functions.inc

################################################################################
# Start up
################################################################################

set -evx

RPC_USER="user"
RPC_PASS="pass"
WALLET_PASS=abc

LOCALHOST="127.0.0.1"

# p2p listen and rpc listen ports for alpha node
export ALPHA_NODE_PORT="18080"
export ALPHA_NODE_RPC_PORT="18081"

# for multinode - not used for singlenode
export ALPHA_NODE="${LOCALHOST}:${ALPHA_NODE_PORT}"

# wallet servers' listen rpc ports
export FRED_WALLET_RPC_PORT="28084"
export BILL_WALLET_RPC_PORT="28184"
export CHARLIE_WALLET_RPC_PORT="28284"

# wallet seeds, passwords & primary addresses
FRED_WALLET_SEED="vibrate fever timber cuffs hunter terminal dilute losing light because nabbing slower royal brunt gnaw vats fishing tipsy toxic vague oscar fudge mice nasty light"
export FRED_WALLET_NAME="fred"
export FRED_WALLET_PASS=""
export FRED_WALLET_PRIMARY_ADDRESS="494aSG3QY1C4PJf7YyDjFc9n2uAuARWSoGQ3hrgPWXtEjgGrYDn2iUw8WJP5Dzm4GuMkY332N9WfbaKfu5tWM3wk8ZeSEC5"

BILL_WALLET_SEED="zodiac playful artistic friendly ought myriad entrance inroads mural duets enraged furnished tsunami pimple ammo prying january swiftly pulp aunt beer ticket tubes unplugs ammo"
export BILL_WALLET_NAME="bill"
export BILL_WALLET_PASS=""
export BILL_WALLET_PRIMARY_ADDRESS="42xPx5nWhxegefWEzRNoJZWwK7d5ofKoWLG1Gmf8567nJMVR37P1EvqYxqWtfgtYUn8qgSbeAqoLcLKe3seFXV2k5ZSqvQw"

CHARLIE_WALLET_SEED="tilt equip bikini nylon ardent asylum eight vane gyrate venomous dove vortex aztec maul rash lair elope rover lodge neutral lemon eggs mocked mugged equip"
export CHARLIE_WALLET_NAME="charlie"
export CHARLIE_WALLET_PASS=""
export CHARLIE_WALLET_PRIMARY_ADDRESS="453w1dEoNE1HjKzKVpAU14Honzenqs5VKKQWHb7RuNHLa4ekXhXnGhR6RuttNpvjbtDjzy8pTgz5j4ZSsWQqyxSDBVQ4WCk"

# data dir
NODES_ROOT=~/dextest/xmr
FRED_WALLET_DIR="${NODES_ROOT}/wallets/fred"
BILL_WALLET_DIR="${NODES_ROOT}/wallets/bill"
CHARLIE_WALLET_DIR="${NODES_ROOT}/wallets/charlie"
HARNESS_CTL_DIR="${NODES_ROOT}/harness-ctl"
ALPHA_DATA_DIR="${NODES_ROOT}/alpha"
ALPHA_REGTEST_CFG="${ALPHA_DATA_DIR}/alpha.conf"

if [ -d "${NODES_ROOT}" ]; then
  rm -fR "${NODES_ROOT}"
fi
mkdir -p "${FRED_WALLET_DIR}"
mkdir -p "${BILL_WALLET_DIR}"
mkdir -p "${CHARLIE_WALLET_DIR}"
mkdir -p "${HARNESS_CTL_DIR}"
mkdir -p "${ALPHA_DATA_DIR}"
touch    "${ALPHA_REGTEST_CFG}"           # currently empty

# make available from the harness-ctl dir 
cp monero_functions.inc ${HARNESS_CTL_DIR} 

# Background watch mining in window ??? by default:
# 'export NOMINER="1"' or uncomment this line to disable
#NOMINER="1"

################################################################################
# Control Scripts
################################################################################
echo "Writing ctl scripts"

# Node info script
cat > "${HARNESS_CTL_DIR}/alpha_info" <<EOF
#!/usr/bin/env bash
source monero_functions.inc
get_info ${ALPHA_NODE_RPC_PORT}
EOF
chmod +x "${HARNESS_CTL_DIR}/alpha_info"

# Mine script - mine to bill-the-miner
# inputs:
# - number of blocks to mine
cat > "${HARNESS_CTL_DIR}/mine-to-bill" <<EOF
#!/usr/bin/env bash
source monero_functions.inc
generate ${BILL_WALLET_PRIMARY_ADDRESS} ${ALPHA_NODE_RPC_PORT} \$1
sleep 2
EOF
chmod +x "${HARNESS_CTL_DIR}/mine-to-bill"

# Script to send funds from fred's primary account address to another address
# inputs:
# - money in atomic units 1e12
# - recipient monero address
cat > "${HARNESS_CTL_DIR}/fred_transfer_to" <<EOF
#!/usr/bin/env bash
source monero_functions.inc
transfer_simple ${FRED_WALLET_RPC_PORT} \$1 \$2
sleep 0.5
EOF
chmod +x "${HARNESS_CTL_DIR}/fred_transfer_to"

# Script to send funds from bill's primary account address to another address
# inputs:
# - money in atomic units 1e12
# - recipient monero address
cat > "${HARNESS_CTL_DIR}/bill_transfer_to" <<EOF
#!/usr/bin/env bash
source monero_functions.inc
transfer_simple ${BILL_WALLET_RPC_PORT} \$1 \$2
sleep 0.5
EOF
chmod +x "${HARNESS_CTL_DIR}/bill_transfer_to"

# Script to send funds from charlie's primary account address to another address
# inputs:
# - money in atomic units 1e12
# - recipient monero address
cat > "${HARNESS_CTL_DIR}/charlie_transfer_to" <<EOF
#!/usr/bin/env bash
source monero_functions.inc
transfer_simple ${CHARLIE_WALLET_RPC_PORT} \$1 \$2
sleep 0.5
EOF
chmod +x "${HARNESS_CTL_DIR}/charlie_transfer_to"

# Script to get fred's balance from an account
# input
# - account number - defaults to account 0
cat > "${HARNESS_CTL_DIR}/fred_balance" <<EOF
#!/usr/bin/env bash
source monero_functions.inc
get_balance ${FRED_WALLET_RPC_PORT} \$1
EOF
chmod +x "${HARNESS_CTL_DIR}/fred_balance"

# Script to get bill's balance from an account
# input
# - account number - defaults to account 0
cat > "${HARNESS_CTL_DIR}/bill_balance" <<EOF
#!/usr/bin/env bash
source monero_functions.inc
get_balance ${BILL_WALLET_RPC_PORT} \$1
EOF
chmod +x "${HARNESS_CTL_DIR}/bill_balance"

# Script to get charlie's balance from an account
# input
# - account number - defaults to account 0
cat > "${HARNESS_CTL_DIR}/charlie_balance" <<EOF
#!/usr/bin/env bash
source monero_functions.inc
get_balance ${CHARLIE_WALLET_RPC_PORT} \$1
EOF
chmod +x "${HARNESS_CTL_DIR}/charlie_balance"

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

echo "empty config file in ${ALPHA_DATA_DIR}"
echo "TODO: populate; for now we have no passwords and the ports are not random"

################################################################################
# Start tmux harness
################################################################################
echo "Starting harness"

SESSION="xmr-harness"

tmux new-session -d -s $SESSION $SHELL
tmux rename-window -t $SESSION:0 "harness-ctl"
tmux send-keys -t $SESSION:0 "set +o history" C-m
tmux send-keys -t $SESSION:0 "cd ${HARNESS_CTL_DIR}" C-m

################################################################################
# SINGLE NODE
################################################################################

# start alpha node - window 1
echo "starting singlenode alpha"

tmux new-window -t $SESSION:1 -n 'alpha' $SHELL
tmux send-keys -t $SESSION:1 "set +o history" C-m
tmux send-keys -t $SESSION:1 "cd ${ALPHA_DATA_DIR}" C-m

tmux send-keys -t $SESSION:1 "monerod \
   --regtest \
   --offline \
   --data-dir ${ALPHA_DATA_DIR} \
   --config-file ${ALPHA_REGTEST_CFG} \
   --rpc-bind-ip 127.0.0.1 \
   --rpc-bind-port ${ALPHA_NODE_RPC_PORT} \
   --fixed-difficulty 1 \
   --log-level 1; tmux wait-for -S alphaxmr" C-m

sleep 5

get_info ${ALPHA_NODE_RPC_PORT}

################################################################################
# WALLET CLIENTS
################################################################################

# Start the first wallet client - window 2
echo "starting fred wallet client"

tmux new-window -t $SESSION:2 -n 'fred' $SHELL
tmux send-keys -t $SESSION:2 "set +o history" C-m
tmux send-keys -t $SESSION:2 "cd ${FRED_WALLET_DIR}" C-m

tmux send-keys -t $SESSION:2 "monero-wallet-rpc \
   --rpc-bind-ip 127.0.0.1 \
   --rpc-bind-port ${FRED_WALLET_RPC_PORT} \
   --wallet-dir ${FRED_WALLET_DIR} \
   --disable-rpc-login \
   --allow-mismatched-daemon-version; tmux wait-for -S fredxmr" C-m 

sleep 2

# Start the second wallet client - window 3
echo "starting bill wallet client"

tmux new-window -t $SESSION:3 -n 'bill' $SHELL
tmux send-keys -t $SESSION:3 "set +o history" C-m
tmux send-keys -t $SESSION:3 "cd ${BILL_WALLET_DIR}" C-m

tmux send-keys -t $SESSION:3 "monero-wallet-rpc \
   --rpc-bind-ip 127.0.0.1 \
   --rpc-bind-port ${BILL_WALLET_RPC_PORT} \
   --wallet-dir ${BILL_WALLET_DIR} \
   --disable-rpc-login \
   --allow-mismatched-daemon-version; tmux wait-for -S billxmr" C-m

sleep 2

# Start the third wallet client - window 4
echo "starting bill wallet client"

tmux new-window -t $SESSION:4 -n 'charlie' $SHELL
tmux send-keys -t $SESSION:4 "set +o history" C-m
tmux send-keys -t $SESSION:4 "cd ${CHARLIE_WALLET_DIR}" C-m

tmux send-keys -t $SESSION:4 "monero-wallet-rpc \
   --rpc-bind-ip 127.0.0.1 \
   --rpc-bind-port ${CHARLIE_WALLET_RPC_PORT} \
   --wallet-dir ${CHARLIE_WALLET_DIR} \
   --disable-rpc-login \
   --allow-mismatched-daemon-version; tmux wait-for -S charliexmr" C-m

sleep 2

################################################################################
# Create the wallets
################################################################################

# from here on we are working in the harness-ctl dir
tmux send-keys -t $SESSION:0 "cd ${HARNESS_CTL_DIR}" C-m

# recreate_fred wallet
restore_deterministic_wallet ${FRED_WALLET_RPC_PORT} "${FRED_WALLET_NAME}" "${FRED_WALLET_PASS}" "${FRED_WALLET_SEED}"
sleep 3

# recreate bill wallet
restore_deterministic_wallet ${BILL_WALLET_RPC_PORT} "${BILL_WALLET_NAME}" "${BILL_WALLET_PASS}" "${BILL_WALLET_SEED}"
sleep 3

# recreate charlie wallet
restore_deterministic_wallet ${CHARLIE_WALLET_RPC_PORT} "${CHARLIE_WALLET_NAME}" "${CHARLIE_WALLET_PASS}" "${CHARLIE_WALLET_SEED}"
sleep 3

# ################################################################################
# # Prepare the wallets
# ################################################################################

# mine 300 blocks to bill's wallet (60 confirmations needed for coinbase)
generate ${BILL_WALLET_PRIMARY_ADDRESS} ${ALPHA_NODE_RPC_PORT} 60
sleep 2
generate ${BILL_WALLET_PRIMARY_ADDRESS} ${ALPHA_NODE_RPC_PORT} 60
sleep 2
generate ${BILL_WALLET_PRIMARY_ADDRESS} ${ALPHA_NODE_RPC_PORT} 60
sleep 2
generate ${BILL_WALLET_PRIMARY_ADDRESS} ${ALPHA_NODE_RPC_PORT} 60
sleep 2
generate ${BILL_WALLET_PRIMARY_ADDRESS} ${ALPHA_NODE_RPC_PORT} 60
# let bill's wallet catch up - time sensitive: it is abnormal to mine 300 blocks
sleep 7

# bill starts with 180 XMR 144 spendable
get_balance ${BILL_WALLET_RPC_PORT}

# Monero block reward 0.6 XMR on regtest

# transfer some money from bill-the-miner to fred and charlie
for money in 10000000000000 18000000000000 5000000000000 7000000000000 1000000000000 15000000000000 3000000000000 25000000000000
do
	transfer_simple ${BILL_WALLET_RPC_PORT} ${money} ${FRED_WALLET_PRIMARY_ADDRESS}
	sleep 1 
	transfer_simple ${BILL_WALLET_RPC_PORT} ${money} ${CHARLIE_WALLET_PRIMARY_ADDRESS}
	sleep 1 
   generate ${BILL_WALLET_PRIMARY_ADDRESS} ${ALPHA_NODE_RPC_PORT} 1
   sleep 1
done

# mine 10 more blocks to make all fred's and charlie's money spendable (normal tx needs 10 confirmations)
generate ${BILL_WALLET_PRIMARY_ADDRESS} ${ALPHA_NODE_RPC_PORT} 10
# let all the wallets catch up
sleep 7

# Watch miner
if [ -z "$NOMINER" ]
then
  tmux new-window -t $SESSION:5 -n "miner" $SHELL
  tmux send-keys -t $SESSION:5 "cd ${NODES_ROOT}/harness-ctl" C-m
  tmux send-keys -t $SESSION:5 "watch -n 15 ./mine-to-bill 1" C-m
fi

# Re-enable history and attach to the control session.
tmux send-keys -t $SESSION:0 "set -o history" C-m
tmux select-window -t $SESSION:0
tmux attach-session -t $SESSION

echo "harness set up"
