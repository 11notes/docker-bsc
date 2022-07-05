#!/bin/ash
if [ -z "$1" ]; then
    set -- "geth" \
        --datadir "/geth/var" \
        --config "/geth/etc/config.toml"  \
        --maxpeers 200 \
        --diffsync  \
        --syncmode=snap \
        --cache 16384  \
        --rpc.allow-unprotected-txs  \
        --txlookuplimit 0 \
        --ws \
            --ws.addr 0.0.0.0 \
            --ws.api eth,net,web3 \
            --ws.origins '*' \
        --http \
            --http.addr 0.0.0.0 \
            --http.api eth,net,web3 \
            --http.corsdomain '*' \
            --http.vhosts '*'

    exec "$@"
else
    case $1 in
        "prune")
            set -- "geth" \
                snapshot \
                prune-block \
                --datadir "/geth/var" \
                --datadir.ancient "/geth/var/geth/chaindata/ancient" \
                --block-amount-reserved 1024

            exec "$@"
        ;;
    esac
fi