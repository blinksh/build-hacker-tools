# Based on the official rust image
export RUSTUP_HOME=/usr/local/rustup
export CARGO_HOME=/usr/local/cargo
export PATH=/usr/local/cargo/bin:$PATH
export RUST_VERSION=1.69.0

echo "Installing Rust $RUST_VERSION"

set -eux;
dpkgArch="$(dpkg --print-architecture)";
case "${dpkgArch##*-}" in
    amd64) rustArch='x86_64-unknown-linux-gnu'; rustupSha256='bb31eaf643926b2ee9f4d8d6fc0e2835e03c0a60f34d324048aa194f0b29a71c' ;;
    armhf) rustArch='armv7-unknown-linux-gnueabihf'; rustupSha256='6626b90205d7fe7058754c8e993b7efd91dedc6833a11a225b296b7c2941194f' ;;
    arm64) rustArch='aarch64-unknown-linux-gnu'; rustupSha256='4ccaa7de6b8be1569f6b764acc28e84f5eca342f5162cd5c810891bff7ed7f74' ;;
    i386) rustArch='i686-unknown-linux-gnu'; rustupSha256='34392b53a25c56435b411d3e575b63aab962034dd1409ba405e708610c829607' ;;
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
