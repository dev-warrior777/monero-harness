
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

function myip() {
	curl http://icanhazip.com
	ip addr | grep inet$IP | \
	cut -d"/" -f 1 | \
	grep -v 127\.0 | \
	grep -v \:\:1 | \
	awk '{$1=$1};1'
}