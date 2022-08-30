export HELIX=/usr/local/.config/helix
export HELIX_RUNTIME=$HELIX/runtime

echo "Installing Helix"

mkdir -p $HELIX

set -eux;
dpkgArch="$(dpkg --print-architecture)";
case "${dpkgArch##*-}" in
    amd64) rustArch='x86_64-linux' ;;
    *) echo >&2 "unsupported architecture: ${dpkgArch}"; exit 1 ;;
esac;

url="https://api.github.com/repos/helix-editor/helix/releases/latest"
curl -L -o helix.tar.xz `curl -s "$url" | jq -r '.assets[].browser_download_url' | grep "$rustArch"`
mkdir helix
tar -xf helix.tar.xz -C helix --strip-components=1

mv helix/hx /usr/local/bin/
mv helix/runtime $HELIX

rm -rf helix

hx --grammar fetch
hx --grammar build
