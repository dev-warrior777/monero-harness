#!/usr/bin/env bash
# Tmux script that sets up an XMR regtest harness with one node 'alpha' and 3
# wallets 'fred', 'bill' & 'charlie'.

###############################################################################
# Development
################################################################################

export PATH=$PATH:~/monero-x86_64-linux-gnu-v0.18.3.3

export NOMINER="1"

################################################################################
# Monero RPC functions
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
export TX_BUILDER_WALLET_RPC_PORT="28384"
export TX_BUILDER_VIEW_WALLET_RPC_PORT="28484"

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
export CHARLIE_WALLET_VIEWKEY="ff3bef320b8268cef410b78c91f34dfc995c72fcb1b498f7a732d76a42a9e207"

TX_BUILDER_WALLET_SEED="aptitude depth object farming tyrant buzzer afield awakened darted misery urgent water tanks unfit strained omnibus radar furnished hefty yoyo looking titans lukewarm menu buzzer"
export TX_BUILDER_WALLET_NAME="tx_builder"
export TX_BUILDER_WALLET_PASS=""
export TX_BUILDER_WALLET_PRIMARY_ADDRESS="46MdM2AoFHz8wAkRgBvjpBe6zmDaUTXqDEHU7SxpJjvULydszNoHLdn4qzCRjRzmEL3dBStqjFFkb1P31vBbVe5KEDzh6LV"
export TX_BUILDER_WALLET_VIEWKEY="18631cd84ddbcd7fa56a119bd05d303d206d59878dfb5d891bcd7a8773a7f90a"

# txBuilder_view cannot spend outputs but can create unsigned transactions
export TX_BUILDER_VIEW_WALLET_NAME="tx_builder_view"
export TX_BUILDER_WALLET_PRIMARY_ADDRESS="46MdM2AoFHz8wAkRgBvjpBe6zmDaUTXqDEHU7SxpJjvULydszNoHLdn4qzCRjRzmEL3dBStqjFFkb1P31vBbVe5KEDzh6LV"

# data dir
NODES_ROOT=~/dextest/xmr
FRED_WALLET_DIR="${NODES_ROOT}/wallets/fred"
BILL_WALLET_DIR="${NODES_ROOT}/wallets/bill"
CHARLIE_WALLET_DIR="${NODES_ROOT}/wallets/charlie"
TX_BUILDER_WALLET_DIR="${NODES_ROOT}/wallets/tx_builder"
TX_BUILDER_VIEW_WALLET_DIR="${NODES_ROOT}/wallets/tx_builder_view"
HARNESS_CTL_DIR="${NODES_ROOT}/harness-ctl"
ALPHA_DATA_DIR="${NODES_ROOT}/alpha"
ALPHA_REGTEST_CFG="${ALPHA_DATA_DIR}/alpha.conf"

if [ -d "${NODES_ROOT}" ]; then
  rm -fR "${NODES_ROOT}"
fi
mkdir -p "${FRED_WALLET_DIR}"
mkdir -p "${BILL_WALLET_DIR}"
mkdir -p "${CHARLIE_WALLET_DIR}"
mkdir -p "${TX_BUILDER_WALLET_DIR}"
mkdir -p "${TX_BUILDER_VIEW_WALLET_DIR}"
mkdir -p "${HARNESS_CTL_DIR}"
mkdir -p "${ALPHA_DATA_DIR}"
touch    "${ALPHA_REGTEST_CFG}"           # currently empty

# make available from the harness-ctl dir 
cp monero_functions.inc ${HARNESS_CTL_DIR} 

# make golang utis available from the harness-ctl dir
UTILS_SRC_DIR=$(pwd)/cmd/
HEX_DECODE=${UTILS_SRC_DIR}/decode/decode
HEX_ENCODE=${UTILS_SRC_DIR}/encode/encode
if [ "${HEX_DECODE}" == "" ]; then
   echo "please build utils (encode, decode) in ${UTILS_SRC_DIR}"
   exit 1
fi
if [ "${HEX_ENCODE}" == "" ]; then
   echo "please build utils (encode, decode) in ${UTILS_SRC_DIR}"
   exit 1
fi
cp ${HEX_DECODE}  ${HARNESS_CTL_DIR}
cp ${HEX_ENCODE}  ${HARNESS_CTL_DIR}

# Background watch mining in window ??? by default:
# 'export NOMINER="1"' or uncomment this line to disable
#NOMINER="1"

################################################################################
# Control Scripts
################################################################################
echo "Writing ctl scripts"

# Node info
cat > "${HARNESS_CTL_DIR}/alpha_info" <<EOF
#!/usr/bin/env bash
source monero_functions.inc
get_info ${ALPHA_NODE_RPC_PORT}
EOF
chmod +x "${HARNESS_CTL_DIR}/alpha_info"
# -----------------------------------------------------------------------------

# Mine to bill-the-miner
# inputs:
# - number of blocks to mine
cat > "${HARNESS_CTL_DIR}/mine-to-bill" <<EOF
#!/usr/bin/env bash
source monero_functions.inc
generate ${BILL_WALLET_PRIMARY_ADDRESS} ${ALPHA_NODE_RPC_PORT} \$1
sleep 2
EOF
chmod +x "${HARNESS_CTL_DIR}/mine-to-bill"
# -----------------------------------------------------------------------------

# Send funds from fred's primary account address to another address
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
# -----------------------------------------------------------------------------

# Send funds from bill's primary account address to another address
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
# -----------------------------------------------------------------------------

# Send funds from charlie's primary account address to another address
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
# -----------------------------------------------------------------------------

# Get fred's balance from an account
# input
# - account number - defaults to account 0
cat > "${HARNESS_CTL_DIR}/fred_balance" <<EOF
#!/usr/bin/env bash
source monero_functions.inc
get_balance ${FRED_WALLET_RPC_PORT} \$1
EOF
chmod +x "${HARNESS_CTL_DIR}/fred_balance"
# -----------------------------------------------------------------------------

# Get bill's balance from an account
# input
# - account number - defaults to account 0
cat > "${HARNESS_CTL_DIR}/bill_balance" <<EOF
#!/usr/bin/env bash
source monero_functions.inc
get_balance ${BILL_WALLET_RPC_PORT} \$1
EOF
chmod +x "${HARNESS_CTL_DIR}/bill_balance"
# -----------------------------------------------------------------------------

# Get charlie's balance from an account
# input
# - account number - defaults to account 0
cat > "${HARNESS_CTL_DIR}/charlie_balance" <<EOF
#!/usr/bin/env bash
source monero_functions.inc
get_balance ${CHARLIE_WALLET_RPC_PORT} \$1
EOF
chmod +x "${HARNESS_CTL_DIR}/charlie_balance"
# -----------------------------------------------------------------------------

# Export outputs from tx builder view wallet
# output:
# - exported_outputs file
# this will be imported into the cold wallet manually using monero-wallet-cli 
cat > "${HARNESS_CTL_DIR}/bv_export_outputs" <<EOF
#!/usr/bin/env bash
source monero_functions.inc
export_outputs ${TX_BUILDER_VIEW_WALLET_RPC_PORT}
EOF
chmod +x "${HARNESS_CTL_DIR}/bv_export_outputs"

# Import key images to tx builder view wallet
# input:
# - exported_key_images file
#   produced by the cold wallet manually using monero-wallet-cli
cat > "${HARNESS_CTL_DIR}/bv_import_key_images" <<EOF
#!/usr/bin/env bash
source monero_functions.inc
EOF
chmod +x "${HARNESS_CTL_DIR}/bv_import_key_images"

# Prepare an unsigned tx with the builder view wallet
# output:
# - unsigned-monero-tx
# This will be signed by the cold wallet manually using monero-wallet-cli
cat > "${HARNESS_CTL_DIR}/bv_prepare_unsigned_tx" <<EOF
#!/usr/bin/env bash
source monero_functions.inc
EOF
chmod +x "${HARNESS_CTL_DIR}/bv_prepare_unsigned_tx"

# Script to import key images to tx builder view wallet
# input:
# - signed_monero_tx file
#   produced by the cold wallet manually using monero-wallet-cli
cat > "${HARNESS_CTL_DIR}/bv_submit_transfer" <<EOF
#!/usr/bin/env bash
source monero_functions.inc
EOF
chmod +x "${HARNESS_CTL_DIR}/bv_submit_transfer"
# -----------------------------------------------------------------------------

# Shutdown script
cat > "${NODES_ROOT}/harness-ctl/quit" <<EOF
#!/usr/bin/env bash
if [ -z "$NOMINER" ]
then
   tmux send-keys -t $SESSION:7 C-c
fi
sleep 0.05
tmux send-keys -t $SESSION:6 C-c
sleep 0.05
tmux send-keys -t $SESSION:5 C-c
sleep 0.05
tmux send-keys -t $SESSION:4 C-c
sleep 0.05
tmux send-keys -t $SESSION:3 C-c
sleep 0.05
tmux send-keys -t $SESSION:2 C-c
sleep 0.05
tmux send-keys -t $SESSION:1 C-c
sleep 0.05
tmux kill-session
sleep 0.05
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
# WALLET SERVERS
################################################################################

# Start the first wallet server - window 2
echo "starting fred wallet server"

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
echo "starting bill wallet server"

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

# Start the third wallet server - window 4
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

# Start the fourth wallet server - window 5
echo "starting tx_builder wallet client"

tmux new-window -t $SESSION:5 -n 'tx_builder' $SHELL
tmux send-keys -t $SESSION:5 "set +o history" C-m
tmux send-keys -t $SESSION:5 "cd ${TX_BUILDER_WALLET_DIR}" C-m

tmux send-keys -t $SESSION:5 "monero-wallet-rpc \
   --rpc-bind-ip 127.0.0.1 \
   --rpc-bind-port ${TX_BUILDER_WALLET_RPC_PORT} \
   --wallet-dir ${TX_BUILDER_WALLET_DIR} \
   --disable-rpc-login \
   --allow-mismatched-daemon-version; tmux wait-for -S builderxmr" C-m

sleep 2

# Start the fifth wallet server - window 6
echo "starting tx_builder_view wallet client"

tmux new-window -t $SESSION:6 -n 'tx_builder_view' $SHELL
tmux send-keys -t $SESSION:6 "set +o history" C-m
tmux send-keys -t $SESSION:6 "cd ${TX_BUILDER_VIEW_WALLET_DIR}" C-m

tmux send-keys -t $SESSION:6 "monero-wallet-rpc \
   --rpc-bind-ip 127.0.0.1 \
   --rpc-bind-port ${TX_BUILDER_VIEW_WALLET_RPC_PORT} \
   --wallet-dir ${TX_BUILDER_VIEW_WALLET_DIR} \
   --disable-rpc-login \
   --allow-mismatched-daemon-version; tmux wait-for -S builderviewxmr" C-m

sleep 2

################################################################################
# Create the wallets
################################################################################

# from here on we are working in the harness-ctl dir
tmux send-keys -t $SESSION:0 "cd ${HARNESS_CTL_DIR}" C-m

# create_wallet ${TX_BUILDER_WALLET_RPC_PORT} "${TX_BUILDER_WALLET_NAME}"
# sleep 1
# query_key ${TX_BUILDER_WALLET_RPC_PORT} "view_key"
# query_key ${TX_BUILDER_WALLET_RPC_PORT} "mnemonic"
# get_primary_address ${TX_BUILDER_WALLET_RPC_PORT}

# recreate_fred wallet
restore_deterministic_wallet ${FRED_WALLET_RPC_PORT} "${FRED_WALLET_NAME}" "${FRED_WALLET_PASS}" "${FRED_WALLET_SEED}"
sleep 3

# recreate bill wallet
restore_deterministic_wallet ${BILL_WALLET_RPC_PORT} "${BILL_WALLET_NAME}" "${BILL_WALLET_PASS}" "${BILL_WALLET_SEED}"
sleep 3

# recreate charlie wallet
restore_deterministic_wallet ${CHARLIE_WALLET_RPC_PORT} "${CHARLIE_WALLET_NAME}" "${CHARLIE_WALLET_PASS}" "${CHARLIE_WALLET_SEED}"
sleep 3

# recreate tx_builder wallet
restore_deterministic_wallet ${TX_BUILDER_WALLET_RPC_PORT} "${TX_BUILDER_WALLET_NAME}" "${TX_BUILDER_WALLET_PASS}" "${TX_BUILDER_WALLET_SEED}"
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
sleep 5

refresh_wallet ${BILL_WALLET_RPC_PORT} | jq '.'
sleep 1

# bill starts with 180 XMR 144 spendable
get_balance ${BILL_WALLET_RPC_PORT}

# Monero block reward 0.6 XMR on regtest

# transfer some money from bill-the-miner to fred, charlie & tx_builder
for money in 10000000000000 18000000000000 5000000000000 7000000000000 1000000000000 15000000000000 3000000000000 25000000000000
do
	transfer_simple ${BILL_WALLET_RPC_PORT} ${money} ${FRED_WALLET_PRIMARY_ADDRESS}
	sleep 1 
	transfer_simple ${BILL_WALLET_RPC_PORT} ${money} ${CHARLIE_WALLET_PRIMARY_ADDRESS}
	sleep 1 
	transfer_simple ${BILL_WALLET_RPC_PORT} ${money} ${TX_BUILDER_WALLET_PRIMARY_ADDRESS}
	sleep 1 
   generate ${BILL_WALLET_PRIMARY_ADDRESS} ${ALPHA_NODE_RPC_PORT} 1
   sleep 1
done

# generate tx_builder view only wallet for building txs
generate_from_keys ${TX_BUILDER_VIEW_WALLET_RPC_PORT} \
   "${TX_BUILDER_VIEW_WALLET_NAME}" \
   "${TX_BUILDER_WALLET_PRIMARY_ADDRESS}" \
   "" \
   "${TX_BUILDER_WALLET_VIEWKEY}" \
   "${TX_BUILDER_WALLET_PASS}"

refresh_wallet ${FRED_WALLET_RPC_PORT} | jq '.'
sleep 1
refresh_wallet ${BILL_WALLET_RPC_PORT} | jq '.'
sleep 1
refresh_wallet ${CHARLIE_WALLET_RPC_PORT} | jq '.'
sleep 1
refresh_wallet ${TX_BUILDER_WALLET_RPC_PORT} | jq '.'
sleep 1
refresh_wallet ${TX_BUILDER_VIEW_WALLET_RPC_PORT} | jq '.'
sleep 1

# mine 10 more blocks to make all fred's and charlie's money spendable (normal tx needs 10 confirmations)
generate ${BILL_WALLET_PRIMARY_ADDRESS} ${ALPHA_NODE_RPC_PORT} 10
# let all the wallets catch up
sleep 7

# get key images from tx_builder
export_key_images ${TX_BUILDER_WALLET_RPC_PORT}
sleep 1
export_key_images ${TX_BUILDER_WALLET_RPC_PORT}
sleep 1
export_key_images ${TX_BUILDER_WALLET_RPC_PORT}
sleep 1
export_key_images ${TX_BUILDER_WALLET_RPC_PORT}
sleep 1
export_key_images ${TX_BUILDER_WALLET_RPC_PORT}
sleep 1
export_key_images ${TX_BUILDER_WALLET_RPC_PORT}
sleep 1
export_key_images ${TX_BUILDER_WALLET_RPC_PORT}
sleep 1

# now kill tx_builder Hot wallet to enable a cold wallet to be made and used
# offline manually using the monero-wallet-cli tool
stop_wallet ${TX_BUILDER_WALLET_RPC_PORT}
sleep 0.5
tmux send-keys -t $SESSION:5 "echo \"${TX_BUILDER_WALLET_NAME}\" is now offline to enable a Cold wallet" C-m
tmux send-keys -t $SESSION:0 "echo \"${TX_BUILDER_WALLET_NAME}\" is now offline to enable a Cold wallet" C-m

# Watch miner
if [ -z "$NOMINER" ]
then
  tmux new-window -t $SESSION:7 -n "miner" $SHELL
  tmux send-keys -t $SESSION:7 "cd ${NODES_ROOT}/harness-ctl" C-m
  tmux send-keys -t $SESSION:7 "watch -n 15 ./mine-to-bill 1" C-m
fi

# Re-enable history and attach to the control session.
tmux send-keys -t $SESSION:0 "set -o history" C-m
tmux select-window -t $SESSION:0
tmux attach-session -t $SESSION
