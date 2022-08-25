#!/usr/bin/env bash

set -e

SWIFT_PLATFORM=ubuntu20.04
SWIFT_BRANCH=swift-5.6.2-release
SWIFT_VERSION=swift-5.6.2-RELEASE
SWIFT_WEBROOT=https://download.swift.org
# pub   4096R/ED3D1561 2019-03-22 [SC] [expires: 2023-03-23]
#       Key fingerprint = A62A E125 BBBF BB96 A6E0  42EC 925C C1CC ED3D 1561
# uid                  Swift 5.x Release Signing Key <swift-infrastructure@swift.org
SWIFT_SIGNING_KEY=A62AE125BBBFBB96A6E042EC925CC1CCED3D1561

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

echo "Installing $SWIFT_VERSION"

ARCH_NAME="$(dpkg --print-architecture)";
url=;
case "${ARCH_NAME##*-}" in
    'amd64')
        OS_ARCH_SUFFIX='';
        ;;
    'arm64')
        OS_ARCH_SUFFIX='-aarch64';
        ;;
    *) echo >&2 "error: unsupported architecture: '$ARCH_NAME'"; exit 1 ;;
esac;

SWIFT_WEBDIR="$SWIFT_WEBROOT/$SWIFT_BRANCH/$(echo $SWIFT_PLATFORM | tr -d .)$OS_ARCH_SUFFIX"
SWIFT_BIN_URL="$SWIFT_WEBDIR/$SWIFT_VERSION/$SWIFT_VERSION-$SWIFT_PLATFORM$OS_ARCH_SUFFIX.tar.gz"
SWIFT_SIG_URL="$SWIFT_BIN_URL.sig"
# - Grab curl here so we cache better up above
export DEBIAN_FRONTEND=noninteractive
# - Download the GPG keys, Swift toolchain, and toolchain signature, and verify.
export GNUPGHOME="$(mktemp -d)"
curl -fsSL "$SWIFT_BIN_URL" -o swift.tar.gz "$SWIFT_SIG_URL" -o swift.tar.gz.sig
gpg --batch --quiet --keyserver keyserver.ubuntu.com --recv-keys "$SWIFT_SIGNING_KEY"
gpg --batch --verify swift.tar.gz.sig swift.tar.gz
# - Unpack the toolchain, set libs permissions, and clean up.
tar -xzf swift.tar.gz --directory / --strip-components=1
chmod -R o+r /usr/lib/swift
rm -rf "$GNUPGHOME" swift.tar.gz.sig swift.tar.gz

# Smoke test
swift --version
