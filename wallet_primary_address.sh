#!/usr/bin/env bash
#
# TEST ONLY
source monero_functions.inc

# get_primary_address $1

bill=$(get_primary_address 28184)
echo ${bill}
