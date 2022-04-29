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

    exec "$@"
else
    case $1 in
        "prune")
            echo "pruning bsc ..."
            set -- "geth" \
                snapshot \
                prune-block \
                --datadir "/bsc/var" \
                --datadir.ancient "/bsc/var/geth/chaindata/ancient" \
                --block-amount-reserved 1024

            exec "$@"
        ;;

        "sync")
            echo "sync bsc ..."
            BSC_URL="$(curl -f -L -s https://github.com/bnb-chain/bsc-snapshots | grep -Eo 'https?://tf-dex-prod-public-snapshot.s3-accelerate.amazonaws.com\S+?\"' | grep -Eo '[^"]+' | sed -e 's/\&amp;/\&/g')"
            cd /bsc/var
            exec wget -q -O - $BSC_URL | tar -I lz4 -xvf - --strip-components=2
        ;;
    esac
fi