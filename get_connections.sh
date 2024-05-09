#!/usr/bin/env bash
#
# TEST ONLY - only useful for multinode
source monero_functions.inc

echo "---------------------------------"
echo "alpha connections"
monero-rpc-request 18081 "get_connections" "{}"
echo "---------------------------------"
