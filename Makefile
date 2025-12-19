export KONFLUX_BUILDS=true
FIPS_ENABLED=true
TESTTARGETS=$(shell ${GOENV} go list -e ./... | egrep -v "/(vendor)/" | grep -v /int)
PKO_IMAGE=$(IMAGE_REGISTRY)/$(IMAGE_REPOSITORY)/$(IMAGE_NAME)-pko:$(CURRENT_COMMIT)

include boilerplate/generated-includes.mk

SHELL := /usr/bin/env bash

.PHONY: pko-build
pko-build:
	$(CONTAINER_ENGINE) build -f ./build/Dockerfile.pko -t $(PKO_IMAGE) ./deploy_pko

.PHONY: pko-build-push
pko-build-push: pko-build container-engine-login
	$(CONTAINER_ENGINE) push $(PKO_IMAGE)

.PHONY: pko-validation
pko-validation:
	kubectl package tree --cluster ./deploy/pko
	kubectl package validate ./deploy/pko

.PHONY: boilerplate-update
boilerplate-update:
	@boilerplate/update
