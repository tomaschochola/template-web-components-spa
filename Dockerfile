# syntax=docker/dockerfile:1

FROM node:24-trixie AS versionednode
FROM mcr.microsoft.com/devcontainers/typescript-node:24-trixie AS versioneddevcontainer
FROM nginxinc/nginx-unprivileged:1-trixie AS versionednginx

FROM versionednode AS base
WORKDIR /workspaces
ENV APP_ENV=production
ENV APP_VERSION=dev
ENV NODE_ENV=production
RUN <<EOF
  set -euo pipefail
  apt-get update -y
  apt-get upgrade -y --no-install-recommends
  apt-get autoremove -y
  apt-get autoclean -y
  apt-get clean -y
  rm -rf /var/lib/apt/lists/*
EOF
RUN chown node:node /workspaces
USER node

FROM base AS development_deps
COPY --chown=node:node ./package* ./
RUN npm install --ignore-scripts --install-links --include=prod --include=dev --include=peer --include=optional

FROM development_deps AS build
COPY --chown=node:node ./ ./
RUN npm exec --ignore-scripts -- tsc

FROM versionednginx AS nginx
USER root
WORKDIR /var/www/html
COPY ./ops/nginx /etc/nginx
RUN <<EOF
	set -euo pipefail
	apt-get update -y
	apt-get upgrade -y --no-install-recommends
	openssl req -x509 -newkey rsa:4096 -nodes -sha256 -keyout /etc/nginx/snakeoil.key -out /etc/nginx/snakeoil.pem -days 3650 -subj "/CN=localhost" -addext "subjectAltName=DNS:*.localhost,DNS:localhost"
	apt-get autoremove -y
	apt-get autoclean -y
	apt-get clean -y
	rm -rf /var/lib/apt/lists/*
EOF
COPY --chown=nginx:nginx --from=build /workspaces/dist ./
USER nginx

FROM versioneddevcontainer AS devcontainer
WORKDIR /workspaces
ENV APP_ENV=local
ENV APP_VERSION=dev
ENV NODE_ENV=development
ADD --chmod=755 https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 /usr/local/bin/yq
RUN <<EOF
  set -euo pipefail
  apt-get update -y
  apt-get upgrade -y --no-install-recommends
  apt-get install -y --no-install-recommends ca-certificates curl wget build-essential git zip unzip icoutils
  npm install -g svgo@latest sharp-cli@latest
  wget https://github.com/linebender/resvg/releases/latest/download/resvg-linux-x86_64.tar.gz -O /tmp/resvg.tar.gz
  tar -xf /tmp/resvg.tar.gz -C /usr/local/bin resvg
  rm /tmp/resvg.tar.gz
  chmod +x /usr/local/bin/resvg
  apt-get autoremove -y
  apt-get autoclean -y
  apt-get clean -y
  rm -rf /var/lib/apt/lists/*
EOF
USER node
RUN <<EOF
  set -euo pipefail
  npm exec --ignore-scripts -- playwright install --with-deps
EOF
