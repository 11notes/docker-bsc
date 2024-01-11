#!/bin/ash
  if [ -z "${1}" ]; then
    log-json info "starting default geth configuration"
    set -- "geth" \
      --datadir "${APP_ROOT}/var" \
      --config "${APP_ROOT}/etc/config.toml"  \
      --cache 66560  \
      --history.transactions=0 \
      --syncmode=full \
      --tries-verify-mode=local \
      --pruneancient \
      --db.engine=pebble \
      --state.scheme=path \
      --ws \
        --ws.addr 0.0.0.0 \
        --ws.api net,web3,eth,txpool \
        --ws.origins '*' \
      --http \
        --http.addr 0.0.0.0 \
        --http.api net,web3,eth,txpool \
        --http.corsdomain '*' \
        --http.vhosts '*' \
      --log.format=json \
      --nat extip:$(curl -s ip.anon.global)
  else
    case "${1}" in
      init)
        log-json info "download latest snapshot from 48club"
        cd ${APP_ROOT}/var
        wget -q -O - $(curl -f -L -s https://github.com/48Club/bsc-snapshots | grep -Eo 'https://snapshots.48.club/geth.full.\S+.tar.zst') | zstd -cd | tar -xvf - --strip-components=2
      ;;
    esac
  fi

  exec "$@"