# Based on the official rust image
export RUSTUP_HOME=/usr/local/rustup
export CARGO_HOME=/usr/local/cargo
export PATH=/usr/local/cargo/bin:$PATH
export RUST_VERSION=1.71.1

echo "Installing Rust $RUST_VERSION"

set -eux;
dpkgArch="$(dpkg --print-architecture)";
case "${dpkgArch##*-}" in
    amd64) rustArch='x86_64-unknown-linux-gnu'; rustupSha256='0b2f6c8f85a3d02fde2efc0ced4657869d73fccfce59defb4e8d29233116e6db' ;;
    armhf) rustArch='armv7-unknown-linux-gnueabihf'; rustupSha256='f21c44b01678c645d8fbba1e55e4180a01ac5af2d38bcbd14aa665e0d96ed69a' ;;
    arm64) rustArch='aarch64-unknown-linux-gnu'; rustupSha256='673e336c81c65e6b16dcdede33f4cc9ed0f08bde1dbe7a935f113605292dc800' ;;
    i386) rustArch='i686-unknown-linux-gnu'; rustupSha256='e7b0f47557c1afcd86939b118cbcf7fb95a5d1d917bdd355157b63ca00fc4333' ;;
    *) echo >&2 "unsupported architecture: ${dpkgArch}"; exit 1 ;;
esac;

url="https://static.rust-lang.org/rustup/archive/1.26.0/${rustArch}/rustup-init"
wget "$url"
echo "${rustupSha256} *rustup-init" | sha256sum -c -
chmod +x rustup-init
./rustup-init -y --no-modify-path --default-toolchain $RUST_VERSION --default-host ${rustArch}
rm rustup-init

echo '# rust setup' > /etc/profile.d/rustup-env.sh
echo "export RUSTUP_HOME=$RUSTUP_HOME" >> /etc/profile.d/rustup-env.sh
echo "export CARGO_HOME=$CARGO_HOME" >> /etc/profile.d/rustup-env.sh
echo "export RUST_VERSION=$RUST_VERSION" >> /etc/profile.d/rustup-env.sh
echo "source $CARGO_HOME/env" >> /etc/profile.d/rustup-env.sh
chmod +x /etc/profile.d/rustup-env.sh

chmod -R a+w $RUSTUP_HOME $CARGO_HOME

rustup component add clippy rustfmt

# Smoke test
rustup --version
cargo --version
rustc --version
