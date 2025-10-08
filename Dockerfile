FROM nikolaik/python-nodejs:python3.13-nodejs24 AS build

ADD . /app
WORKDIR /app
RUN uv sync && npm install
RUN rm -rf public/dist && uv run hyperflask build
RUN mkdir -p _site
RUN uv export --frozen --no-hashes > requirements.txt

FROM python:3.13-slim

RUN apt update && apt install -y git
ADD . /app
WORKDIR /app

COPY --from=build /app/app/assets.json /app/app/assets.json
COPY --from=build /app/public /app/public
COPY --from=build /app/_site /app/_site
COPY --from=caddy:latest /usr/bin/caddy /usr/bin/caddy
COPY --from=litestream/litestream:latest /usr/local/bin/litestream /usr/local/bin/litestream

RUN mkdir -p database uploads

RUN cat >/app/Caddyfile <<EOT
{
    auto_https off
    admin off
    grace_period 5s
}

:80 {
    root * /app/_site

    handle_path /static/* {
        file_server {
            root /app/public
        }
    }

    handle /.well-known/mercure {
        reverse_proxy localhost:5300
    }

    handle {
        file_server {
            pass_thru
        }
        reverse_proxy localhost:5000
    }
}
EOT

RUN cat >/app/Procfile <<EOT
caddy: caddy run --config /app/Caddyfile
EOT

RUN --mount=type=bind,from=build,source=/app/requirements.txt,target=/tmp/requirements.txt \
    pip install -r /tmp/requirements.txt

RUN cat >/app/entrypoint.sh <<EOT
#!/bin/sh
set -e
if [ -z "${LITESTREAM_URL}" ]; then
    hyperflask "\$@"
else
    if [ ! -f /etc/litestream.yml ] && [ -f /app/litestream.yml ]; then
        cp /app/litestream.yml /etc/litestream.yml
    elif [ ! -f /etc/litestream.yml ]; then
        cat >/etc/litestream.yml <<EOF
dbs:
  - path: /app/database/app.db
    replica:
      url: ${LITESTREAM_URL}
EOF
    fi
    litestream replicate -exec "hyperflask \$@"
fi
EOT

RUN chmod +x /app/entrypoint.sh
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["run", "--extend-procfile", "--init-db", "--host", "0.0.0.0"]

VOLUME ["/app/database", "/app/uploads", "/etc/litestream.yml"]
EXPOSE 80
