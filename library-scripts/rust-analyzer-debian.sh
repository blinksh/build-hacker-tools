echo "Installing Rust Analyzer"

set -eux;
dpkgArch="$(dpkg --print-architecture)";
case "${dpkgArch##*-}" in
    amd64) rustArch='x86_64-unknown-linux-gnu' ;;
    arm64) rustArch='aarch64-unknown-linux-gnu' ;;
    *) echo >&2 "unsupported architecture: ${dpkgArch}"; exit 1 ;;
esac;

url="https://api.github.com/repos/rust-lang/rust-analyzer/releases/latest"
curl -L -o rust-analyzer.gz `curl -s "$url" | jq -r '.assets[].browser_download_url' | grep "$rustArch"`
gzip -d rust-analyzer.gz
chmod +x rust-analyzer
mv rust-analyzer /usr/local/bin/
