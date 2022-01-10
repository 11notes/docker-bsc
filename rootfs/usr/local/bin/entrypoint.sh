#!/bin/ash
if [ "$1" = "geth" ]; then
    echo "starting bsc ..."
    set -- "$@" --datadir "/bsc/var" --config "/bsc/etc/config.toml" --diffsync --cache 16384 --rpc.allow-unprotected-txs --txlookuplimit 0
fi

exec "$@"