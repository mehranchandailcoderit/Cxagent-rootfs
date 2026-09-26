# syntax=docker/dockerfile:1
#
# Builds the "CX Agent Extended" rootfs: the same Ubuntu 24.04 (arm64) base the app already
# downloads, but with the exact tool set that RootfsInstaller.kt's bootstrapEssentialTools()
# would otherwise install via apt-get on the phone at first-boot time.
#
# IMPORTANT: keep this package list in sync with BOOTSTRAP_STEPS in
# workspace/src/main/java/com/cx/agent/workspace/RootfsInstaller.kt. If you add/remove a
# package there, update it here too, then rebuild and re-publish (see build.sh / README.md).
FROM --platform=linux/arm64 ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq && \
    apt-get install -y -qq --no-install-recommends \
        curl ca-certificates git \
        nodejs \
        npm \
        python3 python3-pip python3-venv \
        build-essential pkg-config \
        openssh-client \
        unzip wget jq vim nano && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
