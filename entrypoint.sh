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

# In a rootless podman container, `rndc stop` works, while `podman stop`
# doesn't if named is running in the foreground (as PID 1 or as child of
# this script, but not in the background)
trap 'echo "Received SIGTERM; Shutting down gracefully..."; /usr/sbin/rndc stop; exit 0' TERM
trap 'echo "Received SIGINT; Shutting down gracefully..."; /usr/sbin/rndc stop; exit 0' INT
# DEBUG - show traps: # trap

NAMED_ARGS="-u bind"
if [ "${IPV4ONLY}" = "y" ]
then
	NAMED_ARGS="${NAMED_ARGS} -4"
fi
if [ "${IPV6ONLY}" = "y" ]
then
	NAMED_ARGS="${NAMED_ARGS} -6"
fi

set -x
/usr/sbin/named ${NAMED_ARGS} "$@" &
wait
