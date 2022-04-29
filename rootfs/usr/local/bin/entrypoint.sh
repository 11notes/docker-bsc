#!/bin/ash
if [ -z "$1" ]; then
    echo "starting bsc ..."
    set -- "geth" \
        --datadir "/bsc/var" \
        --config "/bsc/etc/config.toml"  \
        --diffsync  \
        --syncmode=snap \
        --cache 16384  \
        --rpc.allow-unprotected-txs  \
        --txlookuplimit 0 \
        --ws \
            --ws.addr 0.0.0.0 \
            --ws.api eth,web3 \
            --ws.origins '*' \
        --http \
            --http.addr 0.0.0.0 \
            --http.api eth,web3 \
            --http.corsdomain '*'
fi

if [ "$1" = "prune" ]; then
    echo "pruning bsc ..."
    set -- "geth" \
        snapshot \
        prune-block \
        --datadir "/bsc/var" \
        --datadir.ancient "/bsc/var/geth/chaindata/ancient" \
        --block-amount-reserved 1024
fi

exec "$@"