#!/bin/ash
if [ -z "$1" ]; then
    set -- "geth" \
        --datadir "/geth/var" \
        --config "/geth/etc/config.toml"  \
        --diffsync  \
        --syncmode full \
        --persistdiff \
        --enabletrustprotocol \
        --disablesnapprotocol \
        --disablediffprotocol \
        --cache 65536  \
        --rpc.allow-unprotected-txs  \
        --txlookuplimit 0 \
        --pruneancient \
        --ws \
            --ws.addr 0.0.0.0 \
            --ws.api net,web3,eth,txpool \
            --ws.origins '*' \
        --http \
            --http.addr 0.0.0.0 \
            --http.api net,web3,eth,txpool \
            --http.corsdomain '*' \
            --http.vhosts '*'
fi

exec "$@"