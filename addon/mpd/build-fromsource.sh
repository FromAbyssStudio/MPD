#!/usr/bin/env bash
# Build the MPD add-on image from this repo (your modified MPD).
# Run from the repo root. For HA Yellow use aarch64.
#
# Usage:
#   ./addon/mpd/build-fromsource.sh [arch]
#   arch: aarch64 (HA Yellow), amd64, armhf, armv7, i386 (default: aarch64)
#
# Then push to your container registry and set addon/mpd/config.yaml image:
#   image: ghcr.io/YOUR_USERNAME/mpd-{arch}

set -e
ARCH="${1:-aarch64}"
IMAGE="${IMAGE:-ghcr.io/${GITHUB_REPOSITORY_OWNER:-local}/mpd}"

# HA uses alpine-based BUILD_FROM; match common version
BUILD_FROM="alpine:3.19"
echo "Building MPD from source for $ARCH (BUILD_FROM=$BUILD_FROM)"
echo "Image: $IMAGE-$ARCH"
echo ""

if docker buildx version >/dev/null 2>&1; then
  docker buildx build -f addon/mpd/Dockerfile.fromsource \
    --build-arg BUILD_FROM="$BUILD_FROM" \
    --platform "linux/$ARCH" \
    --load \
    -t "$IMAGE-$ARCH" .
else
  docker build -f addon/mpd/Dockerfile.fromsource \
    --build-arg BUILD_FROM="$BUILD_FROM" \
    --platform "linux/$ARCH" \
    -t "$IMAGE-$ARCH" .
fi

echo ""
echo "Built $IMAGE-$ARCH"
echo "Push with: docker push $IMAGE-$ARCH"
echo "Then in addon/mpd/config.yaml set: image: $IMAGE-{arch}"
