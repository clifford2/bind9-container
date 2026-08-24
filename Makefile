# Makefile for building BIND 9 container image
#
# SPDX-FileCopyrightText: © 2025 Clifford Weinmann <https://www.cliffordweinmann.com/>
# SPDX-License-Identifier: MIT-0
#
# To log in to registry before pushing, run:
#   make push REGISTRY_NAME=ghcr.io REGISTRY_USER=clifford2 REPOBASE=ghcr.io/clifford2


### UPDATING THIS IMAGE ###
# For the latest version, see <https://www.isc.org/download/>.
# For the latest ISC Dockerfile, see <https://gitlab.isc.org/isc-projects/bind9-docker/-/tree/v9.20>.
# Note that the default branch isn't necessarily the latest.
#
# Compare the ISC Dockerfile to ours, get the `BIND9_VERSION` and `BIND9_CHECKSUM` values from there, and update them in our `Makefile`.
#
# To verify GPG signatures, we use the signing key from
# <https://www.isc.org/docs/isc-keyblock.asc>.
# Obtained via: <https://www.isc.org/pgpkey/>

BIND9_MINOR_VER := 9.20
BIND9_PATCH_VER := 27
BUILD_NR := 1
BIND9_VERSION := $(BIND9_MINOR_VER).$(BIND9_PATCH_VER)
# From https://gitlab.isc.org/isc-projects/bind9-docker/-/blob/v9.20/Dockerfile
BIND9_CHECKSUM := 145ab7a50b33a06d9d488b5e668c887e754f42acf8954e2b5dc7e238b080e4a0

# Use podman or docker?
ifeq ($(shell command -v podman 2> /dev/null),)
	CONTAINER_ENGINE := docker
else
	CONTAINER_ENGINE := podman
endif

# Add date into release version to distinguish between image differences resulting from `apk update` & `apk upgrade` steps
IMAGE_RELEASE := $(BUILD_NR).$(shell TZ=UTC date '+%Y%m%d')
IMAGE_VERSION := $(BIND9_VERSION)-$(IMAGE_RELEASE)
GIT_REVISION := $(shell git rev-parse @)
BUILD_DATE := $(shell TZ=UTC date '+%Y-%m-%d')
BUILD_TIME := $(shell TZ=UTC date '+%Y-%m-%dT%H:%M:%SZ')

# REGISTRY_NAME := ghcr.io
# REGISTRY_USER := clifford2
# REPOBASE := $(REGISTRY_NAME)/$(REGISTRY_USER)
IMGBASENAME := bind9
IMGRELNAME := $(REPOBASE)/$(IMGBASENAME)

.PHONY: help
help:
	@echo "No default target configured - please specify the desired target:"
	@echo ""
	@echo "  build-dev:  Builds a development image ($(IMGBASENAME):dev)"
	@echo "  test-dev:   Runs some basic tests against the dev image"
	@echo "  build:      Builds the image ($(IMGBASENAME):$(IMAGE_VERSION))"
	@echo "  push:       Tag & push the image"
	@echo "  all:        Build, tag & push the image"
	@test -z "$(REPOBASE)" || echo "  push:   Tags & pushes the image ($(IMGRELNAME):$(IMAGE_VERSION))"


# Build image for testing
.PHONY: build-dev
build-dev: .check-depends .download-src
	$(CONTAINER_ENGINE) build --build-arg BIND9_VERSION=$(BIND9_VERSION) --build-arg IMAGE_VERSION=$(IMAGE_VERSION) --build-arg BIND9_CHECKSUM=$(BIND9_CHECKSUM) --build-arg GIT_REVISION=$(GIT_REVISION) --build-arg BUILD_DATE=$(BUILD_DATE) --build-arg BUILD_TIME=$(BUILD_TIME) -t $(IMGBASENAME):dev .

# Test the image
.PHONY: test-dev
test-dev:
	@chmod 0755 testconfig
	@chmod 0644 testconfig/*
	$(CONTAINER_ENGINE) run --rm -d --replace --name bind-test -e IPV4ONLY=y -v ./testconfig:/etc/bind:ro,Z $(IMGBASENAME):dev
	$(CONTAINER_ENGINE) exec -it bind-test dig -p 5353 @127.0.0.1 -t A localhost.
	# $(CONTAINER_ENGINE) exec -it bind-test dig -p 5353 @127.0.0.1 -t SOA localhost.
	# $(CONTAINER_ENGINE) exec -it bind-test /usr/sbin/rndc stop
	$(CONTAINER_ENGINE) stop bind-test

# Build image for release
.PHONY: build
build: .check-depends .download-src
	$(CONTAINER_ENGINE) build --build-arg BIND9_VERSION=$(BIND9_VERSION) --build-arg IMAGE_VERSION=$(IMAGE_VERSION) --build-arg BIND9_CHECKSUM=$(BIND9_CHECKSUM) --build-arg GIT_REVISION=$(GIT_REVISION) --build-arg BUILD_DATE=$(BUILD_DATE) --build-arg BUILD_TIME=$(BUILD_TIME) -t $(IMGBASENAME):$(IMAGE_VERSION) .
	$(CONTAINER_ENGINE) run --rm $(IMGBASENAME):$(IMAGE_VERSION) -V

.PHONY: tag
tag: .check-depends
	$(CONTAINER_ENGINE) tag $(IMGBASENAME):$(IMAGE_VERSION) $(IMGRELNAME):$(IMAGE_VERSION)
	$(CONTAINER_ENGINE) tag $(IMGBASENAME):$(IMAGE_VERSION) $(IMGRELNAME):$(BIND9_VERSION)
	$(CONTAINER_ENGINE) tag $(IMGBASENAME):$(IMAGE_VERSION) $(IMGRELNAME):$(BIND9_MINOR_VER)

.PHONY: push
push: tag
	test ! -z "$(REGISTRY_NAME)" && $(CONTAINER_ENGINE) login -u $(REGISTRY_USER) $(REGISTRY_NAME)|| echo 'Not logging into registry'
	$(CONTAINER_ENGINE) push $(IMGRELNAME):$(IMAGE_VERSION)
	$(CONTAINER_ENGINE) push $(IMGRELNAME):$(BIND9_VERSION)
	$(CONTAINER_ENGINE) push $(IMGRELNAME):$(BIND9_MINOR_VER)

.PHONY: all
all: build push

# git tag with current APP_VERSION
.PHONY: .git-tag
.git-tag: .check-git-deps
	@git tag -m "Version $(IMAGE_VERSION)" $(IMAGE_VERSION)

# git push
.PHONY: .git-push
.git-push: .check-git-deps
	@git push --follow-tags

# git tag & push
.PHONY: git-tag-push
git-tag-push: .git-tag .git-push

# Verify that we have git installed
.PHONY: .check-git-deps
.check-git-deps:
	command -v git

# Verify that we have all required dependencies installed
.PHONY: .check-depends
.check-depends:
	command -v podman || command -v docker
	command -v curl

# Download BIND 9 source code
.PHONY: .download-src
.download-src:
	@test -f downloads/isc-keyblock.asc || curl --output downloads/isc-keyblock.asc https://www.isc.org/docs/isc-keyblock.asc
	@test -f downloads/bind-${BIND9_VERSION}.tar.xz.asc || curl --output downloads/bind-${BIND9_VERSION}.tar.xz.asc https://downloads.isc.org/isc/bind9/${BIND9_VERSION}/bind-${BIND9_VERSION}.tar.xz.asc
	@test -f downloads/bind-${BIND9_VERSION}.tar.xz || curl --output downloads/bind-${BIND9_VERSION}.tar.xz https://downloads.isc.org/isc/bind9/${BIND9_VERSION}/bind-${BIND9_VERSION}.tar.xz
