#!/bin/ash
if [ -z "$1" ]; then
    set -- "geth" \
        --datadir "/geth/var" \
        --config "/geth/etc/config.toml"  \
        --diffsync true  \
        --syncmode full \
        --persistdiff \
        --enabletrustprotocol \
        --disablesnapprotocol \
        --disablediffprotocol \
        --cache 65536  \
        --rpc.allow-unprotected-txs  \
        --txlookuplimit 0 \
        --diffblock 5000 \
        --ws \
            --ws.addr 0.0.0.0 \
            --ws.api net,web3,eth,txpool \
            --ws.origins '*' \
        --http \
            --http.addr 0.0.0.0 \
            --http.api net,web3,eth,txpool \
            --http.corsdomain '*' \
            --http.vhosts '*'

    exec "$@"
else
    case $1 in
        "prune")
            set -- "geth" \
                snapshot \
                prune-state \
                --datadir "/geth/var" \
                --datadir.ancient "/geth/var/geth/chaindata/ancient"

            exec "$@"
        ;;

        *)
            exec "$@"
        ;;
    esac
fi