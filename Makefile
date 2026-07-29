# Makefile

SHELL := /usr/bin/env bash

GNUMAKEFLAGS ?=

MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --no-builtin-variables

.SHELLFLAGS := -Eeuo pipefail -c

.DELETE_ON_ERROR:
.SUFFIXES:
.NOTPARALLEL:

# Options

export APP_ENV ?= production
export NODE_ENV ?= production
export OTEL_ENABLED ?= false
export OTLP_API_KEY ?=
export POLYFILLS_ENABLED ?= false

# Default goal

.DEFAULT_GOAL := never

.PHONY: never
.SILENT: never
never:
	printf '%s\n' 'No default target. Run an explicit target' >&2
	exit 1

# Goals

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
	npm exec --ignore-scripts -- playwright install --with-deps chromium firefox webkit chrome msedge

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
postcreate: deps_install playwright_install

.PHONY: start serve server dev
start serve server dev: override export APP_ENV := local
start serve server dev: override export NODE_ENV := development
start serve server dev: ./node_modules ./package.json ./package-lock.json generated
	npm exec --ignore-scripts -- webpack-cli serve --mode=$${NODE_ENV} --config-node-env=$${NODE_ENV}

.PHONY: local_dist local_zip local_image local_pull local_push local_compose local_swarm local_swarm_remove
local_dist local_zip local_image local_pull local_push local_compose local_swarm local_swarm_remove: override export APP_ENV := local
local_dist local_zip local_image local_pull local_push local_compose local_swarm local_swarm_remove: override export NODE_ENV := development

.PHONY: development_dist development_zip development_image development_pull development_push development_compose development_swarm development_swarm_remove
development_dist development_zip development_image development_pull development_push development_compose development_swarm development_swarm_remove: override export APP_ENV := development
development_dist development_zip development_image development_pull development_push development_compose development_swarm development_swarm_remove: override export NODE_ENV := development

.PHONY: sit_dist sit_zip sit_image sit_pull sit_push sit_compose sit_swarm sit_swarm_remove
sit_dist sit_zip sit_image sit_pull sit_push sit_compose sit_swarm sit_swarm_remove: override export APP_ENV := sit
sit_dist sit_zip sit_image sit_pull sit_push sit_compose sit_swarm sit_swarm_remove: override export NODE_ENV := production

.PHONY: uat_dist uat_zip uat_image uat_pull uat_push uat_compose uat_swarm uat_swarm_remove
uat_dist uat_zip uat_image uat_pull uat_push uat_compose uat_swarm uat_swarm_remove: override export APP_ENV := uat
uat_dist uat_zip uat_image uat_pull uat_push uat_compose uat_swarm uat_swarm_remove: override export NODE_ENV := production

.PHONY: production_dist production_zip production_image production_pull production_push production_compose production_swarm production_swarm_remove
production_dist production_zip production_image production_pull production_push production_compose production_swarm production_swarm_remove: override export APP_ENV := production
production_dist production_zip production_image production_pull production_push production_compose production_swarm production_swarm_remove: override export NODE_ENV := production

local_dist development_dist sit_dist uat_dist production_dist:
	${MAKE} build

local_zip: local_dist
development_zip: development_dist
sit_zip: sit_dist
uat_zip: uat_dist
production_zip: production_dist

local_zip development_zip sit_zip uat_zip production_zip:
	mkdir -p ./release
	rm -f "./release/$${APP_ENV}.zip"
	cd "./dist/$${APP_ENV}" && zip -q -r "../../release/$${APP_ENV}.zip" .

local_image development_image sit_image uat_image production_image:
	docker compose -f ./docker-compose.yml build --pull

local_pull development_pull sit_pull uat_pull production_pull:
	docker compose -f ./docker-compose.yml pull

local_push: local_image
development_push: development_image
sit_push: sit_image
uat_push: uat_image
production_push: production_image

local_push development_push sit_push uat_push production_push:
	docker compose -f ./docker-compose.yml push

local_compose: local_image
development_compose: development_image
sit_compose: sit_image
uat_compose: uat_image
production_compose: production_image

local_compose development_compose sit_compose uat_compose production_compose:
	docker compose -f ./docker-compose.yml -f ./docker-compose-runtime.yml up --no-build --remove-orphans --force-recreate

local_swarm: local_push
development_swarm: development_push
sit_swarm: sit_push
uat_swarm: uat_push
production_swarm: production_push

local_swarm development_swarm sit_swarm uat_swarm production_swarm:
	docker stack deploy -c ./docker-compose.yml -c ./docker-compose-swarm.yml --with-registry-auth --prune --detach=false --resolve-image=always "$${CI_PROJECT_PATH_SLUG:-template-web-components-spa}-$${APP_ENV}"

.PHONY: compose_stop
compose_stop:
	docker compose -f ./docker-compose.yml -f ./docker-compose-runtime.yml stop

local_swarm_remove development_swarm_remove sit_swarm_remove uat_swarm_remove production_swarm_remove:
	docker stack rm "$${CI_PROJECT_PATH_SLUG:-template-web-components-spa}-$${APP_ENV}"

.PHONY: devcontainer
devcontainer: precreate
	devcontainer up --workspace-folder .
	devcontainer exec --workspace-folder . /bin/bash || true
	docker ps -q --filter "label=devcontainer.local_folder=$${PWD}" | xargs -r docker stop

.PHONY: build
build: ./node_modules ./package.json ./package-lock.json generated
	npm exec --ignore-scripts -- webpack-cli build --mode=$${NODE_ENV} --config-node-env=$${NODE_ENV}

.PHONY: artifacts
artifacts: ./node_modules ./package.json ./package-lock.json ./artifacts/artifacts.ts
	npm exec --ignore-scripts -- browser-artifacts --entry ./artifacts/artifacts.ts --output ./generated/artifacts

.PHONY: generated
generated: artifacts icons

.PHONY: icons
icons: ./node_modules ./package.json ./package-lock.json ./assets/icon.svg
	npm exec --ignore-scripts -- generate-icons ./assets/icon.svg ./generated symbol '#141218'

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
