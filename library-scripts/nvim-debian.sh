
echo "Installing NeoVim"


set -eux;
dpkgArch="$(dpkg --print-architecture)";
case "${dpkgArch##*-}" in
    amd64) dep='linux64.tar.gz' ;;
    *) echo >&2 "unsupported architecture: ${dpkgArch}"; exit 1 ;;
esac;

url="https://api.github.com/repos/neovim/neovim/releases/latest"
curl -L -o nvim-linux64.tar.gz `curl -s "$url" | jq -r '.assets[].browser_download_url' | grep "$dep"`
mkdir nvim
tar -zxf nvim-linux64.tar.gz -C nvim --strip-components=1

mv nvim/bin/* /usr/local/bin/
mv nvim/lib/* /usr/local/lib/
cp -r nvim/share/* /usr/local/share/

rm -rf nvim