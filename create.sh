#!/usr/bin/env bash
# A handy utility script to create a new local kubernetes cluster.

set -e
trap 'exit 100' INT

if [ "$#" -ne 2 ]; then
    echo 'USAGE: ./create.sh <cluster-name> <output-config-path>'
    echo 'EXAMPLE: ./create.sh local ~/k8s-local.conf'
    exit 0
fi

cluster_name="$1"
output_config="$2"

if [ ! -f config.yaml ]; then
    echo 'Unable to find config.yaml'
    exit 1
fi

REGISTRY_NAME='kind-registry'
REGISTRY_PORT='5000'

registry_status=$(docker inspect -f '{{.State.Running}}' "$REGISTRY_NAME" 2>/dev/null || true)

if [ "$registry_status" != "true" ]; then
    echo 'Creating local docker registry...'
    docker run \
        -d \
        --restart always \
        -p "127.0.0.1:${REGISTRY_PORT}:5000" \
        --name "$REGISTRY_NAME" \
        registry:2
fi

if [ -f "$output_config" ]; then
    rm "$output_config"
fi

echo 'Creating cluster...'
kind create cluster --config config.yaml --name "$cluster_name" --kubeconfig "$output_config"
export KUBECONFIG="$output_config"

echo 'Connecting cluster network...'
docker network connect 'kind' "$REGISTRY_NAME" || true

echo 'Documenting local registry...'
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: local-registry-hosting
  namespace: kube-public
data:
  localRegistryHosting.v1: |
    host: "localhost:${REGISTRY_PORT}"
    help: "https://kind.sigs.k8s.io/docs/user/local-registry/"
EOF

echo 'Installing ingress controller...'
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
