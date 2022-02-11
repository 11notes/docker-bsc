#!/bin/ash
if [ "$1" = "start" ]; then
    echo "starting bsc ..."
    set -- "geth" \
        --datadir "/bsc/var" \
        --config "/bsc/etc/config.toml"  \
        --diffsync  \
        --cache 16384  \
        --rpc.allow-unprotected-txs  \
        --txlookuplimit 0 \
        --ws \
            --ws.addr 0.0.0.0 \
            --ws.api eth,web3 \
            --ws.origins '*'
fi

if [ "$1" = "prune" ]; then
    echo "pruning bsc ..."
    set -- "geth" \
        snapshot \
        prune-block \
        --datadir "/bsc/var" \
        --datadir.ancient "/bsc/var/geth/chaindata/ancient" \
        --block-amount-reserved 9000 \
        --triesInMemory 32 \
        --check-snapshot-with-mpt
fi

exec "$@"