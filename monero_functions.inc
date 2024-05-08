#!/usr/bin/env bash

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

create_wallet() {
	local port="${1:?input a monero wallet port}"
	local wallet_name="${2:?specify wallet name}"
	local pass="${3:-""}" # default is no password ""
	params="{\"filename\":\"${wallet_name}\",\"password\":\"${pass}\",\"language\":\"English\"}"
	monero-rpc-request "${port}" "create_wallet" "${params}" | jq '.'
}

get_primary_address() {
	local port="${1:?input a valid wallet rpc port}"
	# account 0, address index 0
	params="{\"account_index\":0,\"address_indices\":[0]}"
	monero-rpc-request "${port}" "get_address" "${params}" | jq -r '.result.address'
}

generate() {
	local mine_addr="${1:?input a valid mining (primary) address}"
	local port="${2:?input a valid daemon rpc port}"
	local num_blocks="${3:-1}"
	params="{\"amount_of_blocks\":${num_blocks},\"wallet_address\":\"${mine_addr}\",\"starting_nonce\": 0}"
	monero-rpc-request "${port}" "generateblocks" "${params}"
}

get_balance() {
	local port="${1:?input a valid wallet rpc port}"
	local account="${2:-0}"
	params="{\"account_index\":${account}}" # no sub-addresses
	monero-rpc-request "${port}" "get_balance" "${params}"
}