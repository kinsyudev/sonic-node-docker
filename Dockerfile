FROM golang:1.22 AS builder

RUN apt-get update && apt-get install -y git musl-dev make unzip jq

WORKDIR /go/Sonic

ARG SONIC_VERSION=2.0.1
RUN mkdir /tmp/sonic  \
    && curl https://api.github.com/repos/Fantom-foundation/Sonic/releases/latest | jq '.tarball_url' | xargs wget -qO- | tar xvfz - -C /tmp/sonic  \
    && mv /tmp/sonic/*/* .

ARG GOPROXY
RUN go mod download
RUN make all


FROM golang:1.22

COPY --from=builder /go/Sonic/build/sonicd /usr/local/bin/
COPY --from=builder /go/Sonic/build/sonictool /usr/local/bin/
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENV GOMEMLIMIT=28GiB
ENV RUN_CMD_ARGS="--http --http.addr=0.0.0.0 --ws --ws.addr=0.0.0.0"

EXPOSE 18545 18546 5050 5050/udp

VOLUME /var/sonic

ENTRYPOINT ["/entrypoint.sh"]