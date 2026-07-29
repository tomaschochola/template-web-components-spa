# syntax=docker/dockerfile:1

FROM docker.io/library/node:24-trixie AS versionednode
FROM mcr.microsoft.com/devcontainers/typescript-node:24-trixie AS versioneddevcontainer
FROM docker.io/nginxinc/nginx-unprivileged:1-trixie AS versionednginx

FROM versionednode AS base
WORKDIR /workspaces
RUN <<EOF
  set -euo pipefail
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -y
  apt-get upgrade -y --no-install-recommends
  apt-get install -y --no-install-recommends ca-certificates curl wget build-essential git zip unzip icoutils
  apt-get autoremove -y
  apt-get autoclean -y
  apt-get clean -y
  rm -rf /var/lib/apt/lists/*
EOF
RUN chown node:node /workspaces
USER node

FROM base AS development_deps
COPY --chown=node:node ./.npmrc ./package* ./
RUN npm ci --ignore-scripts --install-links --include=prod --include=dev --include=peer --include=optional

FROM development_deps AS build
USER root
RUN DEBIAN_FRONTEND=noninteractive npm exec --ignore-scripts -- playwright install-deps chromium
USER node
RUN npm exec --ignore-scripts -- playwright install --only-shell chromium
ARG APP_ENV=production
ARG APP_VERSION
ARG NODE_ENV=production
ARG OTEL_ENABLED=false
ARG OTLP_API_KEY=
ARG POLYFILLS_ENABLED=false
COPY --chown=node:node ./ ./
RUN make build \
  APP_ENV="${APP_ENV}" \
  APP_VERSION="${APP_VERSION:-$(node --print "require('./package.json').version")}" \
  NODE_ENV="${NODE_ENV}" \
  OTEL_ENABLED="${OTEL_ENABLED}" \
  OTLP_API_KEY="${OTLP_API_KEY}" \
  POLYFILLS_ENABLED="${POLYFILLS_ENABLED}"

FROM versionednginx AS nginx
ARG APP_ENV=production
WORKDIR /var/www/html
COPY ./ops/nginx /etc/nginx
COPY --chown=nginx:nginx --from=build /workspaces/dist/${APP_ENV}/ ./
USER nginx

FROM versioneddevcontainer AS devcontainer
WORKDIR /workspaces
RUN <<EOF
  set -euo pipefail
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -y
  apt-get upgrade -y --no-install-recommends
  apt-get install -y --no-install-recommends ca-certificates curl wget build-essential git zip unzip icoutils
  install -d -o node -g node /home/node/.npm
  apt-get autoremove -y
  apt-get autoclean -y
  apt-get clean -y
  rm -rf /var/lib/apt/lists/*
EOF
USER node
