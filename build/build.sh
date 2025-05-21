#!/bin/bash

# This script builds a multi-architecture Docker image for LXDE with VNC support for local use.

set -e

# Create and use a builder if not already
docker buildx inspect mybuilder >/dev/null 2>&1 || docker buildx create --name mybuilder --use
docker buildx use mybuilder

# Build multi-arch image for local use
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --tag lxde-vnc:latest \
  --load .

# Run the image locally
docker run -d --rm -p 6080:6080 -p 5900:5900 --name mylxde lxde-vnc:latest