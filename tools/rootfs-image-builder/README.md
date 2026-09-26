# CX Agent Extended rootfs (offline-first base image)

**Problem:** every new workspace today extracts a bare `ubuntu-base` archive, then
`RootfsInstaller.bootstrapEssentialTools()` runs `apt-get update` + several installs over the
phone's network to add curl/git/node/npm/python/build-essential/etc. That's slow and needs
internet at exactly the moment someone is trying to start working.

**Fix (this folder):** pre-bake those same packages into an Ubuntu 24.04 arm64 image, export it
as a `.tar.gz` (the same archive format the app already extracts), and host it as a GitHub
Release asset. New workspaces then extract one bigger archive instead of downloading a small one
+ running apt-get.

The app already knows how to skip apt-get automatically: `bootstrapEssentialTools()` now runs a
quick `command -v` check for every tool it would otherwise install, and if they're all already on
PATH it marks the step DONE instantly with no network call. So this "extended" image doesn't need
any special flag — it just needs to genuinely contain those tools.

## One-time setup

1. Create a (can be private) GitHub repo to host the release, e.g. `cxagent-rootfs`.
2. Build the image, either way:
   - **No local Docker:** push this folder's contents (or just enable Actions) and run the
     included workflow — `.github/workflows/build-rootfs.yml` — from the Actions tab
     ("Run workflow"). It builds and publishes the release for you.
   - **Local Docker:** `./build.sh` (needs buildx + QEMU for the arm64 cross-build — see
     comments at the top of the script), then upload the resulting
     `cxagent-extended-rootfs-arm64.tar.gz` as a GitHub Release asset by hand.
3. Copy the asset's download URL (Release page → asset → right-click → copy link).
4. Paste it into `EXTENDED_ROOTFS_URL` in
   `workspace/src/main/java/com/cx/agent/workspace/RootfsSupport.kt`.
5. Rebuild the app. The picker (`RootfsSourcePicker.kt`) now shows "CX Agent Extended
   (offline-ready)" as a one-tap preset — installing it needs no apt-get at all.

## Keeping it in sync

If you ever change the package list in `RootfsInstaller.kt`'s `BOOTSTRAP_STEPS`, update
`Dockerfile` here to match, then re-run the workflow (or `build.sh`) to publish a new asset and
update `EXTENDED_ROOTFS_URL` to the new URL/tag.

## Why arm64 only

Workspaces run on-device via proot, so the rootfs architecture must match the phone's CPU
(arm64/aarch64), same as the existing `ubuntu-base` presets in `RootfsPresets`.
