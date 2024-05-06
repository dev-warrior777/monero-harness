#!/usr/bin/env bash

source monero_functions.inc

echo "---------------------------------"
echo "alpha info"
monero-rpc-request 48081 "get_info" "{}"
echo "---------------------------------"
echo "beta info"
monero-rpc-request 58081 "get_info" "{}"
echo "---------------------------------"