# olivetin-docker-lite

Image [OliveTin](https://github.com/OliveTin/OliveTin) allégée : **~50 Mo** au lieu de ~445 Mo
pour l'image officielle.

Contenu : Alpine + binaire OliveTin + webui + `bash` + `openssh-client` (+ busybox).
Pas de docker CLI, kubectl, Python/apprise ni git. Convient aux actions qui lancent
des scripts shell ou des commandes via SSH.

## Image

`ghcr.io/loorisr/olivetin-lite:latest` ou `ghcr.io/loorisr/olivetin-lite:<version OliveTin>`
(linux/amd64, linux/arm64).

## Build automatique

La GitHub Action vérifie chaque jour la dernière release d'OliveTin et construit l'image
si ce tag n'existe pas encore sur GHCR. Lancement manuel possible (`workflow_dispatch`).
Le binaire est vérifié avec le `checksums.txt` de la release.

## Build local

```sh
docker build --build-arg OLIVETIN_VERSION=3000.22.0 -t olivetin-lite .
# paquets Alpine en plus :
docker build --build-arg OLIVETIN_VERSION=3000.22.0 --build-arg EXTRA_PACKAGES="curl jq" -t olivetin-lite .
```

## Déploiement

Voir `compose.yaml` (lecture seule, `cap_drop: ALL`, `no-new-privileges`, utilisateur 1000).
