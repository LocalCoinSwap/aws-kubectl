#!/bin/sh

set -e

echo "$KUBE_CONFIG_DATA" | base64 -d > /tmp/config
export KUBECONFIG=/tmp/config

sh -c "kubectl $*"
