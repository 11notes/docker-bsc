# Alpine :: Binance Smart Chain
Run a Binance Smart Chain (BSC) node based on Alpine Linux. Small, lightweight, secure and fast 🏔️

## Volumes
* **/geth/etc** - Directory of config.toml
* **/geth/var** - Directory of all blockchain data

## Run
```shell
docker run --name bsc \
  -v ../geth/etc:/geth/etc \
  -v ../geth/var:/geth/var \
  -d 11notes/bsc:[tag]
```

```shell
# start container with custom configuration
docker run --name bsc \
  -v ../geth/var:/geth/var \
  -d 11notes/bsc:[tag] \
    geth \
      --datadir "/geth/var" \
      --config "/geth/etc/config.toml"  \
      --diffsync  \
      --syncmode full \
      --cache 66560  \
      --rpc.allow-unprotected-txs  \
      --txlookuplimit 0 \
      --pruneancient \
      --tries-verify-mode none \
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
      --nat extip:$(curl -s ifconfig.me) \
      --log.json \
      --metrics \
        --metrics.expensive \
        --metrics.influxdbv2 \
        --metrics.influxdb.endpoint "http://127.0.0.1:8086" \
        --metrics.influxdb.token "**********************************************" \
        --metrics.influxdb.organization "Binance" \
        --metrics.influxdb.bucket "bsc" \
        --metrics.influxdb.tags "host=bsc"

# stop container
docker stop -t 600 bsc
```

## Defaults
| Parameter | Value | Description |
| --- | --- | --- |
| `user` | docker | user docker |
| `uid` | 1000 | user id 1000 |
| `gid` | 1000 | group id 1000 |
| `home` | /geth | home directory of user docker |

## Parent
* [11notes/alpine:stable](https://github.com/11notes/docker-alpine)

## Built with
* [Binance Smart Chain (BSC)](https://github.com/bnb-chain/bsc)
* [Alpine Linux](https://alpinelinux.org)

## Tips
* Increase cache as much as you can (64GB+ recommended)
* Don't kill container, stop gracefully with enough time to sync RAM to disk!
* Don't bind to ports < 1024 (requires root), use NAT/reverse proxy
* [Permanent Stroage](https://github.com/11notes/alpine-docker-netshare) - Module to store permanent container data via NFS/CIFS and more