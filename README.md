# olivetin-docker-lite

A lightweight [OliveTin](https://github.com/OliveTin/OliveTin) image: **~50 MB** instead of
~445 MB for the official image.

Contents: Alpine + OliveTin binary + web UI + `bash` + `openssh-client` (+ busybox).
No docker CLI, kubectl, Python/apprise or git. Suited to actions that run shell scripts
or commands over SSH.

## Image

`ghcr.io/loorisr/olivetin-lite:latest` or `ghcr.io/loorisr/olivetin-lite:<OliveTin version>`
(linux/amd64, linux/arm64).

## Automated builds

A GitHub Action checks the latest OliveTin release every day and builds the image
if that tag does not exist on GHCR yet. It can also be triggered manually (`workflow_dispatch`).
The binary is verified against the release's `checksums.txt`.

## Local build

```sh
docker build --build-arg OLIVETIN_VERSION=3000.22.0 -t olivetin-lite .
# extra Alpine packages:
docker build --build-arg OLIVETIN_VERSION=3000.22.0 --build-arg EXTRA_PACKAGES="curl jq" -t olivetin-lite .
```

## Deployment

See `compose.yaml` (read-only filesystem, `cap_drop: ALL`, `no-new-privileges`, user 1000).
