# Internet Systems Consortium BIND 9 DNS Server

ISC [BIND](https://www.isc.org/bind/) (Berkeley Internet Name Domain) container image.

This code is based on the [ISC](https://www.isc.org/)'s Dockerfile at
[gitlab.isc.org/isc-projects/bind9-docker](https://gitlab.isc.org/isc-projects/bind9-docker/-/tree/v9.20).

The [ISC](https://www.isc.org/) also build these images, and make them available at
[`docker.io/internetsystemsconsortium/bind9`](https://hub.docker.com/r/internetsystemsconsortium/bind9).

Their images are tagged with major and minor versions only.

I'm rebuilding the image *only* so I can tag them with patch version
numbers too, and manage which exact version I'm running.
