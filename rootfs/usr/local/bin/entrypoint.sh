if [ "$1" = "geth" ]; then
    echo "starting bsc ..."
    set -- "$@" \
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