
echo "Installing NeoVim"


set -eux;
dpkgArch="$(dpkg --print-architecture)";
case "${dpkgArch##*-}" in
    amd64) dep='linux64.deb' ;;
    *) echo >&2 "unsupported architecture: ${dpkgArch}"; exit 1 ;;
esac;

url="https://api.github.com/repos/neovim/neovim/releases/latest"
curl -L -o nvim-linux64.deb `curl -s "$url" | jq -r '.assets[].browser_download_url' | grep "$dep"`
apt install ./nvim-linux64.deb

rm -rf nvim-linux64.dep