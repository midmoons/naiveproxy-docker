```bash

curl -fsSL https://raw.githubusercontent.com/bankroft/naiveproxy-docker/main/deploy.sh | bash

```

```bash

# https://github.com/caddy-dns
xcaddy build --with github.com/caddyserver/forwardproxy@caddy2=github.com/klzgrad/forwardproxy@naive --with github.com/caddy-dns/cloudflare --with github.com/mholt/caddy-dynamicdns


```