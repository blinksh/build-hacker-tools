ARG VARIANT="bullseye"
FROM buildpack-deps:${VARIANT}

ARG USERNAME=root
ARG USER_UID=0
ARG USER_GID=0
ARG INSTALL_ZSH="true"
ARG UPGRADE_PACKAGES="true"

# Copy scripts
# TODO Use common-library and then the rest, so that the context does not change for this stage.
COPY common-library-scripts/*.sh common-library-scripts/*.env /tmp/library-scripts/
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && /bin/bash /tmp/library-scripts/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" "true" "true" \
    #
    # ****************************************************************************
    # * TODO: Add any additional OS packages you want included in the definition *
    # * here. We want to do this before cleanup to keep the "layer" small.       *
    # ****************************************************************************
    && apt-get -y install --no-install-recommends \
    emacs-nox \
    tmux screen \
    htop procps file \
    sqlite3 postgresql-client \
    mc tree ack fzf \
    lua5.3 \
    #
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts

# Runtimes
COPY library-scripts/*.sh library-scripts/*.env /tmp/library-scripts/ 
# External scripts
RUN curl -L https://raw.githubusercontent.com/tj/n/master/bin/n -o /tmp/library-scripts/n
RUN cd /tmp/library-scripts && \
    /bin/bash swift5-debian.sh && \
    # Rust
    /bin/bash rust-debian.sh && \
    /bin/bash rust-analyzer-debian.sh && \
    # Node
    /bin/bash n lts && \
        npm i -g n yarn \
            typescript-language-server typescript bash-language-server vls svelte-language-server \
            awk-language-server@>=0.5.2 && \
    curl -f https://get.pnpm.io/v7.27.js | node - add --global pnpm && \
    # TODO Maybe a Next.js or a few frameworks to bootstrap?
    # Ruby
    /bin/bash rbenv-system-wide.sh && \
    /bin/bash -l -c "rbenv install 3.1.3" && /bin/bash -l -c "rbenv global 3.1.3" && \
    /bin/bash -l -c "rbenv install 2.7.7" && \
    # TODO Ruby: bundler
    # Go
    /bin/bash go-debian.sh && \
    # TODO Python
    # Python
    /bin/bash pyenv-system-wide.sh && \
    /bin/bash -l -c "pyenv install 3.11.1" && /bin/bash -l -c "pyenv global 3.11.1" && \
    /bin/bash -l -c "pyenv install 2.7.18" && \
    # TODO PHP
    /bin/bash helix-debian.sh && \
    /bin/bash nvim-debian.sh && \
    /bin/bash broot-debian.sh && \
    rm -rf /tmp/*

# TODO We should include a changelog for what is new in the image.