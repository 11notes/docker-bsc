#!/bin/ash
if [ -z "$1" ]; then
    set -- "geth" \
        --datadir "/geth/var" \
        --config "/geth/etc/config.toml"  \
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

        "sync")
            BSC_URL="$(curl -f -L -s https://github.com/bnb-chain/bsc-snapshots | grep -Eo 'https?://tf-dex-prod-public-snapshot.s3-accelerate.amazonaws.com\S+?\"' | grep -Eo '[^"]+' | sed -e 's/\&amp;/\&/g')"
            cd /geth/var
            exec wget -q -O - $BSC_URL | tar -I lz4 -xvf - --strip-components=2
        ;;
    esac
fi