# Default shell
SHELL := /bin/bash

# Default goal
.DEFAULT_GOAL := never

# Options
export DEBIAN_FRONTEND := noninteractive

# Assets
ICON_SRC := ./assets/icons/icon.svg
PUBLIC_DIR := ./public
ICONS_DIR := $(PUBLIC_DIR)/icons
SOCIAL_DIR := $(PUBLIC_DIR)/social

ICON_BG := \#5b4497
MASKABLE_ICON_BG := $(ICON_BG)
OG_BG := \#141218
APP_ICON_MODE ?= fullbleed
APP_ICON_LOGO_180 := 144
APP_ICON_LOGO_192 := 154
APP_ICON_LOGO_512 := 410
APP_ICON_LOGO_1024 := 820
APP_ICON_OFFSET := +0+0
MASKABLE_LOGO_192 := 108
MASKABLE_LOGO_512 := 290
MASKABLE_LOGO_1024 := 580
MASKABLE_ICON_OFFSET := +0+0
OG_VIEWPORT_SIZE ?= 1200,630
OG_OUTPUT ?= $(SOCIAL_DIR)/og-image.png

render_app_icon = case "$(APP_ICON_MODE)" in fullbleed) magick -background '$(ICON_BG)' -density 1024 $(ICON_SRC) -alpha remove -alpha off -resize $(1)x$(1)\! -strip png32:$(3) ;; symbol) magick -size $(1)x$(1) canvas:'$(ICON_BG)' \( +size -background none -density 1024 $(ICON_SRC) -alpha on -resize $(2)x$(2)\! \) -gravity center -geometry $(APP_ICON_OFFSET) -composite -strip png32:$(3) ;; *) echo 'Unsupported APP_ICON_MODE "$(APP_ICON_MODE)"; use "fullbleed" or "symbol".' >&2; exit 2 ;; esac

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
	rm -rf $(PUBLIC_DIR)/apple-touch-icon.png
	rm -rf $(PUBLIC_DIR)/favicon.ico
	rm -rf $(PUBLIC_DIR)/favicon.svg
	rm -rf $(PUBLIC_DIR)/favicon-16x16.png
	rm -rf $(PUBLIC_DIR)/favicon-32x32.png
	rm -rf $(PUBLIC_DIR)/favicon-48x48.png
	rm -rf $(PUBLIC_DIR)/favicon-96x96.png
	rm -rf $(PUBLIC_DIR)/icon-192x192.png
	rm -rf $(PUBLIC_DIR)/icon-192x192-maskable.png
	rm -rf $(PUBLIC_DIR)/icon-512x512.png
	rm -rf $(PUBLIC_DIR)/icon-512x512-maskable.png
	rm -rf $(ICONS_DIR)
	rm -rf $(PUBLIC_DIR)/og.jpg
	rm -rf $(PUBLIC_DIR)/og.webp
	rm -rf $(SOCIAL_DIR)
	rm -rf ./temp-og.png

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
	npm exec --ignore-scripts -- stylelint --fix ./**/*.{sass,scss,css}

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
	npm exec --ignore-scripts -- stylelint ./**/*.{sass,scss,css}

.PHONY: typescript_check
typescript_check: ./node_modules ./tsconfig.json
	npm exec --ignore-scripts -- tsc --noEmit

.PHONY: playwright_test
playwright_test: ./node_modules ./playwright.config.js
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

.PHONY: postcreate
postcreate: install favicons

.PHONY: start serve server dev
start serve server dev: ./node_modules ./package.json ./package-lock.json favicons
	npm exec --ignore-scripts -- webpack-cli serve --mode=${NODE_ENV} --config-node-env=${NODE_ENV} --env APP_ENV=${APP_ENV}

.PHONY: image
image:
	docker compose -f ./docker-compose.yml -f ./docker-compose-swarm.yml build --pull --push

.PHONY: deploy
deploy:
	docker stack deploy -c ./docker-compose.yml -c ./docker-compose-swarm.yml --with-registry-auth --prune --detach=false --resolve-image=always ${CI_PROJECT_PATH_SLUG:-template-express-api}

.PHONY: up
up:
	docker compose -f ./docker-compose.yml -f ./docker-compose-swarm.yml up --build --remove-orphans --always-recreate-deps --force-recreate --pull=always --renew-anon-volumes

.PHONY: down
down:
	docker compose -f ./docker-compose.yml -f ./docker-compose-swarm.yml down --remove-orphans

.PHONY: password
password:
	@tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 32

.PHONY: secret
secret:
	@tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 64

.PHONY: devcontainer
devcontainer:
	devcontainer up
	devcontainer exec /bin/bash || true
	docker compose -f ./docker-compose.yml -f ./docker-compose-devcontainer.yml down --remove-orphans

.PHONY: build
build: favicons
	npm exec --ignore-scripts -- webpack-cli build --mode=${NODE_ENV} --config-node-env=${NODE_ENV} --env APP_ENV=${APP_ENV}

.PHONY: og
og: ./node_modules ./assets/og.html $(ICON_SRC)
	rm -f ./temp-og.png
	rm -f $(PUBLIC_DIR)/og.jpg $(PUBLIC_DIR)/og.webp
	mkdir -p $(SOCIAL_DIR)
	mkdir -p $(dir $(OG_OUTPUT))
	npm exec --ignore-scripts -- playwright screenshot --browser=chromium --color-scheme=light --viewport-size=$(OG_VIEWPORT_SIZE) --wait-for-selector='html[data-og-ready="true"]' --timeout=60000 file://${CURDIR}/assets/og.html ./temp-og.png
	magick ./temp-og.png -background '$(OG_BG)' -alpha remove -alpha off -colorspace sRGB -strip png32:$(OG_OUTPUT)
	rm ./temp-og.png

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
production: og
	${MAKE} build

.PHONY: favicons
favicons: $(ICON_SRC)
	rm -f $(PUBLIC_DIR)/favicon-16x16.png $(PUBLIC_DIR)/favicon-32x32.png $(PUBLIC_DIR)/favicon-48x48.png
	rm -f $(PUBLIC_DIR)/icon-192x192.png $(PUBLIC_DIR)/icon-192x192-maskable.png $(PUBLIC_DIR)/icon-512x512.png $(PUBLIC_DIR)/icon-512x512-maskable.png
	mkdir -p $(ICONS_DIR)
	magick -background none -density 1024 $(ICON_SRC) -alpha on -define icon:auto-resize=48,32,16 $(PUBLIC_DIR)/favicon.ico
	magick -background none -density 1024 $(ICON_SRC) -alpha on -resize 96x96 -strip png32:$(PUBLIC_DIR)/favicon-96x96.png
	cp $(ICON_SRC) $(PUBLIC_DIR)/favicon.svg
	@$(call render_app_icon,180,$(APP_ICON_LOGO_180),$(PUBLIC_DIR)/apple-touch-icon.png)
	@$(call render_app_icon,192,$(APP_ICON_LOGO_192),$(ICONS_DIR)/icon-192x192.png)
	@$(call render_app_icon,512,$(APP_ICON_LOGO_512),$(ICONS_DIR)/icon-512x512.png)
	@$(call render_app_icon,1024,$(APP_ICON_LOGO_1024),$(ICONS_DIR)/icon-1024x1024.png)
	magick -size 192x192 canvas:'$(MASKABLE_ICON_BG)' \( +size -background none -density 1024 $(ICON_SRC) -alpha on -resize $(MASKABLE_LOGO_192)x$(MASKABLE_LOGO_192)\! \) -gravity center -geometry $(MASKABLE_ICON_OFFSET) -composite -strip png32:$(ICONS_DIR)/maskable-icon-192x192.png
	magick -size 512x512 canvas:'$(MASKABLE_ICON_BG)' \( +size -background none -density 1024 $(ICON_SRC) -alpha on -resize $(MASKABLE_LOGO_512)x$(MASKABLE_LOGO_512)\! \) -gravity center -geometry $(MASKABLE_ICON_OFFSET) -composite -strip png32:$(ICONS_DIR)/maskable-icon-512x512.png
	magick -size 1024x1024 canvas:'$(MASKABLE_ICON_BG)' \( +size -background none -density 1024 $(ICON_SRC) -alpha on -resize $(MASKABLE_LOGO_1024)x$(MASKABLE_LOGO_1024)\! \) -gravity center -geometry $(MASKABLE_ICON_OFFSET) -composite -strip png32:$(ICONS_DIR)/maskable-icon-1024x1024.png

.PHONY: playwright_failed
playwright_failed: ./node_modules ./playwright.config.js
	npm exec --ignore-scripts -- playwright test --last-failed

.PHONY: playwright_headed
playwright_headed: ./node_modules ./playwright.config.js
	npm exec --ignore-scripts -- playwright test --headed

.PHONY: playwright_ui
playwright_ui: ./node_modules ./playwright.config.js
	npm exec --ignore-scripts -- playwright test --ui

# Dependencies
./package-lock.json ./node_modules: ./package.json
	${MAKE} npm_update
