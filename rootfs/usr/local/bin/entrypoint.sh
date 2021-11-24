#!/bin/ash
if [ "$1" = "geth" ]; then
    if [ ! -d /bsc/var/geth/chaindata ]; then
        echo "init bsc ..."
        geth --datadir "/bsc/var" init /bsc/etc/genesis.json
    fi

    echo "starting bsc ..."
    set -- "$@" --datadir "/bsc/var" --config "/bsc/etc/default.toml" --cache 4096
fi

exec "$@"