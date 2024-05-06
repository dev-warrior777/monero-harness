#!/usr/bin/env bash

source monero_functions.inc

port=58081
if [ "$1" != "" ]; then
    port=$1
fi
echo ${port}

# Test only address (from Mastering Monero)
MINE_ADDRESS="4BKjy1uVRTPiz4pHyaXXawb82XpzLiowSDd8rEQJGqvN6AD6kWosLQ6VJXW9sghopxXgQSh1RTd54JdvvCRsXiF41xvfeW5"

params="{\"amount_of_blocks\":1,\"wallet_address\":\"${MINE_ADDRESS}\",\"starting_nonce\": 0}"

echo ${params}

monero-rpc-request "${port}" "generateblocks" "${params}"
