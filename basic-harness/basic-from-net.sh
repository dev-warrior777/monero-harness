MONEROD_PORT=18081
#WALLET_PORT=18084
WALLET_PORT=28084

MONERO_BIN_DIR="${HOME}/monero-x86_64-linux-gnu-v0.18.3.3"
DATA_DIR="${PWD}/test-data"
WALLET_DIR="${DATA_DIR}/wallet"

# Test only address (from Mastering Monero)
MINE_ADDRESS="4BKjy1uVRTPiz4pHyaXXawb82XpzLiowSDd8rEQJGqvN6AD6kWosLQ6VJXW9sghopxXgQSh1RTd54JdvvCRsXiF41xvfeW5"

monero-rpc-request() {
	local port="${1:?}"   # can be a monerod or monero-wallet-rpc port
	local method="${2:?}" # RPC method name
	local params="${3:?}" # JSON parameters to method
	curl --http0.9 "http://localhost:${port}/json_rpc" \
		--silent \
		--show-error \
		-d "{\"jsonrpc\":\"2.0\",\"id\":\"0\",\"method\":\"${method}\",\"params\":${params}" \
		-H 'Content-Type: application/json' \
		-w "\n"
}

create-wallet() {
	local port="${1:?Please provide a monero wallet port}"
	local wallet_name="${2:?Please specify wallet name}"
	local params='{"filename":"'"${wallet_name}"'","password":"","language":"English"}'
	monero-rpc-request "${port}" "create_wallet" "${params}"
}

refresh-wallet() {
	local port="${1:?Please provide a monero wallet port}"
	monero-rpc-request "${port}" "refresh" "{}"
}

generate-block() {
	local port="${1:?Please provide monerod port}"
	local params="{\"amount_of_blocks\":1,\"wallet_address\":\"${MINE_ADDRESS}\"}"
	monero-rpc-request "${port}" "generateblocks" "${params}"
}

set -ex

# Kill any previous running instances
pkill --echo --uid "${UID}" --full '/monerod .* --regtest ' || true
pkill --echo --uid "${UID}" --full '/monero-wallet-rpc ' || true
sleep 2

# Start with fresh data/wallet directories
rm -rf "${DATA_DIR}"
mkdir -p "${DATA_DIR}" "${WALLET_DIR}"

# Start monerod in regtest mode
"${MONERO_BIN_DIR}/monerod" \
	--detach \
	--regtest \
	--offline \
	"--data-dir=${DATA_DIR}/monerod" \
	"--pidfile=${DATA_DIR}/monerod.pid" \
	--fixed-difficulty=1 \
	--rpc-bind-ip=127.0.0.1 \
	"--rpc-bind-port=${MONEROD_PORT}"
sleep 5

# Start a wallet client
"${MONERO_BIN_DIR}/monero-wallet-rpc" \
	--detach \
	--rpc-bind-ip 127.0.0.1 \
	--rpc-bind-port "${WALLET_PORT}" \
	--pidfile="${DATA_DIR}/monero-wallet-rpc.pid" \
	--log-file="${DATA_DIR}/monero-wallet-rpc.log" \
	--disable-rpc-login \
	--wallet-dir "${WALLET_DIR}"
sleep 2

create-wallet "${WALLET_PORT}" test-wallet
generate-block "${MONEROD_PORT}"
# Refresh below will generate an error on v0.18.1.1, but worked fine with v0.18.1.0 and earlier.
refresh-wallet "${WALLET_PORT}"

sleep 2
echo 'exiting'
set +x



