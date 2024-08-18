#!/bin/bash
# Call using build.sh version previous_version (using just the number)
# e.g.
# build.sh 2.0.5 2.0.4
export QUAY_ID=rhpds
export OPERATOR_VERSION=v${1}
# No v in front of the Bundle version
export BUNDLE_VERSION=${1}
export CATALOG_VERSION=v${1}
export CATALOG_VERSION_PREVIOUS=v${2}

make docker-build IMG=quay.io/$QUAY_ID/gitea-operator:$OPERATOR_VERSION

make docker-push IMG=quay.io/$QUAY_ID/gitea-operator:$OPERATOR_VERSION

make bundle CHANNELS=stable DEFAULT_CHANNEL=stable VERSION=$BUNDLE_VERSION IMG=quay.io/$QUAY_ID/gitea-operator:$OPERATOR_VERSION
make bundle-build BUNDLE_CHANNELS=stable BUNDLE_DEFAULT_CHANNEL=stable VERSION=$BUNDLE_VERSION BUNDLE_IMG=quay.io/$QUAY_ID/gitea-operator-bundle:v$BUNDLE_VERSION

podman push quay.io/$QUAY_ID/gitea-operator-bundle:v$BUNDLE_VERSION
operator-sdk bundle validate quay.io/$QUAY_ID/gitea-operator-bundle:v$BUNDLE_VERSION
# Next line for new build
#opm index add --bundles quay.io/$QUAY_ID/gitea-operator-bundle:v$BUNDLE_VERSION --tag quay.io/$QUAY_ID/gitea-catalog:latest

# Next line for replacement with new version
opm index add --from-index quay.io/$QUAY_ID/gitea-catalog:$CATALOG_VERSION_PREVIOUS --bundles quay.io/$QUAY_ID/gitea-operator-bundle:v$BUNDLE_VERSION --tag quay.io/$QUAY_ID/gitea-catalog:$CATALOG_VERSION

podman tag quay.io/$QUAY_ID/gitea-catalog:$CATALOG_VERSION quay.io/$QUAY_ID/gitea-catalog:latest
podman push quay.io/$QUAY_ID/gitea-catalog:latest
podman push quay.io/$QUAY_ID/gitea-catalog:$CATALOG_VERSION
