# MailCatcher Container Build

This image can easily be built by either `podman` or `docker`.

## Bump Versions

After any change, please increment the `RELEASE_VERSION` in the `.env` file,
and run (optional - also a dependency for `make git-push`):

```sh
make fixtags
```

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

Alternately, build with docker:

```sh
make CONTAINER_ENGINE=docker build
```

## Publish

Publish new source (fix tags, commit, tag, push) with these commands:

```sh
make git-commit-push
```

Publish the new image to GitHub Container Registry:

```sh
podman login -i clifford2 ghcr.io
make REPOBASE=ghcr.io/clifford2 push
```

## More Information

See [`README.md`](README.md) for more details.
