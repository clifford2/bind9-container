# BIND 9 Container Build

This image can easily be built by either `podman` or `docker`.

## Build Development Image

Build the image with podman, and run a short test:

```sh
make build-dev
make test-dev
```

## Build Production Image

Build the image with podman:

```sh
make build
```

# Publish

Publish new source (fix tags, commit, tag, push) with these commands:

```sh
git commit -a
make git-commit-push
```

Publish the new image to GitHub Container Registry:

```sh
podman login -u clifford2 ghcr.io
make REPOBASE=ghcr.io/clifford2 push
```

## More Information

See [`README.md`](README.md) for more details.
