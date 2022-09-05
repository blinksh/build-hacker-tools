export PYENV_ROOT="/opt/pyenv"
eval "$(curl https://pyenv.run)"

echo 'export PYENV_ROOT='"$PYENV_ROOT" >> /etc/profile.d/pyenv.sh
echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> /etc/profile.d/pyenv.sh
echo 'eval "$(pyenv init -)"' >> /etc/profile.d/pyenv.sh
echo 'eval "$(pyenv virtualenv-init -)"' >> /etc/profile.d/pyenv.sh

chmod +x /etc/profile.d/pyenv.sh
source /etc/profile.d/pyenv.sh


