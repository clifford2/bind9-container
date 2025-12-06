#!/bin/sh

# Create working directory
test -d /var/cache/bind || mkdir -p /var/cache/bind
chown bind:bind /var/cache/bind && chmod 02755 /var/cache/bind

# Create directory to store secondary zones
test -d /var/lib/bind || mkdir -p /var/lib/bind
chown bind:bind /var/lib/bind && chmod 02755 /var/lib/bind

# Create log directory
test -d /var/log/bind || mkdir -p /var/log/bind
chown bind:bind /var/log/bind && chmod 02755 /var/log/bind

# trap SIGTERM & SIGINT
# This should not be necessary
# In a rootless podman container, `rndc stop` works, while `podman stop` doesn't, but this trap didn't fire, so didn't solve the problem
trap 'echo "Shutting down gracefully..."; /usr/sbin/rndc stop; exit 0' 15 2

set -x
exec /usr/sbin/named -u bind "$@"
