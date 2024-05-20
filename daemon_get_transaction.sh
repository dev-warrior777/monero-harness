#!/usr/bin/env bash
#
# TEST ONLY
source monero_functions.inc

# port - daemon port
# tx_hashes - "hash1,hash2,..."
# decode_as_json

get_transactions $1 $2 $3
