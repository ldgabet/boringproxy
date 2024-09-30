FROM golang:1.17-alpine3.15 as builder
LABEL boringproxy=builder

ARG VERSION
ARG GOOS="linux"
ARG GOARCH="amd64"
ARG BRANCH="master"
ARG REPO="https://github.com/boringproxy/boringproxy.git"
ARG ORIGIN='local'

WORKDIR /build

RUN apk add git

RUN if [[ "ORIGIN" == 'remote' ]] ; then git clone --depth 1 --branch "${BRANCH}" ${REPO}; fi

COPY go.* ./
RUN go mod download
COPY . .

RUN cd cmd/boringproxy && CGO_ENABLED=0 GOOS=${GOOS} GOARCH=${GOARCH} \
	go build -ldflags "-X main.Version=${VERSION}" \
	-o boringproxy

FROM ubuntu:24.04
WORKDIR /storage

COPY --from=builder /build/cmd/boringproxy/boringproxy /usr/sbin/

RUN apt-get update \
	 && apt-get install --no-install-recommends --yes \
	 dropbear \
	 # To clean after install
	 && apt-get clean \
	 && rm -rf /var/lib/apt/lists/*

# COPY docker/server/run/dropbear.sh /dropbear.sh
# RUN /bin/sh /dropbear.sh

# Copier le script d'initialisation
COPY docker/server/run/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Définir le point d'entrée
ENTRYPOINT ["/entrypoint.sh"]

# RUN mkdir -p /root/.ssh && \
#     touch /root/.ssh/authorized_keys

EXPOSE 80 443 22

CMD ["boringproxy", "version"]