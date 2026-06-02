# Default shell
SHELL := /bin/bash

# Default goal
.DEFAULT_GOAL := never

# Options
export DEBIAN_FRONTEND := noninteractive
# Goals
.PHONY: commit
commit: distclean update fix check

.PHONY: fix
fix: eslint_fix prettier_fix stylelint_fix yq_fix

.PHONY: check
check: lint stan test audit

.PHONY: lint
lint: eslint_check prettier_check stylelint_check

.PHONY: stan
stan: typescript_check

.PHONY: test
test: playwright_test

.PHONY: audit
audit: npm_audit

.PHONY: install
install: npm_install

.PHONY: update
update: npm_update

.PHONY: clean
clean:
	rm -rf ./node_modules
	rm -rf ./dist
	rm -rf ./generated
	rm -rf ./tmp

.PHONY: distclean
distclean: clean
	git clean -Xfd

.PHONY: eslint_fix
eslint_fix: ./node_modules ./eslint.config.js
	npm exec --ignore-scripts -- eslint --concurrency=auto --fix .

.PHONY: prettier_fix
prettier_fix: ./node_modules ./prettier.config.js
	npm exec --ignore-scripts -- prettier -w .

.PHONY: stylelint_fix
stylelint_fix: ./node_modules ./stylelint.config.js
	npm exec --ignore-scripts -- stylelint --allow-empty-input --fix ./**/*.{sass,scss,css}

.PHONY: yq_fix
yq_fix:
	find . -type f -name "*.yml" -exec yq -i 'sort_keys(..)' {} \;

.PHONY: eslint_check
eslint_check: ./node_modules ./eslint.config.js
	npm exec --ignore-scripts -- eslint --concurrency=auto .

.PHONY: prettier_check
prettier_check: ./node_modules ./prettier.config.js
	npm exec --ignore-scripts -- prettier -c .

.PHONY: stylelint_check
stylelint_check: ./node_modules ./stylelint.config.js
	npm exec --ignore-scripts -- stylelint --allow-empty-input ./**/*.{sass,scss,css}

.PHONY: typescript_check
typescript_check: ./node_modules ./tsconfig.json ./tsconfig.playwright.json
	npm exec --ignore-scripts -- tsc --noEmit --project ./tsconfig.json
	npm exec --ignore-scripts -- tsc --noEmit --project ./tsconfig.playwright.json

.PHONY: playwright_test
playwright_test: ./node_modules ./playwright.config.js generated
	npm exec --ignore-scripts -- playwright test

.PHONY: playwright_install
playwright_install: ./node_modules ./playwright.config.js
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
	docker volume create tomaschochola-npm-cache >/dev/null

.PHONY: postcreate
postcreate: install

.PHONY: start serve server dev
start serve server dev: ./node_modules ./package.json ./package-lock.json generated
	npm exec --ignore-scripts -- webpack-cli serve --mode=$${NODE_ENV:-development} --config-node-env=$${NODE_ENV:-development} --env APP_ENV=$${APP_ENV:-local}

.PHONY: image
image:
	docker compose -f ./docker-compose.yml -f ./docker-compose-swarm.yml build --pull --push

.PHONY: trivy
trivy:
	docker compose -f ./docker-compose.yml -f ./docker-compose-swarm.yml build --pull
	@set -eo pipefail; \
		docker compose -f ./docker-compose.yml -f ./docker-compose-swarm.yml config --images | sort -u | \
		xargs -r -n 1 docker run --rm --pull missing \
			--mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock \
			--mount type=volume,source=trivy-cache,target=/root/.cache \
			docker.io/aquasec/trivy:latest image \
			--exit-code 1 \
			--severity HIGH,CRITICAL

.PHONY: deploy
deploy:
	docker stack deploy -c ./docker-compose.yml -c ./docker-compose-swarm.yml --with-registry-auth --prune --detach=false --resolve-image=always $${CI_PROJECT_PATH_SLUG:-template-web-components-spa}

.PHONY: up
up:
	docker compose -f ./docker-compose.yml -f ./docker-compose-swarm.yml up --build --remove-orphans --always-recreate-deps --force-recreate --pull=always --renew-anon-volumes

.PHONY: stop
stop:
	docker compose -f ./docker-compose.yml -f ./docker-compose-swarm.yml stop

.PHONY: port ports
port ports:
	@printf '\033[1m%-80s\033[0m\n' 'template-web-components-spa ports'
	@printf '%-80s\n' '--------------------------------------------------------------------------------'
	@printf '\033[1m%-12s %-21s %-12s %-20s\033[0m\n' 'Kind' 'Host' 'Container' 'Service'
	@printf '%-12s %-21s %-12s %-20s\n' 'nginx' '127.0.0.1:61100' '61100' 'nginx'
	@printf '%-12s %-21s %-12s %-20s\n' 'webpack' '127.0.0.1:61101' '61101' 'devcontainer'
	@printf '%-80s\n' '--------------------------------------------------------------------------------'
	@printf '\n\033[1mLinks\033[0m\n'
	@printf '%s\n' 'Webpack dev server: http://127.0.0.1:61101/'
	@printf '%s\n' 'Nginx server:       http://127.0.0.1:61100/'

.PHONY: devcontainer
devcontainer: precreate
	devcontainer up
	devcontainer exec /bin/bash || true
	docker ps -q --filter "label=devcontainer.local_folder=$${PWD}" | xargs -r docker stop

.PHONY: build
build: generated
	npm exec --ignore-scripts -- webpack-cli build --mode=$${NODE_ENV:-development} --config-node-env=$${NODE_ENV:-development} --env APP_ENV=$${APP_ENV:-local}

.PHONY: og
og: ./node_modules ./webpack.config.og.js ./og/og.html ./og/og.scss ./og/og.ts ./assets/icon.svg
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
production: generated
	npm exec --ignore-scripts -- webpack-cli build --mode=$${NODE_ENV:-development} --config-node-env=$${NODE_ENV:-development} --env APP_ENV=$${APP_ENV:-local}

.PHONY: generated
generated: symbol_icon og

.PHONY: symbol_icon
symbol_icon: ./assets/icon.svg
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
fullbleed_icon: ./assets/icon.svg
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
playwright_failed: ./node_modules ./playwright.config.js generated
	npm exec --ignore-scripts -- playwright test --last-failed

.PHONY: playwright_headed
playwright_headed: ./node_modules ./playwright.config.js generated
	npm exec --ignore-scripts -- playwright test --headed

.PHONY: playwright_ui
playwright_ui: ./node_modules ./playwright.config.js generated
	npm exec --ignore-scripts -- playwright test --ui

# Dependencies
./package-lock.json ./node_modules: ./package.json
	${MAKE} npm_update
