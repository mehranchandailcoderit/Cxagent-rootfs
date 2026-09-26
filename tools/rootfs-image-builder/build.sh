#!/usr/bin/env bash
set -euo pipefail
#
# Builds and exports the CX Agent Extended rootfs as a .tar.gz — the same archive format
# RootfsInstaller.kt already knows how to extract (see RootfsInstaller.ArchiveFormat).
# Upload the result as a GitHub Release asset, then paste its download URL into
# RootfsPresets.EXTENDED_ROOTFS_URL (workspace/.../RootfsSupport.kt).
#
# Requires: Docker with buildx + QEMU for cross-building arm64.
#   - Docker Desktop (Mac/Windows): already includes both, nothing to do.
#   - Plain Linux (e.g. a local Ubuntu box): run once first —
#       docker run --privileged --rm tonistiigi/binfmt --install arm64
#
# You do NOT need this script at all if you use the GitHub Actions workflow instead
# (.github/workflows/build-rootfs.yml) — that runs the same steps in CI.

cd "$(dirname "$0")"

IMAGE_TAG="cxagent-extended-rootfs-builder"
OUTPUT="cxagent-extended-rootfs-arm64.tar.gz"
CONTAINER_NAME="cxagent-extended-rootfs-export"

echo "==> Building arm64 image (this cross-builds under QEMU, so it's slower than a native build)..."
docker buildx build --platform linux/arm64 -t "$IMAGE_TAG" --load .

echo "==> Creating throwaway container to export its filesystem..."
docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
docker create --platform linux/arm64 --name "$CONTAINER_NAME" "$IMAGE_TAG" /bin/true >/dev/null

echo "==> Exporting filesystem to $OUTPUT..."
docker export "$CONTAINER_NAME" | gzip -9 > "$OUTPUT"

docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true

echo
echo "==> Done: $(pwd)/$OUTPUT ($(du -h "$OUTPUT" | cut -f1))"
echo "Next: upload this file as a GitHub Release asset, then update"
echo "RootfsPresets.EXTENDED_ROOTFS_URL in RootfsSupport.kt to point at it."
