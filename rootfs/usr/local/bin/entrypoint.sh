#!/bin/ash
if [ -z "$1" ]; then
    set -- "geth" \
        --datadir "/geth/var" \
        --config "/geth/etc/config.toml"  \
        --diffsync  \
        --syncmode full \
        --cache 65536  \
        --rpc.allow-unprotected-txs  \
        --txlookuplimit 0 \
        --pruneancient \
        --tries-verify-mode none \
        --ws \
            --ws.addr 0.0.0.0 \
            --ws.api net,web3,eth,txpool \
            --ws.origins '*' \
        --http \
            --http.addr 0.0.0.0 \
            --http.api net,web3,eth,txpool \
            --http.corsdomain '*' \
            --http.vhosts '*'
        --maxpeers 512 \
        --verbosity 1 \
        --log.json
fi

exec "$@"