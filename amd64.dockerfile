# :: Build
	FROM golang:1.16.10-alpine3.14 as geth
	ENV bscVersion=v1.1.7

    RUN set -ex; \
        apk add --update --no-cache \
			build-base \
            linux-headers \
            make \
            cmake \
            g++ \
            git; \
        git clone https://github.com/binance-chain/bsc.git; \
        cd /go/bsc; \
		git checkout ${bscVersion}; \
        make -j $(nproc);

# :: Header
	FROM alpine:3.14
	COPY --from=geth /go/bsc/build/bin/ /usr/local/bin

# :: Run
	USER root

	# :: prepare
        RUN set -ex; \
            mkdir -p /bsc; \
            mkdir -p /bsc/etc; \
            mkdir -p /bsc/var;

		RUN set -ex; \
			apk add --update --no-cache \
				curl \
				shadow;

		RUN set -ex; \
			addgroup --gid 1000 -S bsc; \
			adduser --uid 1000 -D -S -h /bsc -s /sbin/nologin -G bsc bsc;

    # :: copy root filesystem changes
        COPY ./rootfs /

    # :: docker -u 1000:1000 (no root initiative)
        RUN set -ex; \
            chown -R bsc:bsc \
				/bsc

# :: Volumes
	VOLUME ["/bsc/etc", "/bsc/var"]

# :: Start
	RUN set -ex; chmod +x /usr/local/bin/entrypoint.sh
	USER bsc
	ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
    CMD ["geth"]