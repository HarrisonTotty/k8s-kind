#!/usr/bin/env bash
# A handy script to push all local docker images to the kind registry.

set -e
trap 'exit 100' INT

REGISTRY="localhost:5000"

no_dangling=$(docker image ls --filter 'dangling=false' --format '{{.Repository}}:{{.Tag}}')

no_untagged=$(echo "$no_dangling" | grep -v '<none>' | xargs)

for img in $no_untagged; do
    echo "Pushing ${img}..."
    base_name=$(echo "$img" | awk -F '/' '{ print $NF }')
    docker tag "$img" "${REGISTRY}/${base_name}" || true
    docker push "${REGISTRY}/${base_name}" || true
done
