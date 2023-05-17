FROM golang:alpine as builder

RUN apk add --no-cache git

WORKDIR /app

RUN git clone https://github.com/caddyserver/xcaddy.git && \
    cd xcaddy/cmd/xcaddy && \
    go build

RUN /app/xcaddy/cmd/xcaddy/xcaddy build \
    --output /usr/local/bin/caddy \
    --with github.com/caddyserver/forwardproxy@caddy2=github.com/klzgrad/forwardproxy@naive --with github.com/caddy-dns/cloudflare --with github.com/mholt/caddy-dynamicdns

FROM alpine:latest

RUN apk add --no-cache ca-certificates
COPY --from=builder /usr/local/bin/caddy /usr/local/bin/caddy

EXPOSE 80 443

CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile"]
