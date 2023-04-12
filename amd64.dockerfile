# :: Build
	FROM golang:alpine as geth
	ENV checkout=v1.1.22

    RUN set -ex; \
        apk add --update --no-cache \
            curl \
            wget \
            unzip \
			build-base \
            linux-headers \
            make \
            cmake \
            g++ \
            git; \
        git clone https://github.com/bnb-chain/bsc.git; \
        cd /go/bsc; \
		git checkout ${checkout}; \
        make -j $(nproc);

    RUN set -ex; \
        mkdir -p /go/bsc/mainnet; cd /go/bsc/mainnet; \
        wget https://github.com/bnb-chain/bsc/releases/download/${checkout}/mainnet.zip; \
        unzip mainnet.zip; \
        rm mainnet.zip;
        
        

# :: Header
	FROM alpine:latest
	COPY --from=geth /go/bsc/build/bin/ /usr/local/bin
    COPY --from=geth /go/bsc/mainnet/ /geth/etc

# :: Run
	USER root

	# :: prepare
        RUN set -ex; \
            mkdir -p /geth; \
            mkdir -p /geth/etc; \
            mkdir -p /geth/var;

		RUN set -ex; \
			apk add --update --no-cache \
				curl \
				shadow;

		RUN set -ex; \
			addgroup --gid 1000 -S geth; \
			adduser --uid 1000 -D -S -h /geth -s /sbin/nologin -G geth geth;

    # :: copy root filesystem changes
        COPY ./rootfs /

    # :: docker -u 1000:1000 (no root initiative)
        RUN set -ex; \
            chown -R geth:geth \
				/geth

# :: Volumes
	VOLUME ["/geth/etc", "/geth/var"]

# :: Monitor
    RUN set -ex; chmod +x /usr/local/bin/healthcheck.sh
    HEALTHCHECK CMD /usr/local/bin/healthcheck.sh || exit 1

# :: Start
	RUN set -ex; chmod +x /usr/local/bin/entrypoint.sh
	USER geth
	ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]