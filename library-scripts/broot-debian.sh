echo "Installing Broot"

set -eux;
dpkgArch="$(dpkg --print-architecture)";
case "${dpkgArch##*-}" in
    amd64) url='https://dystroy.org/broot/download/x86_64-linux/broot' ;;
    *) echo >&2 "unsupported architecture: ${dpkgArch}"; exit 1 ;;
esac;

curl -L -o broot "$url"
chmod +x broot
mv broot /usr/local/bin/

broot --print-shell-function bash > /etc/profile.d/broot.sh
broot --set-install-state installed
