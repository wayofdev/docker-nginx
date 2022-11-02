export DOCKER_BUILDKIT ?= 1
IMAGE_NAMESPACE ?= wayofdev/nginx
TEMPLATE ?= dev-alpine

IMAGE_TAG ?= $(IMAGE_NAMESPACE):$(TEMPLATE)-latest
DOCKERFILE_DIR ?= ./dist/$(TEMPLATE)
CACHE_FROM ?= $(IMAGE_TAG)
OS ?= $(shell uname)
CURRENT_DIR ?= $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

ifneq ($(TERM),)
	BLACK := $(shell tput setaf 0)
	RED := $(shell tput setaf 1)
	GREEN := $(shell tput setaf 2)
	YELLOW := $(shell tput setaf 3)
	LIGHTPURPLE := $(shell tput setaf 4)
	PURPLE := $(shell tput setaf 5)
	BLUE := $(shell tput setaf 6)
	WHITE := $(shell tput setaf 7)
	RST := $(shell tput sgr0)
else
	BLACK := ""
	RED := ""
	GREEN := ""
	YELLOW := ""
	LIGHTPURPLE := ""
	PURPLE := ""
	BLUE := ""
	WHITE := ""
	RST := ""
endif
MAKE_LOGFILE = /tmp/docker-nginx.log
MAKE_CMD_COLOR := $(BLUE)

default: all

help:
	@echo 'Management commands for package:'
	@echo 'Usage:'
	@echo '    ${MAKE_CMD_COLOR}make${RST}                       Builds default image and then runs dgoss tests'
	@grep -E '^[a-zA-Z_0-9%-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "    ${MAKE_CMD_COLOR}make %-21s${RST} %s\n", $$1, $$2}'
	@echo
	@echo '    📑 Logs are stored in      $(MAKE_LOGFILE)'
	@echo
	@echo '    📦 Package                 docker-nginx (github.com/wayofdev/docker-nginx)'
	@echo '    🤠 Author                  Andrij Orlenko (github.com/lotyp)'
	@echo '    🏢 ${YELLOW}Org                     wayofdev (github.com/wayofdev)${RST}'
.PHONY: help

all: build test
PHONY: all

build: ## Build default docker image
	cd $(CURRENT_DIR)$(DOCKERFILE_DIR); \
	docker build . -t $(IMAGE_TAG)
PHONY: build

build-from-cache: ## Build default docker image using cached layers
	cd $(CURRENT_DIR)$(DOCKERFILE_DIR); \
	docker build --cache-from $(CACHE_FROM) . -t $(IMAGE_TAG)
PHONY: build-from-cache

test: ## Run dgoss tests over docker images
	set -eux
	GOSS_FILES_STRATEGY=cp GOSS_FILES_PATH=$(DOCKERFILE_DIR) dgoss run --add-host app:127.0.0.1 -t $(IMAGE_TAG)
.PHONY: test

pull: ## Pulls docker image from upstream
	docker pull $(IMAGE_TAG)
.PHONY: pull

push: ## Pushes image to upstream
	docker push $(IMAGE_TAG)
.PHONY: push

ssh: ## Login into built image
	docker run --rm -it -v $(PWD)/:/opt/nginx $(IMAGE_TAG) sh
.PHONY: ssh

hadolint:  ## Run hadolint over dist Dockerfiles
	hadolint -V ./dist/dev-alpine/Dockerfile
	hadolint -V ./dist/k8s-alpine/Dockerfile
.PHONY: hadolint


# Git Actions
# ------------------------------------------------------------------------------------
hooks: ## Install git hooks from pre-commit-config
	pre-commit install
	pre-commit autoupdate
.PHONY: hooks


# Yaml Actions
# ------------------------------------------------------------------------------------
lint: ## Lints yaml files inside project
	yamllint .
.PHONY: lint


# Ansible Actions
# ------------------------------------------------------------------------------------
generate: ## Generate dist files from src folder using ansible playbook
	ansible-playbook src/generate.yml
PHONY: generate

clean: ## Deletes all files in dist folder
	rm -rf ./dist/*
PHONY: clean
