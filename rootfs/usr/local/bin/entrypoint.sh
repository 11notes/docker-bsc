#!/bin/ash
  CMD="${1}"
  case "${CMD}" in
    init)
      if [ -z "$(ls -A ${APP_ROOT}/var)" ]; then
        log-json info "download latest snapshot from 48club"
        cd ${APP_ROOT}/var
        wget -q -O - $(curl -f -L -s https://github.com/48Club/bsc-snapshots | grep -Eo 'https://snapshots.48.club/geth.pbss.\S+.tar.zst') | zstd -cd | tar -xvf - --strip-components=2
        CMD=""
      else
        log-json error "can't download snapshot, directory [${APP_ROOT}/var] not empty!"
      fi
    ;;

    status)
      geth console --preload ${APP_ROOT}/lib/js/status.js
    ;;
  esac

  if [ -z "${CMD}" ]; then
    log-json info "starting default geth configuration"
    set -- "geth" \
      --datadir "${APP_ROOT}/var" \
      --config "${APP_ROOT}/etc/config.toml"  \
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
      --maxpeers 64 \
      --nat extip:$(curl -sL ip.anon.global) \
      --log.format=json
  fi

  exec "$@"