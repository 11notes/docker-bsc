#!/bin/ash
if [ "$1" = "geth" ]; then
    if [ ! -d /bsc/var/geth/chaindata ]; then
        echo "init bsc ..."
        geth --datadir "/bsc/var" init /bsc/etc/genesis.json
    fi

    echo "starting bsc ..."
    set -- "$@" --datadir "/bsc/var" --config "/bsc/etc/default.toml" --syncmode fast --diffsync --cache 8000 --rpc.allow-unprotected-txs --txlookuplimit 0 # default from binance git
fi

exec "$@"