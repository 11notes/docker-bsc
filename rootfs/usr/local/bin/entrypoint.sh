#!/bin/ash
  if [ -z "${1}" ]; then
    set -- "geth" \
      --datadir "/geth/var" \
      --config "/geth/etc/config.toml"  \
      --diffsync  \
      --syncmode full \
      --cache 65536  \
      --rpc.allow-unprotected-txs  \
      --txlookuplimit 0 \
      --pruneancient \
      --tries-verify-mode local \
      --ws \
        --ws.addr 0.0.0.0 \
        --ws.api net,web3,eth,txpool \
        --ws.origins '*' \
      --http \
        --http.addr 0.0.0.0 \
        --http.api net,web3,eth,txpool \
        --http.corsdomain '*' \
        --http.vhosts '*'
      --log.json
  else
    case "${1}" in
      init)
        cd /geth/var
        set -- "wget" -q -O - $(curl -f -L -s https://github.com/48Club/bsc-snapshots | grep -Eo 'https://snapshots.48.club/geth.full.\S+.tar.zst') | zstd -cd | tar -xvf - --strip-components=2
      ;;
    esac
  fi

  exec "$@"