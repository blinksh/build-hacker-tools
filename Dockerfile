FROM ubuntu

WORKDIR /root
RUN apt-get update -y && apt-get install \
    curl wget \ 
    git \
    tmux screen \
    htop procps file \
    vim nano neovim \
    sqlite postgresql-client \
    gnupg2 libssl-dev \
    mc tree ack fzf \
    lua5.3 \
    build-essential -y

# DOTFILES
RUN rm .bashrc
RUN git clone --recursive --bare https://github.com/blinksh/blink-build-dotfiles.git /root/.cfg && \
  git --git-dir=/root/.cfg --work-tree=/root config status.showUntrackedFiles no && \
  git --git-dir=/root/.cfg --work-tree=/root checkout
# homebrew
# NO arm suppprt :(
# RUN curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash

# Swift

RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true && \
    apt-get -q install -y \
    binutils \
    libc6-dev \
    libcurl4-openssl-dev \
    libedit2 \
    libgcc-9-dev \
    libpython3.8 \
    libsqlite3-0 \
    libstdc++-9-dev \
    libxml2-dev \
    libz3-dev \
    pkg-config \
    tzdata \
    zlib1g-dev

ENV SWIFT_SIGNING_KEY=A62AE125BBBFBB96A6E042EC925CC1CCED3D1561 \
    SWIFT_PLATFORM=ubuntu20.04 \
    SWIFT_BRANCH=swift-5.6.2-release \
    SWIFT_VERSION=swift-5.6.2-RELEASE \
    SWIFT_WEBROOT=https://download.swift.org

RUN set -e; \
    ARCH_NAME="$(dpkg --print-architecture)"; \
    url=; \
    case "${ARCH_NAME##*-}" in \
        'amd64') \
            OS_ARCH_SUFFIX=''; \
            ;; \
        'arm64') \
            OS_ARCH_SUFFIX='-aarch64'; \
            ;; \
        *) echo >&2 "error: unsupported architecture: '$ARCH_NAME'"; exit 1 ;; \
    esac; \
    SWIFT_WEBDIR="$SWIFT_WEBROOT/$SWIFT_BRANCH/$(echo $SWIFT_PLATFORM | tr -d .)$OS_ARCH_SUFFIX" \
    && SWIFT_BIN_URL="$SWIFT_WEBDIR/$SWIFT_VERSION/$SWIFT_VERSION-$SWIFT_PLATFORM$OS_ARCH_SUFFIX.tar.gz" \
    && SWIFT_SIG_URL="$SWIFT_BIN_URL.sig" \
    # - Grab curl here so we cache better up above
    && export DEBIAN_FRONTEND=noninteractive \
    # - Download the GPG keys, Swift toolchain, and toolchain signature, and verify.
    && export GNUPGHOME="$(mktemp -d)" \
    && curl -fsSL "$SWIFT_BIN_URL" -o swift.tar.gz "$SWIFT_SIG_URL" -o swift.tar.gz.sig \
    && gpg --batch --quiet --keyserver keyserver.ubuntu.com --recv-keys "$SWIFT_SIGNING_KEY" \
    && gpg --batch --verify swift.tar.gz.sig swift.tar.gz \
    # - Unpack the toolchain, set libs permissions, and clean up.
    && tar -xzf swift.tar.gz --directory / --strip-components=1 \
    && chmod -R o+r /usr/lib/swift \
    && rm -rf "$GNUPGHOME" swift.tar.gz.sig swift.tar.gz

# RUST
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
# NODE
RUN curl -L https://raw.githubusercontent.com/tj/n/master/bin/n -o n
RUN bash n lts && npm i -g yarn

# RUBY
RUN gpg2 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
RUN curl -sSL https://get.rvm.io | bash -s stable --rails

# helix editor
RUN git clone --depth 1 https://github.com/helix-editor/helix
RUN cd helix && /root/.cargo/bin/cargo install --path helix-term && mkdir -p /root/.config/helix && cp -r runtime /root/.config/helix/
RUN cd /root && rm -rf helix


# V lang
RUN git clone --depth 1 https://github.com/vlang/v && cd v && make && ./v symlink
