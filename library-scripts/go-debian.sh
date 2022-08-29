#!/usr/bin/env bash
# This script is adapted and simplified to always install the latest version of Go.
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------
#
# Docs: https://github.com/microsoft/vscode-dev-containers/blob/main/script-library/docs/go.md
# Maintainer: The VS Code and Codespaces Teams
#
# Syntax: ./go-debian.sh [Install tools flag]

TARGET_GO_VERSION="latest"
TARGET_GOROOT="/usr/local/"
# GOPATH is now part of the workspace
# TARGET_GOPATH="/go"
# Where to install the tools
TARGET_GOTOOLS="/opt/go/"
INSTALL_GO_TOOLS=${1:-"true"}

# https://www.google.com/linuxrepositories/
GO_GPG_KEY_URI="https://dl.google.com/linux/linux_signing_key.pub"

set -e

# Figure out correct version of a three part version number is not passed
find_version_from_git_tags() {
    local variable_name=$1
    local requested_version=${!variable_name}
    if [ "${requested_version}" = "none" ]; then return; fi
    local repository=$2
    local prefix=${3:-"tags/v"}
    local separator=${4:-"."}
    local last_part_optional=${5:-"false"}
    if [ "$(echo "${requested_version}" | grep -o "." | wc -l)" != "2" ]; then
        local escaped_separator=${separator//./\\.}
        local last_part
        if [ "${last_part_optional}" = "true" ]; then
            last_part="(${escaped_separator}[0-9]+)?"
        else
            last_part="${escaped_separator}[0-9]+"
        fi
        local regex="${prefix}\\K[0-9]+${escaped_separator}[0-9]+${last_part}$"
        local version_list="$(git ls-remote --tags ${repository} | grep -oP "${regex}" | tr -d ' ' | tr "${separator}" "." | sort -rV)"
        if [ "${requested_version}" = "latest" ] || [ "${requested_version}" = "current" ] || [ "${requested_version}" = "lts" ]; then
            declare -g ${variable_name}="$(echo "${version_list}" | head -n 1)"
        else
            set +e
            declare -g ${variable_name}="$(echo "${version_list}" | grep -E -m 1 "^${requested_version//./\\.}([\\.\\s]|$)")"
            set -e
        fi
    fi
    if [ -z "${!variable_name}" ] || ! echo "${version_list}" | grep "^${!variable_name//./\\.}$" > /dev/null 2>&1; then
        echo -e "Invalid ${variable_name} value: ${requested_version}\nValid values:\n${version_list}" >&2
        exit 1
    fi
    echo "${variable_name}=${!variable_name}"
}

# Get closest match for version number specified
find_version_from_git_tags TARGET_GO_VERSION "https://go.googlesource.com/go" "tags/go" "." "true"

architecture="$(uname -m)"
case $architecture in
    x86_64) architecture="amd64";;
    aarch64 | armv8*) architecture="arm64";;
    aarch32 | armv7* | armvhf*) architecture="armv6l";;
    i?86) architecture="386";;
    *) echo "(!) Architecture $architecture unsupported"; exit 1 ;;
esac

# Install Go

# Use a temporary locaiton for gpg keys to avoid polluting image
# https://github.com/golang/go/issues/14739#issuecomment-324767697
GNUPGHOME="$(mktemp -d)"; export GNUPGHOME;
# https://www.google.com/linuxrepositories/
gpg --batch --keyserver keyserver.ubuntu.com --recv-keys 'EB4C 1BFD 4F04 2F6D DDCC  EC91 7721 F63B D38B 4796'
# let's also fetch the specific subkey of that key explicitly that we expect "go.tgz.asc" to be signed by, just to make sure we definitely have it
gpg --batch --keyserver keyserver.ubuntu.com --recv-keys '2F52 8D36 D67B 69ED F998  D857 78BD 6547 3CB3 BD13';
echo "Downloading Go ${TARGET_GO_VERSION}..."
curl -fsSL -o /tmp/go.tar.gz "https://golang.org/dl/go${TARGET_GO_VERSION}.linux-${architecture}.tar.gz"
# The original script can do magic to figure out the versions, we skip that.
curl -fsSL -o /tmp/go.tar.gz.asc "https://golang.org/dl/go${TARGET_GO_VERSION}.linux-${architecture}.tar.gz.asc"
gpg --batch --verify /tmp/go.tar.gz.asc /tmp/go.tar.gz
gpgconf --kill all
echo "Extracting Go ${TARGET_GO_VERSION}..."
tar -xzf /tmp/go.tar.gz -C "${TARGET_GOROOT}"
rm -rf /tmp/go.tar.gz /tmp/go.tar.gz.asc "$GNUPGHOME"

# Install Go tools that are isImportant && !replacedByGopls based on
# https://github.com/golang/vscode-go/blob/v0.31.1/src/goToolsInformation.ts
GO_TOOLS="\
    golang.org/x/tools/gopls@latest \
    honnef.co/go/tools/cmd/staticcheck@latest \
    golang.org/x/lint/golint@latest \
    github.com/mgechev/revive@latest \
    github.com/uudashr/gopkgs/v2/cmd/gopkgs@latest \
    github.com/ramya-rao-a/go-outline@latest \
    github.com/go-delve/delve/cmd/dlv@latest \
    github.com/golangci/golangci-lint/cmd/golangci-lint@latest"
if [ "${INSTALL_GO_TOOLS}" = "true" ]; then
    echo "Installing common Go tools..."
    export PATH=${TARGET_GOROOT}/go/bin:${PATH}
    mkdir -p /tmp/gotools ${TARGET_GOTOOLS}/bin
    cd /tmp/gotools
    export GOPATH=/tmp/gotools
    export GOCACHE=/tmp/gotools/cache

    # Use go get for versions of go under 1.16
    go_install_command=install
    if [[ "1.16" > "$(go version | grep -oP 'go\K[0-9]+\.[0-9]+(\.[0-9]+)?')" ]]; then
        export GO111MODULE=on
        go_install_command=get
        echo "Go version < 1.16, using go get."
    fi

    (echo "${GO_TOOLS}" | xargs -n 1 go ${go_install_command} -v )2>&1 | tee -a /var/log/go.log

    # Move Go tools into path and clean up
    mv /tmp/gotools/bin/* ${TARGET_GOTOOLS}/bin/

    rm -rf /tmp/gotools
fi

# Add PATH(s) system wide
echo 'export PATH=$PATH:{$TARGET_GOROOT}/go/bin:${TARGET_GOTOOLS}/bin' >> /etc/profile
chmod -R o+r "${TARGET_GOROOT}/go" "${TARGET_GOTOOLS}"

echo "Done!"

