#!/bin/bash

# This script builds a multi-architecture support to publish on Docker Hub.

set -e

IMAGE_NAME=jmeiracorbal/lxde-novnc
TAG=${1:-test}

# Create and use a builder if not exists
# docker buildx inspect mybuilder >/dev/null 2>&1 || docker buildx create --name mybuilder --use
# docker buildx use mybuilder

echo "authenticating to Docker Hub..."
docker login

echo "build the multi-arch image and pusblih to Docker Hub..."
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --tag $IMAGE_NAME:$TAG \
  --push \
  ./build

echo "$IMAGE_NAME:$TAG is published on Docker Hub"