SHELL := /bin/bash
.DEFAULT_GOAL := help
ROOT_PATH := $(abspath $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST))))))
CONFIG_PATH := $(ROOT_PATH)/config
HOME_PATH ?= $(ROOT_PATH)/.local
BIN_PATH := $(HOME_PATH)/bin
PROFILE_PATH ?= $(ROOT_PATH)/profiles
INSTALL_PATH := $(BIN_PATH)
TEMP_PATH := $(HOME_PATH)/tmp
APP_PATH := $(HOME_PATH)/apps
SCRIPT_PATH ?= $(ROOT_PATH)/scripts
DEPLOY_PATH ?= $(ROOT_PATH)/deploy
PROFILE ?= default

yq := $(BIN_PATH)/yq
jq := $(BIN_PATH)/jq
terraform := $(BIN_PATH)/terraform

# Import target deployment env vars
ENVIRONMENT_VARS ?= $(PROFILE_PATH)/profile.$(PROFILE).env
ifneq (,$(wildcard $(ENVIRONMENT_VARS)))
include ${ENVIRONMENT_VARS}
export $(shell sed 's/=.*//' ${ENVIRONMENT_VARS})
endif

SECRETS ?= $(ROOT_PATH)/.SECRET.env
ifneq (,$(wildcard $(SECRETS)))
include ${SECRETS}
export $(shell sed 's/=.*//' ${SECRETS})
endif

.PHONY: .dep/githubapps
.dep/githubapps: ## Install githubapp (ghr-installer)
ifeq (,$(wildcard $(APP_PATH)/githubapp))
	@rm -rf $(APP_PATH)
	@mkdir -p $(APP_PATH)
	@git clone https://github.com/zloeber/ghr-installer $(APP_PATH)/githubapp
endif

.PHONY: .dep/yq
.dep/yq: ## Install yq
ifeq (,$(wildcard $(yq)))
	@$(MAKE) --no-print-directory -C $(APP_PATH)/githubapp auto mikefarah/yq INSTALL_PATH=$(BIN_PATH)
endif

.PHONY: .dep/jq
.dep/jq: ## Install jq
ifeq (,$(wildcard $(jq)))
	@$(MAKE) --no-print-directory -C $(APP_PATH)/githubapp install jq INSTALL_PATH=$(BIN_PATH)
endif

.PHONY: .dep/terraform
.dep/jq: ## Install terraform
ifeq (,$(wildcard $(terraform)))
	@$(MAKE) --no-print-directory -C $(APP_PATH)/githubapp install terraform INSTALL_PATH=$(BIN_PATH)
endif

.PHONY: deps
deps: .dep/githubapps $(DEPTASKS) .dep/yq .dep/jq .dep/terraform ## Install general dependencies
	@mkdir -p $(TEMP_PATH)

.PHONY: clean
clean: ## Remove downloaded dependencies
	@rm -rf $(APP_PATH)/githubapp
	@rm -rf $(INSTALL_PATH)/*
	@rm -rf $(ROOT_PATH)/deploy/.terraform
	@rm -rf $(ROOT_PATH)/deploy/terraform.tfstate*
