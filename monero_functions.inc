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

generate_from_keys() {
	local port="${1:?input a monero wallet port}"
	local wallet_name="${2:?specify wallet name}"
	local address="${3:?specify wallet primary address}"
	local spendkey="${4:-""}" # if no spendkey then a view only wallet will be created
	local viewkey="${5:?specify wallet viewkey}"
	local pass="${6:-""}" # default is no password ""
	if [ "${spendkey}" != "" ]
	then
		params="{\"filename\":\"${wallet_name}\",\"address\":\"${address}\",\"spendkey\":\"${spendkey}\",\"viewkey\":\"${viewkey}\",\"password\":\"${pass}\"}"
	else
		params="{\"filename\":\"${wallet_name}\",\"address\":\"${address}\",\"viewkey\":\"${viewkey}\",\"password\":\"${pass}\"}"
	fi
	monero-rpc-request "${port}" "generate_from_keys" "${params}" | jq '.'
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

close_wallet() {
	echo "TODO:"
}

stop_wallet() {
	echo "TODO:"
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

# Online Tx Creation & Offline Signing

export_outputs() {
	local port="${1:?input a valid wallet rpc port}"
	params="{\"all\":true}"
	monero-rpc-request "${port}" "export_outputs" "${params}" | jq '.'
}

import_outputs() {
	local port="${1:?input a valid wallet rpc port}"
	local outputs_data_hex="${2:?input a valid outputs data hex string}"
	params="{\"outputs_data_hex\":\"${outputs_data_hex}\"}"
	echo "${params}"
	monero-rpc-request "${port}" "import_outputs" "${params}"
}

export_key_images() {
	local port="${1:?input a valid wallet rpc port}"
	params="{\"all\":true}"
	monero-rpc-request "${port}" "export_key_images" "${params}" | jq '.' #TODO: refine jq
}

import_key_images() {
	local port="${1:?input a valid wallet rpc port}"
	local signed_key_images="${2:?input a a set valid  key images}" # json array of signed key images:
	params="{\"signed_key_images\":\"${signed_key_images}\"}"
	monero-rpc-request "${port}" "import_key_images" "${params}"
}

# transfer monero to 1 recipient at their account 0, subaddress-indeces [0] 
# but do not send. Iff it is called for a view only wallet (like watch only)
# an unsigned_txset (unsigned txs) will be returned. This can then be signed
# by the parent full wallet, but offline (i.e. not connected to alpha node).
#
# Note: This is for online unsigned tx creation and offline signing and can
# also be used with a hardware wallet device like trezor. As a consequence not
# only must the offline wallet have no connection to the monerod it can never
# have had any connection to monerod or it is considered a Hot wallet and thus
# is prevented from imorting outputs by the monero code.
# https://github.com/monero-project/monero/issues/9333
#
transfer_no_relay() {
	local port="${1:?input a valid wallet rpc port for a view-only wallet}"
	local amount="${2:?input an amount of monero to send in atomic units 1e12}"
	local address="${3:?input a valid destination wallet address}"
	destinations="[{\"amount\":${amount},\"address\":\"${address}\"}]"
    fixed_params="\"account_index\":0,\"subaddr_indices\":[0],\"priority\":0,\"do_not_relay\":true,\"get_tx_key\":true,\"get_tx_hex\":true,\"get_tx_metadata\":true"
	params="{\"destinations\":[{\"amount\":${amount},\"address\":\"${address}\"}], "${fixed_params}" }"
	echo "${params}"
	monero-rpc-request "${port}" "transfer" "${params}"
}

sign_transfer() {
	local port="${1:?input a valid wallet rpc port}"
	local unsigned_txset="${2:?input an unsigned tx set}"
	params="{\"unsigned_txset\":\"${unsigned_txset}\"}"
	echo "${params}"
	monero-rpc-request "${port}" "sign_transfer" "${params}"
}

