# Alpine :: Binance Smart Chain
![size](https://img.shields.io/docker/image-size/11notes/bsc/1.3.7?color=0eb305) ![version](https://img.shields.io/docker/v/11notes/bsc?color=eb7a09) ![pulls](https://img.shields.io/docker/pulls/11notes/bsc?color=2b75d6) ![activity](https://img.shields.io/github/commit-activity/m/11notes/docker-bsc?color=c91cb8) ![commit-last](https://img.shields.io/github/last-commit/11notes/docker-bsc?color=c91cb8)

Run Binance Smart Chain based on Alpine Linux. Small, lightweight, secure and fast 🏔️

## Description
With this image you can run your own BSC node. Easy to use, easy to deploy. You can either use the run example below or use the default configuration. Works on any CPU. Includes CVE fixes which the official repo doesn't address.

## Volumes
* **/geth/etc** - Directory of config.toml
* **/geth/var** - Directory of all blockchain data

## Run
```shell
docker run --name bsc \
  -v .../var:/geth/var \
  -d 11notes/bsc:[tag] \
    geth \
      --datadir "/geth/var" \
      --config "/geth/etc/config.toml"  \
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
      --maxpeers 64 \
      --nat extip:$(curl -sL ip.anon.global) \
      --log.format=json
      --metrics \
        --metrics.expensive \
        --metrics.influxdbv2 \
        --metrics.influxdb.endpoint "http://127.0.0.1:8086" \
        --metrics.influxdb.token "**********************************************" \
        --metrics.influxdb.organization "Binance" \
        --metrics.influxdb.bucket "bsc" \
        --metrics.influxdb.tags "host=bsc"
```

## Defaults
| Parameter | Value | Description |
| --- | --- | --- |
| `user` | docker | user docker |
| `uid` | 1000 | user id 1000 |
| `gid` | 1000 | group id 1000 |
| `home` | /geth | home directory of user docker |
| `engine` | pebble | Go supported storage backend |
| `api` | http://${IP}:8545 | HTTP endpoint |
| `api` | http://${IP}:8546 | WS endpoint |

## Environment
| Parameter | Value | Default |
| --- | --- | --- |
| `TZ` | [Time Zone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) | null |

## Parent image
* [11notes/alpine:stable](https://hub.docker.com/r/11notes/alpine)

## Built with (thanks to)
* [Binance Smart Chain (BSC)](https://github.com/bnb-chain/bsc)
* [Alpine Linux](https://alpinelinux.org)

## Tips
* Only use rootless container runtime (podman, rootless docker)
* Don't bind to ports < 1024 (requires root), use NAT/reverse proxy (haproxy, traefik, nginx)
* Increase cache<sup>1</sup> as much as you can (64GB+ recommended)
* Don't kill container, stop gracefully with enough time to sync RAM to disk

## Disclaimers
* <sup>1</sup> There is currently a bug in pebble that you can’t set more than 4GB RAM on an amd64 system. Cache is currently disabled in the active branch.