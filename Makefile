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


# Use podman or docker?
ifeq ($(shell command -v podman 2> /dev/null),)
	CONTAINER_ENGINE := docker
else
	CONTAINER_ENGINE := podman
endif

IMAGE_NAME := bind9
BIND9_MINOR_VER := 9.20
BIND9_PATCH_VER := 16
IMAGE_RELEASE := 1
BIND9_VERSION := $(BIND9_MINOR_VER).$(BIND9_PATCH_VER)
BIND9_CHECKSUM := 03ffcc7a4fcb7c39b82b34be1ba2b59f6c191bc795c5935530d5ebe630a352d6
IMAGE_VERSION := $(BIND9_VERSION)-$(IMAGE_RELEASE)
ALPINE_VERSION := 3.22.2

# REGISTRY_NAME := ghcr.io
# REGISTRY_USER := clifford2
# REPOBASE := $(REGISTRY_NAME)/$(REGISTRY_USER)
IMGBASENAME := bind9
IMGRELNAME := $(REPOBASE)/$(IMGBASENAME)

.PHONY: help
help:
	@echo "No default target configured - please specify the desired target:"
	@echo ""
	@echo "  build:  Builds the image ($(IMGBASENAME):$(IMAGE_VERSION))"
	@echo "  push:   Tags & pushes the image ($(IMGRELNAME):$(IMAGE_VERSION))"


.PHONY: build
build:
	$(CONTAINER_ENGINE) build --build-arg ALPINE_VERSION=$(ALPINE_VERSION) --build-arg BIND9_VERSION=$(BIND9_VERSION) --build-arg IMAGE_VERSION=$(IMAGE_VERSION) --build-arg BIND9_CHECKSUM=$(BIND9_CHECKSUM) -t $(IMGBASENAME):$(IMAGE_VERSION) .

.PHONY: tag
tag:
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
