# :: Build
  FROM golang:alpine as build
  ENV checkout=v1.1.23

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
  FROM 11notes/alpine:stable
  COPY --from=build /go/bsc/build/bin/ /usr/local/bin
  COPY --from=build /go/bsc/mainnet/ /geth/etc

# :: Run
  USER root

  # :: update image
    RUN set -ex; \
      apk update; \
      apk upgrade;

  # :: prepare image
  RUN set -ex; \
    mkdir -p /geth; \
    mkdir -p /geth/etc; \
    mkdir -p /geth/var;

  # :: copy root filesystem changes and add execution rights to init scripts
    COPY ./rootfs /
    RUN set -ex; \
      chmod +x -R /usr/local/bin

  # :: change home path for existing user and set correct permission
    RUN set -ex; \
      usermod -d /geth docker; \
      chown -R 1000:1000 \
        /geth;

# :: Volumes
  VOLUME ["/geth/etc", "/geth/var"]

# :: Monitor
  HEALTHCHECK CMD /usr/local/bin/healthcheck.sh || exit 1

# :: Start
  USER docker
  ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]