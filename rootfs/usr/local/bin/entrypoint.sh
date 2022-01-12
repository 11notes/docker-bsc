#!/bin/ash
if [ "$1" = "geth" ]; then
    echo "starting bsc ..."
    set -- "$@" \
        --datadir "/bsc/var" \
        --config "/bsc/etc/config.toml"  \
        --diffsync  \
        --cache 16384  \
        --rpc.allow-unprotected-txs  \
        --txlookuplimit 0 \
        --http \
            --http.addr 0.0.0.0 \
            --http.api personal,eth,net,web3 \
            --http.corsdomain '*' \
        --ws \
            --ws.addr 0.0.0.0 \
            --ws.api eth,net,web3 \
            --ws.origins '*' \
        --ipcdisable
fi

exec "$@"