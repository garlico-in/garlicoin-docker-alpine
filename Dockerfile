FROM public.ecr.aws/docker/library/alpine:3.17 as build
LABEL maintainer = "jorge@garlicoin.io"

WORKDIR /tmp

RUN apk update
RUN apk upgrade --no-cache
RUN apk add --no-cache ca-certificates
RUN update-ca-certificates
RUN apk add --no-cache --update alpine-sdk
RUN apk add --no-cache autoconf
RUN apk add --no-cache automake
RUN apk add --no-cache bash
RUN apk add --no-cache bison
RUN apk add --no-cache boost-dev
RUN apk add --no-cache build-base
RUN apk add --no-cache cmake
RUN apk add --no-cache curl
RUN apk add --no-cache git
RUN apk add --no-cache libevent-dev
RUN apk add --no-cache libressl
RUN apk add --no-cache libtool
RUN apk add --no-cache linux-headers
RUN apk add --no-cache make
RUN apk add --no-cache pkgconf
RUN apk add --no-cache python3
RUN apk add --no-cache sqlite
RUN apk add --no-cache xz
RUN apk add --no-cache zeromq-dev
RUN apk add --no-cache openssl-dev

RUN git clone https://github.com/GarlicoinOrg/Garlicoin.git garlicoin

WORKDIR /tmp/garlicoin
RUN wget https://raw.githubusercontent.com/bitcoin/bitcoin/master/contrib/install_db4.sh
RUN sh install_db4.sh `pwd`

ENV BDB_PREFIX='/tmp/garlicoin/db4'
RUN ./autogen.sh
RUN ./configure \
    LDFLAGS="-L${BDB_PREFIX}/lib/" \
    CPPFLAGS="-I${BDB_PREFIX}/include/" \
    --disable-tests \
    --disable-bench 

RUN make
RUN make install
RUN strip /usr/local/bin/garlicoin*

FROM public.ecr.aws/docker/library/alpine:3.17

RUN apk add --no-cache \
  boost \
  boost-program_options \
  libevent \
  libzmq \
  openssl \
  bash

COPY --from=build \
  /usr/local/bin/garlicoind \
  /usr/local/bin/

COPY garlicoin.conf /root/

COPY start.sh /root/
RUN chmod +x /root/start.sh

EXPOSE 29000
EXPOSE 42068
EXPOSE 42069

CMD ["bash", "-c", "ls -la && exec /root/start.sh"]