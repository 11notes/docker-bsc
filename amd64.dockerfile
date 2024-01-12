# :: Util
  FROM alpine as util

  RUN set -ex; \
    apk add --no-cache \
      git; \
    git clone https://github.com/11notes/util.git;

# :: Build
  FROM golang:1.20-alpine3.19 as build
  ENV APP_VERSION=v1.3.7
  ENV CGO_CFLAGS="-O -D__BLST_PORTABLE__"
  ENV CGO_CFLAGS_ALLOW="-O -D__BLST_PORTABLE__"

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
    git checkout ${APP_VERSION};

  # fix security
  RUN set -ex; \    
    sed -i 's#google.golang.org/grpc v1.51.0#google.golang.org/grpc v1.56.3#g' /go/bsc/go.mod; \    
    sed -i 's#github.com/consensys/gnark-crypto v0.10.0#github.com/consensys/gnark-crypto v0.12.0#g' /go/bsc/go.mod; \
    sed -i 's#golang.org/x/net v0.10.0#golang.org/x/net v0.17.0#g' /go/bsc/go.mod; \
    sed -i 's#golang.org/x/crypto v0.12.0#golang.org/x/crypto v0.17.0#g' /go/bsc/go.mod; \
    cd /go/bsc; \
    go mod tidy; \
    make -j $(nproc);

  RUN set -ex; \
    cd /go/bsc; \
    make -j $(nproc);

  RUN set -ex; \
    mkdir -p /go/bsc/mainnet; cd /go/bsc/mainnet; \
    wget https://github.com/bnb-chain/bsc/releases/download/${APP_VERSION}/mainnet.zip; \
    unzip mainnet.zip; \
    rm mainnet.zip;
    
# :: Header
  FROM 11notes/alpine:stable
  ENV APP_ROOT=/geth
  COPY --from=util /util/linux/shell/log-json /usr/local/bin
  COPY --from=build /go/bsc/build/bin/ /usr/local/bin
  COPY --from=build /go/bsc/mainnet/ ${APP_ROOT}/etc

# :: Run
  USER root

  # :: prepare image
    RUN set -ex; \
      mkdir -p ${APP_ROOT}; \
      mkdir -p ${APP_ROOT}/etc; \
      mkdir -p ${APP_ROOT}/var; \
      apk --no-cache add \
        zstd \
        wget \
        tar \
        libstdc++; \
      apk --no-cache upgrade;

  # :: copy root filesystem changes and add execution rights to init scripts
    COPY ./rootfs /
    RUN set -ex; \
      chmod +x -R /usr/local/bin

  # :: change home path for existing user and set correct permission
    RUN set -ex; \
      usermod -d ${APP_ROOT} docker; \
      chown -R 1000:1000 \
        ${APP_ROOT};

# :: Volumes
  VOLUME ["${APP_ROOT}/etc", "${APP_ROOT}/var"]

# :: Monitor
  HEALTHCHECK CMD /usr/local/bin/healthcheck.sh || exit 1

# :: Start
  USER docker
  ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]