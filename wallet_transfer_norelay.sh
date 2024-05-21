#!/usr/bin/env bash
#
# TEST ONLY
source monero_functions.inc


# transfer_no_relay 28084 444000000 "453w1dEoNE1HjKzKVpAU14Honzenqs5VKKQWHb7RuNHLa4ekXhXnGhR6RuttNpvjbtDjzy8pTgz5j4ZSsWQqyxSDBVQ4WCk" 25
transfer_no_relay $1 $2 $3 $4
