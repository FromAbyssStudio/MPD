#!/usr/bin/env bash
# Build the MPD add-on image from this repo and push to GitHub Container Registry.
# Run from the repo root. For HA Yellow use aarch64.
#
# Usage:
#   ./addon/mpd/build-and-push.sh [arch] [ghcr_username]
#
# Examples:
#   ./addon/mpd/build-and-push.sh                    # aarch64, user from gh
#   ./addon/mpd/build-and-push.sh aarch64 toymak3r    # HA Yellow, your GHCR
#   ./addon/mpd/build-and-push.sh amd64              # amd64, user from gh
#
# Requires: Docker, gh CLI (gh auth login). First time: gh auth refresh -s write:packages

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$REPO_ROOT"

ARCH="${1:-aarch64}"
GHR_USER="${2:-${GITHUB_USERNAME}}"
if [ -z "$GHR_USER" ]; then
  if command -v gh >/dev/null 2>&1; then
    GHR_USER="$(gh api user -q .login)"
  else
    echo "Error: gh not found. Set GITHUB_USERNAME or pass username: $0 [arch] [ghcr_username]"
    exit 1
  fi
fi

IMAGE="ghcr.io/${GHR_USER}/mpd"
IMAGE_TAG="${IMAGE}-${ARCH}"

echo "=== MPD add-on: build and push ==="
echo "  arch:    $ARCH"
echo "  image:   $IMAGE_TAG"
echo "  repo:    $REPO_ROOT"
echo ""

# Ensure gh has package write scope
if command -v gh >/dev/null 2>&1; then
  echo ">>> Refreshing gh token (write:packages)..."
  gh auth refresh -s write:packages || true
  echo ">>> Logging in to ghcr.io..."
  gh auth token | docker login ghcr.io -u "$GHR_USER" --password-stdin
else
  echo ">>> gh not found; skipping docker login. Ensure you're already logged in to ghcr.io."
fi

echo ""
echo ">>> Building..."
export IMAGE="$IMAGE"
"$SCRIPT_DIR/build-fromsource.sh" "$ARCH"

echo ""
echo ">>> Pushing $IMAGE_TAG ..."
docker push "$IMAGE_TAG"

echo ""
echo "Done. Ensure addon/mpd/config.yaml has:"
echo "  image: $IMAGE-{arch}"
echo ""
echo "Then in Home Assistant: Add-ons → Repositories → add your repo URL (e.g. https://github.com/FromAbyssStudio/MPD) → Install MPD → Start → Add MPD integration (127.0.0.1:6600)."
