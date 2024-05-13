#!/usr/bin/env bash

# https://www.getmonero.org/resources/developer-guides/wallet-rpc.html

monero-rpc-request() {
	local port="${1:?}"   # can be a monerod or monero-wallet-rpc port
	local method="${2:?}" # RPC method name
	local params="${3:?}" # JSON parameters to method
	curl --http0.9 "http://localhost:${port}/json_rpc" \
		--silent \
		--show-error \
		-d "{\"jsonrpc\":\"2.0\",\"id\":\"0\",\"method\":\"${method}\",\"params\":${params}}" \
		-H 'Content-Type: application/json' \
		-w "\n"
}

# Daemon

# get info for a daemon including height, latest block hash, etc.
get_info() {
	local port="${1:?input a monero daemon port}"
	params="{}"
	monero-rpc-request ${port} "get_info" "${params}"
}

# mine into a mining (primary) address
generate() {
	local mine_addr="${1:?input a valid mining (primary) address}"
	local port="${2:?input a valid daemon rpc port}"
	local num_blocks="${3:-1}"
	params="{\"amount_of_blocks\":${num_blocks},\"wallet_address\":\"${mine_addr}\",\"starting_nonce\": 0}"
	monero-rpc-request "${port}" "generateblocks" "${params}"
}

# Wallets

# recreate a wallet from seed
restore_deterministic_wallet() {
	local port="${1:?input a monero wallet port}"
	local wallet_name="${2:?specify wallet name}"
	local pass="${3:-""}" # default is no password ""
	local seed="${4:?input seed 25 words from English wordlist}"
	params="{\"filename\":\"${wallet_name}\",\"password\":\"${pass}\",\"seed\":\"${seed}\"}"
	monero-rpc-request "${port}" "restore_deterministic_wallet" "${params}" | jq '.'
 }


# create a new nettype mainnet wallet (on the fake regtest network chain)
create_wallet() {
	local port="${1:?input a monero wallet port}"
	local wallet_name="${2:?specify wallet name}"
	local pass="${3:-""}" # default is no password ""
	params="{\"filename\":\"${wallet_name}\",\"password\":\"${pass}\",\"language\":\"English\"}"
	monero-rpc-request "${port}" "create_wallet" "${params}" | jq '.'
}

refresh_wallet() {
	local port="${1:?input a monero wallet port}"
	monero-rpc-request "${port}" "refresh" "{}"
}

# get the primary address of a wallet account 0 address index 0
get_primary_address() {
	local port="${1:?input a valid wallet rpc port}"
	# account 0, address index 0
	params="{\"account_index\":0,\"address_indices\":[0]}"
	monero-rpc-request "${port}" "get_address" "${params}" | jq -r '.result.address'
}

# get simple balance from a wallet account - defaults to account 0
get_balance() {
	local port="${1:?input a valid wallet rpc port}"
	local account="${2:-0}"
	params="{\"account_index\":${account}}" # no sub-addresses
	monero-rpc-request "${port}" "get_balance" "${params}"
}

# get a key from a wallet - key_type is either "view_key" or "mnemonic"
query_key() {
	local port="${1:?input a valid wallet rpc port}"
	local key_type="${2,?input either view_key or mnemonic}"
	params="{\"key_type\":\"${key_type}\"}"
	monero-rpc-request "${port}" "query_key" "${params}"
}

# transfer monero to 1 recipient at their account 0, subaddress-indeces [0]
transfer_simple() {
	local port="${1:?input a valid wallet rpc port}"
	local amount="${2:?input an amount of monero to send in atomic units 1e12}"
	local address="${3:?input a valid destination wallet address}"
	destinations="[{\"amount\":${amount},\"address\":\"${address}\"}]"
    fixed_params="\"account_index\":0,\"subaddr_indices\":[0],\"priority\":0,\"ring_size\":7,\"get_tx_key\": true"
	params="{\"destinations\":[{\"amount\":${amount},\"address\":\"${address}\"}], "${fixed_params}" }"
	echo "${params}"
	monero-rpc-request "${port}" "transfer" "${params}"
}

# transfer monero to 1 recipient at their account 0, subaddress-indeces [0] 
# but do not send.
# 
transfer_no_relay() {
	local port="${1:?input a valid wallet rpc port}"
	local amount="${2:?input an amount of monero to send in atomic units 1e12}"
	local address="${3:?input a valid destination wallet address}"
	destinations="[{\"amount\":${amount},\"address\":\"${address}\"}]"
    fixed_params="\"account_index\":0,\"subaddr_indices\":[0],\"priority\":0,\"do_not_relay\":true,\"get_tx_key\": true"
	params="{\"destinations\":[{\"amount\":${amount},\"address\":\"${address}\"}], "${fixed_params}" }"
	echo "${params}"
	monero-rpc-request "${port}" "transfer" "${params}"
}
