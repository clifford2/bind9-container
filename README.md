# ISC BIND 9 DNS Server

Internet Systems Consortium [BIND](https://www.isc.org/bind/) (Berkeley
Internet Name Domain) container image.

The [ISC](https://www.isc.org/) publishes official container images at
[`docker.io/internetsystemsconsortium/bind9`](https://hub.docker.com/r/internetsystemsconsortium/bind9).
These images are tagged with major and minor version numbers only.

I prefer *reproducable deployments*, which require *immutable tags*.
This repository exists only to produce images with immutable tags.

My code is based on the [ISC](https://www.isc.org/)'s `Dockerfile` at
[gitlab.isc.org/isc-projects/bind9-docker](https://gitlab.isc.org/isc-projects/bind9-docker/-/tree/v9.20),
and there are no material differences between their images and mine
besides the tags.
