ARG VARIANT="buster"
FROM buildpack-deps:${VARIANT}

ARG USERNAME=blink
ARG USER_UID=1000
ARG USER_GID=$USER_GID
ARG INSTALL_ZSH="true"
ARG UPGRADE_PACKAGES="true"

# Copy scripts
COPY library-scripts/*.sh library-scripts/*.env /tmp/library-scripts/ 
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && /bin/bash /tmp/library-scripts/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" "true" "true" \
    #
    # ****************************************************************************
    # * TODO: Add any additional OS packages you want included in the definition *
    # * here. We want to do this before cleanup to keep the "layer" small.       *
    # ****************************************************************************
    && apt-get -y install --no-install-recommends \
    neovim emacs-nox \
    tmux screen \
    htop procps file \
    sqlite postgresql-client \
    mc tree ack fzf \
    lua5.3 \
    #
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts
