#!/usr/bin/env bash
#
# TEST ONLY
source monero_functions.inc

get_balance $1 $2

#
# possible
#

# params="{\"account_index\":${account}}" <-- using this in monero-functions.inc
# params="{\"account_index\":${account},\"all_accounts\":true}"
# params="{\"account_index\":${account},\"address_indices\":[0,1,2]}"
