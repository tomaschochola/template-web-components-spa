# Makefile

SHELL := /usr/bin/env bash

GNUMAKEFLAGS ?=

MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --no-builtin-variables

.SHELLFLAGS := -Eeuo pipefail -c

.DELETE_ON_ERROR:
.SUFFIXES:

# Default goal

.DEFAULT_GOAL := help

# Options

export DEBIAN_FRONTEND := noninteractive

# Goals

.PHONY: help
.SILENT: help
help:
	printf '\033[1m%s\033[0m\n' "$${PWD##*/} targets"
	printf '%s\n' '--------------------------------------------------------------------------------'
	printf '\033[1m%-18s\033[0m  %s\n' 'help' 'Show this help.'
	printf '\033[1m%-18s\033[0m  %s\n' 'all' 'Build production artifacts and package dist.zip.'
	printf '\033[1m%-18s\033[0m  %s\n' 'fix' 'Run all automatic fixers.'
	printf '\033[1m%-18s\033[0m  %s\n' 'check' 'Run lint, static analysis, tests, and audits.'
	printf '\033[1m%-18s\033[0m  %s\n' 'lint' 'Run code style checks.'
	printf '\033[1m%-18s\033[0m  %s\n' 'static' 'Run static analysis.'
	printf '\033[1m%-18s\033[0m  %s\n' 'test' 'Run tests.'
	printf '\033[1m%-18s\033[0m  %s\n' 'audit' 'Run dependency/security audits.'
	printf '\033[1m%-18s\033[0m  %s\n' 'deps_install' 'Install dependencies from current lock files.'
	printf '\033[1m%-18s\033[0m  %s\n' 'deps_update' 'Refresh dependencies and generated lock files.'
	printf '\033[1m%-18s\033[0m  %s\n' 'clean' 'Remove generated build, dependency, and test artifacts.'
	printf '\033[1m%-18s\033[0m  %s\n' 'distclean' 'Run clean and remove generated lock files.'
	printf '\033[1m%-18s\033[0m  %s\n' 'eslint_fix' 'Fix JavaScript/TypeScript lint issues with ESLint.'
	printf '\033[1m%-18s\033[0m  %s\n' 'prettier_fix' 'Format files with Prettier.'
	printf '\033[1m%-18s\033[0m  %s\n' 'stylelint_fix' 'Fix stylesheet lint issues with Stylelint.'
	printf '\033[1m%-18s\033[0m  %s\n' 'eslint_check' 'Check JavaScript/TypeScript with ESLint.'
	printf '\033[1m%-18s\033[0m  %s\n' 'prettier_check' 'Check formatting with Prettier.'
	printf '\033[1m%-18s\033[0m  %s\n' 'stylelint_check' 'Check stylesheets with Stylelint.'
	printf '\033[1m%-18s\033[0m  %s\n' 'typescript_check' 'Run TypeScript type checking.'
	printf '\033[1m%-18s\033[0m  %s\n' 'playwright_test' 'Run Playwright tests.'
	printf '\033[1m%-18s\033[0m  %s\n' 'playwright_install' 'Install Playwright browsers and OS dependencies.'
	printf '\033[1m%-18s\033[0m  %s\n' 'npm_audit' 'Run npm audit at the configured severity level.'
	printf '\033[1m%-18s\033[0m  %s\n' 'npm_install' 'Install npm dependencies from package-lock.json.'
	printf '\033[1m%-18s\033[0m  %s\n' 'npm_update' 'Refresh npm dependencies and package-lock.json.'
	printf '\033[1m%-18s\033[0m  %s\n' 'precreate' 'Run pre-devcontainer setup hooks.'
	printf '\033[1m%-18s\033[0m  %s\n' 'postcreate' 'Run post-devcontainer setup hooks.'
	printf '\033[1m%-18s\033[0m  %s\n' 'start' 'Start the local development server.'
	printf '\033[1m%-18s\033[0m  %s\n' 'serve' 'Alias for start.'
	printf '\033[1m%-18s\033[0m  %s\n' 'server' 'Alias for start.'
	printf '\033[1m%-18s\033[0m  %s\n' 'dev' 'Alias for start.'
	printf '\033[1m%-18s\033[0m  %s\n' 'compose_push' 'Build and push Docker Compose images.'
	printf '\033[1m%-18s\033[0m  %s\n' 'swarm_deploy' 'Deploy the stack to Docker Swarm.'
	printf '\033[1m%-18s\033[0m  %s\n' 'compose_up' 'Start the Docker Compose environment.'
	printf '\033[1m%-18s\033[0m  %s\n' 'compose_stop' 'Stop the Docker Compose environment.'
	printf '\033[1m%-18s\033[0m  %s\n' 'port' 'Print local service ports.'
	printf '\033[1m%-18s\033[0m  %s\n' 'ports' 'Alias for port.'
	printf '\033[1m%-18s\033[0m  %s\n' 'devcontainer' 'Open a devcontainer shell, then stop the container.'
	printf '\033[1m%-18s\033[0m  %s\n' 'build' 'Build project artifacts.'
	printf '\033[1m%-18s\033[0m  %s\n' 'dist_zip' 'Package the contents of ./dist into ./release/dist.zip.'
	printf '\033[1m%-18s\033[0m  %s\n' 'og' 'Generate Open Graph image assets.'
	printf '\033[1m%-18s\033[0m  %s\n' 'local' 'Build/run with APP_ENV=local.'
	printf '\033[1m%-18s\033[0m  %s\n' 'development' 'Build/run with APP_ENV=development.'
	printf '\033[1m%-18s\033[0m  %s\n' 'sit' 'Build/run with APP_ENV=sit.'
	printf '\033[1m%-18s\033[0m  %s\n' 'uat' 'Build/run with APP_ENV=uat.'
	printf '\033[1m%-18s\033[0m  %s\n' 'production' 'Build/run with APP_ENV=production.'
	printf '\033[1m%-18s\033[0m  %s\n' 'generated' 'Generate derived frontend assets.'
	printf '\033[1m%-18s\033[0m  %s\n' 'symbol_icon' 'Generate padded symbol icon assets.'
	printf '\033[1m%-18s\033[0m  %s\n' 'fullbleed_icon' 'Generate full-bleed icon assets.'
	printf '\033[1m%-18s\033[0m  %s\n' 'playwright_failed' 'Open the last failed Playwright test report.'
	printf '\033[1m%-18s\033[0m  %s\n' 'playwright_headed' 'Run Playwright tests in headed mode.'
	printf '\033[1m%-18s\033[0m  %s\n' 'playwright_ui' 'Open Playwright UI mode.'

.PHONY: all
all: dist_zip

.PHONY: fix
fix: eslint_fix prettier_fix stylelint_fix

.PHONY: check
check: lint static test audit

.PHONY: lint
lint: eslint_check prettier_check stylelint_check

.PHONY: static
static: typescript_check

.PHONY: test
test: playwright_test

.PHONY: audit
audit: npm_audit

.PHONY: deps_install
deps_install: npm_install

.PHONY: deps_update
deps_update: npm_update

.PHONY: clean
clean:
	rm -rf ./node_modules
	rm -rf ./dist
	rm -rf ./release
	rm -rf ./generated
	rm -rf ./tmp
	rm -rf ./test-results

.PHONY: distclean
distclean: clean
	rm -rf ./package-lock.json

.PHONY: eslint_fix
eslint_fix: ./node_modules ./package.json ./package-lock.json ./eslint.config.js
	npm exec --ignore-scripts -- eslint --concurrency=auto --fix .

.PHONY: prettier_fix
prettier_fix: ./node_modules ./package.json ./package-lock.json ./prettier.config.js
	npm exec --ignore-scripts -- prettier -w .

.PHONY: stylelint_fix
stylelint_fix: ./node_modules ./package.json ./package-lock.json ./stylelint.config.js
	npm exec --ignore-scripts -- stylelint --allow-empty-input --fix ./**/*.{sass,scss,css}


.PHONY: eslint_check
eslint_check: ./node_modules ./package.json ./package-lock.json ./eslint.config.js
	npm exec --ignore-scripts -- eslint --concurrency=auto .

.PHONY: prettier_check
prettier_check: ./node_modules ./package.json ./package-lock.json ./prettier.config.js
	npm exec --ignore-scripts -- prettier -c .

.PHONY: stylelint_check
stylelint_check: ./node_modules ./package.json ./package-lock.json ./stylelint.config.js
	npm exec --ignore-scripts -- stylelint --allow-empty-input ./**/*.{sass,scss,css}

.PHONY: typescript_check
typescript_check: ./node_modules ./package.json ./package-lock.json ./tsconfig.json ./tsconfig.playwright.json
	npm exec --ignore-scripts -- tsc --noEmit --project ./tsconfig.json
	npm exec --ignore-scripts -- tsc --noEmit --project ./tsconfig.playwright.json

.PHONY: playwright_test
playwright_test: ./node_modules ./package.json ./package-lock.json ./playwright.config.js generated
	npm exec --ignore-scripts -- playwright test

.PHONY: playwright_install
playwright_install: ./node_modules ./package.json ./package-lock.json ./playwright.config.js
	npm exec --ignore-scripts -- playwright install --with-deps

.PHONY: npm_audit
npm_audit: ./node_modules ./package.json ./package-lock.json
	npm audit --ignore-scripts --audit-level=critical --install-links --include=prod --include=dev --include=peer --include=optional

.PHONY: npm_install
npm_install: ./package.json ./package-lock.json
	npm install --ignore-scripts --install-links --include=prod --include=dev --include=peer --include=optional

.PHONY: npm_update
npm_update: ./package.json
	rm -rf ./node_modules
	rm -rf ./package-lock.json
	npm update --ignore-scripts --install-links --include=prod --include=dev --include=peer --include=optional

.PHONY: precreate
precreate:
	docker volume create tomaschochola-npm-cache

.PHONY: postcreate
postcreate: deps_install

.PHONY: start serve server dev
start serve server dev: ./node_modules ./package.json ./package-lock.json generated
	npm exec --ignore-scripts -- webpack-cli serve --mode=$${NODE_ENV:-development} --config-node-env=$${NODE_ENV:-development} --env APP_ENV=$${APP_ENV:-local}

.PHONY: compose_push
compose_push:
	docker compose -f ./docker-compose.yml -f ./docker-compose-swarm.yml build --pull --push

.PHONY: swarm_deploy
swarm_deploy:
	docker stack deploy -c ./docker-compose.yml -c ./docker-compose-swarm.yml --with-registry-auth --prune --detach=false --resolve-image=always $${CI_PROJECT_PATH_SLUG:-template-web-components-spa}

.PHONY: compose_up
compose_up:
	docker compose -f ./docker-compose.yml -f ./docker-compose-swarm.yml up --build --remove-orphans --always-recreate-deps --force-recreate --pull=always --renew-anon-volumes

.PHONY: compose_stop
compose_stop:
	docker compose -f ./docker-compose.yml -f ./docker-compose-swarm.yml stop

.PHONY: port ports
.SILENT: port ports
port ports:
	printf '\033[1m%-80s\033[0m\n' 'template-web-components-spa ports'
	printf '%-80s\n' '--------------------------------------------------------------------------------'
	printf '\033[1m%-12s %-21s %-12s %-20s\033[0m\n' 'Kind' 'Host' 'Container' 'Service'
	printf '%-12s %-21s %-12s %-20s\n' 'nginx' '127.0.0.1:61100' '61100' 'nginx'
	printf '%-12s %-21s %-12s %-20s\n' 'webpack' '127.0.0.1:61101' '61101' 'devcontainer'
	printf '%-80s\n' '--------------------------------------------------------------------------------'
	printf '\n\033[1mLinks\033[0m\n'
	printf '%s\n' 'Webpack dev server: http://127.0.0.1:61101/'
	printf '%s\n' 'Nginx server:       http://127.0.0.1:61100/'

.PHONY: devcontainer
devcontainer: precreate
	devcontainer up
	devcontainer exec /bin/bash || true
	docker ps -q --filter "label=devcontainer.local_folder=$${PWD}" | xargs -r docker stop

.PHONY: build
build: ./node_modules ./package.json ./package-lock.json generated
	npm exec --ignore-scripts -- webpack-cli build --mode=$${NODE_ENV:-development} --config-node-env=$${NODE_ENV:-development} --env APP_ENV=$${APP_ENV:-local}

.PHONY: dist_zip
dist_zip: production
	rm -rf ./release
	mkdir -p ./release
	cd ./dist && zip -r ../release/dist.zip .

.PHONY: og
og: ./node_modules ./package.json ./package-lock.json ./webpack.config.og.js ./og/og.html ./og/og.scss ./og/og.ts ./assets/icon.svg
	rm -rf ./tmp/og
	rm -f ./generated/og/og-image.png
	mkdir -p ./generated/og
	npm exec --ignore-scripts -- webpack-cli build --mode=production --config-node-env=production --config ./webpack.config.og.js --env APP_ENV=$${APP_ENV:-local}
	npm exec --ignore-scripts -- playwright screenshot --browser=chromium --color-scheme=light --viewport-size=1200,630 --timeout=60000 file://${CURDIR}/./tmp/og/og.html ./generated/og/og-image.png
	rm -rf ./tmp/og

.PHONY: local
local: export APP_ENV := local
local: export NODE_ENV := development
local: build

.PHONY: development
development: export APP_ENV := development
development: export NODE_ENV := production
development: build

.PHONY: sit
sit: export APP_ENV := sit
sit: export NODE_ENV := production
sit: build

.PHONY: uat
uat: export APP_ENV := uat
uat: export NODE_ENV := production
uat: build

.PHONY: production
production: export APP_ENV := production
production: export NODE_ENV := production
production: build

.PHONY: generated
generated: symbol_icon og

.PHONY: symbol_icon
symbol_icon: ./node_modules ./package.json ./package-lock.json ./assets/icon.svg
	mkdir -p ./generated/icons
	rm -rf ./tmp/favicons
	mkdir -p ./tmp/favicons
	rm -f ./generated/favicon.svg ./generated/favicon.ico
	rm -f ./generated/favicon-16x16.png ./generated/favicon-32x32.png ./generated/favicon-48x48.png ./generated/favicon-96x96.png
	rm -f ./generated/apple-touch-icon.png
	rm -f ./generated/icons/icon-192x192.png ./generated/icons/icon-512x512.png ./generated/icons/icon-1024x1024.png
	rm -f ./generated/icons/maskable-icon-192x192.png ./generated/icons/maskable-icon-512x512.png ./generated/icons/maskable-icon-1024x1024.png
	svgo --multipass --quiet --input "./assets/icon.svg" --output "./generated/favicon.svg"
	resvg --width 16 --height 16 "./generated/favicon.svg" "./tmp/favicons/favicon16.png"
	sharp -i "./tmp/favicons/favicon16.png" -o "./generated/favicon-16x16.png" -f png --compressionLevel 9 --adaptiveFiltering toColorspace srgb
	resvg --width 32 --height 32 "./generated/favicon.svg" "./tmp/favicons/favicon32.png"
	sharp -i "./tmp/favicons/favicon32.png" -o "./generated/favicon-32x32.png" -f png --compressionLevel 9 --adaptiveFiltering toColorspace srgb
	resvg --width 48 --height 48 "./generated/favicon.svg" "./tmp/favicons/favicon48.png"
	sharp -i "./tmp/favicons/favicon48.png" -o "./generated/favicon-48x48.png" -f png --compressionLevel 9 --adaptiveFiltering toColorspace srgb
	resvg --width 96 --height 96 "./generated/favicon.svg" "./tmp/favicons/favicon96.png"
	sharp -i "./tmp/favicons/favicon96.png" -o "./generated/favicon-96x96.png" -f png --compressionLevel 9 --adaptiveFiltering toColorspace srgb
	icotool --create --output "./generated/favicon.ico" "./generated/favicon-16x16.png" "./generated/favicon-32x32.png" "./generated/favicon-48x48.png"
	resvg --width 144 --height 144 "./generated/favicon.svg" "./tmp/favicons/apple.png"
	sharp -i "./tmp/favicons/apple.png" -o "./generated/apple-touch-icon.png" -f png --compressionLevel 9 --adaptiveFiltering extend 18 18 18 18 --background '#141218' -- flatten '#141218' -- toColorspace srgb
	resvg --width 154 --height 154 "./generated/favicon.svg" "./tmp/favicons/icon192.png"
	sharp -i "./tmp/favicons/icon192.png" -o "./generated/icons/icon-192x192.png" -f png --compressionLevel 9 --adaptiveFiltering extend 19 19 19 19 --background '#141218' -- flatten '#141218' -- toColorspace srgb
	resvg --width 410 --height 410 "./generated/favicon.svg" "./tmp/favicons/icon512.png"
	sharp -i "./tmp/favicons/icon512.png" -o "./generated/icons/icon-512x512.png" -f png --compressionLevel 9 --adaptiveFiltering extend 51 51 51 51 --background '#141218' -- flatten '#141218' -- toColorspace srgb
	resvg --width 820 --height 820 "./generated/favicon.svg" "./tmp/favicons/icon1024.png"
	sharp -i "./tmp/favicons/icon1024.png" -o "./generated/icons/icon-1024x1024.png" -f png --compressionLevel 9 --adaptiveFiltering extend 102 102 102 102 --background '#141218' -- flatten '#141218' -- toColorspace srgb
	resvg --width 108 --height 108 "./generated/favicon.svg" "./tmp/favicons/maskable192.png"
	sharp -i "./tmp/favicons/maskable192.png" -o "./generated/icons/maskable-icon-192x192.png" -f png --compressionLevel 9 --adaptiveFiltering extend 42 42 42 42 --background '#141218' -- flatten '#141218' -- toColorspace srgb
	resvg --width 288 --height 288 "./generated/favicon.svg" "./tmp/favicons/maskable512.png"
	sharp -i "./tmp/favicons/maskable512.png" -o "./generated/icons/maskable-icon-512x512.png" -f png --compressionLevel 9 --adaptiveFiltering extend 112 112 112 112 --background '#141218' -- flatten '#141218' -- toColorspace srgb
	resvg --width 576 --height 576 "./generated/favicon.svg" "./tmp/favicons/maskable1024.png"
	sharp -i "./tmp/favicons/maskable1024.png" -o "./generated/icons/maskable-icon-1024x1024.png" -f png --compressionLevel 9 --adaptiveFiltering extend 224 224 224 224 --background '#141218' -- flatten '#141218' -- toColorspace srgb
	rm -rf ./tmp/favicons

.PHONY: fullbleed_icon
fullbleed_icon: ./node_modules ./package.json ./package-lock.json ./assets/icon.svg
	mkdir -p ./generated/icons
	rm -rf ./tmp/favicons
	mkdir -p ./tmp/favicons
	rm -f ./generated/favicon.svg ./generated/favicon.ico
	rm -f ./generated/favicon-16x16.png ./generated/favicon-32x32.png ./generated/favicon-48x48.png ./generated/favicon-96x96.png
	rm -f ./generated/apple-touch-icon.png
	rm -f ./generated/icons/icon-192x192.png ./generated/icons/icon-512x512.png ./generated/icons/icon-1024x1024.png
	rm -f ./generated/icons/maskable-icon-192x192.png ./generated/icons/maskable-icon-512x512.png ./generated/icons/maskable-icon-1024x1024.png
	svgo --multipass --quiet --input "./assets/icon.svg" --output "./generated/favicon.svg"
	resvg --width 16 --height 16 "./generated/favicon.svg" "./tmp/favicons/favicon16.png"
	sharp -i "./tmp/favicons/favicon16.png" -o "./generated/favicon-16x16.png" -f png --compressionLevel 9 --adaptiveFiltering toColorspace srgb
	resvg --width 32 --height 32 "./generated/favicon.svg" "./tmp/favicons/favicon32.png"
	sharp -i "./tmp/favicons/favicon32.png" -o "./generated/favicon-32x32.png" -f png --compressionLevel 9 --adaptiveFiltering toColorspace srgb
	resvg --width 48 --height 48 "./generated/favicon.svg" "./tmp/favicons/favicon48.png"
	sharp -i "./tmp/favicons/favicon48.png" -o "./generated/favicon-48x48.png" -f png --compressionLevel 9 --adaptiveFiltering toColorspace srgb
	resvg --width 96 --height 96 "./generated/favicon.svg" "./tmp/favicons/favicon96.png"
	sharp -i "./tmp/favicons/favicon96.png" -o "./generated/favicon-96x96.png" -f png --compressionLevel 9 --adaptiveFiltering toColorspace srgb
	icotool --create --output "./generated/favicon.ico" "./generated/favicon-16x16.png" "./generated/favicon-32x32.png" "./generated/favicon-48x48.png"
	resvg --width 180 --height 180 --background '#141218' "./generated/favicon.svg" "./tmp/favicons/apple.png"
	sharp -i "./tmp/favicons/apple.png" -o "./generated/apple-touch-icon.png" -f png --compressionLevel 9 --adaptiveFiltering flatten '#141218' -- toColorspace srgb
	resvg --width 192 --height 192 --background '#141218' "./generated/favicon.svg" "./tmp/favicons/icon192.png"
	sharp -i "./tmp/favicons/icon192.png" -o "./generated/icons/icon-192x192.png" -f png --compressionLevel 9 --adaptiveFiltering flatten '#141218' -- toColorspace srgb
	resvg --width 512 --height 512 --background '#141218' "./generated/favicon.svg" "./tmp/favicons/icon512.png"
	sharp -i "./tmp/favicons/icon512.png" -o "./generated/icons/icon-512x512.png" -f png --compressionLevel 9 --adaptiveFiltering flatten '#141218' -- toColorspace srgb
	resvg --width 1024 --height 1024 --background '#141218' "./generated/favicon.svg" "./tmp/favicons/icon1024.png"
	sharp -i "./tmp/favicons/icon1024.png" -o "./generated/icons/icon-1024x1024.png" -f png --compressionLevel 9 --adaptiveFiltering flatten '#141218' -- toColorspace srgb
	resvg --width 192 --height 192 --background '#141218' "./generated/favicon.svg" "./tmp/favicons/maskable192.png"
	sharp -i "./tmp/favicons/maskable192.png" -o "./generated/icons/maskable-icon-192x192.png" -f png --compressionLevel 9 --adaptiveFiltering flatten '#141218' -- toColorspace srgb
	resvg --width 512 --height 512 --background '#141218' "./generated/favicon.svg" "./tmp/favicons/maskable512.png"
	sharp -i "./tmp/favicons/maskable512.png" -o "./generated/icons/maskable-icon-512x512.png" -f png --compressionLevel 9 --adaptiveFiltering flatten '#141218' -- toColorspace srgb
	resvg --width 1024 --height 1024 --background '#141218' "./generated/favicon.svg" "./tmp/favicons/maskable1024.png"
	sharp -i "./tmp/favicons/maskable1024.png" -o "./generated/icons/maskable-icon-1024x1024.png" -f png --compressionLevel 9 --adaptiveFiltering flatten '#141218' -- toColorspace srgb
	rm -rf ./tmp/favicons

.PHONY: playwright_failed
playwright_failed: ./node_modules ./package.json ./package-lock.json ./playwright.config.js generated
	npm exec --ignore-scripts -- playwright test --last-failed

.PHONY: playwright_headed
playwright_headed: ./node_modules ./package.json ./package-lock.json ./playwright.config.js generated
	npm exec --ignore-scripts -- playwright test --headed

.PHONY: playwright_ui
playwright_ui: ./node_modules ./package.json ./package-lock.json ./playwright.config.js generated
	npm exec --ignore-scripts -- playwright test --ui

# Dependencies

./package-lock.json ./node_modules &: ./package.json
	${MAKE} npm_update
