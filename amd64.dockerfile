# :: Build
  FROM golang:1.19.12-alpine3.18 as build
  ENV APP_VERSION=v1.2.10

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
  # https://nvd.nist.gov/vuln/detail/CVE-2023-39533
  # https://nvd.nist.gov/vuln/detail/CVE-2020-8565
  # https://nvd.nist.gov/vuln/detail/CVE-2023-3978
  RUN set -ex; \
    sed -i 's#golang.org/x/net v0.7.0#golang.org/x/net v0.13.0#g' /go/bsc/go.mod; \
    sed -i 's#github.com/libp2p/go-libp2p v0.26.2#github.com/libp2p/go-libp2p v0.27.8#g' /go/bsc/go.mod; \
    sed -i 's#k8s.io/client-go v0.18.3#k8s.io/client-go v0.20.0-alpha.2#g' /go/bsc/go.mod; \
    cd /go/bsc; \
    go mod tidy;

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
  COPY --from=build /go/bsc/build/bin/ /usr/local/bin
  COPY --from=build /go/bsc/mainnet/ ${APP_ROOT}/etc

# :: Run
  USER root

  # :: prepare image
    RUN set -ex; \
      mkdir -p ${APP_ROOT}; \
      mkdir -p ${APP_ROOT}/etc; \
      mkdir -p ${APP_ROOT}/var;

  # :: copy root filesystem changes and add execution rights to init scripts
    COPY ./rootfs /
    RUN set -ex; \
      chmod +x -R /usr/local/bin

  # :: change home path for existing user and set correct permission
    RUN set -ex; \
      usermod -d ${APP_ROOT} docker; \
      chown -R 1000:1000 \
        ${APP_ROOT};

  # :: update image
    RUN set -ex; \
      apk --no-cache upgrade;

# :: Volumes
  VOLUME ["${APP_ROOT}/etc", "${APP_ROOT}/var"]

# :: Monitor
  HEALTHCHECK CMD /usr/local/bin/healthcheck.sh || exit 1

# :: Start
  USER docker
  ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]