# Install rbenv
git clone https://github.com/sstephenson/rbenv.git /opt/rbenv

# Add rbenv to the path:
echo '# rbenv setup' > /etc/profile.d/rbenv.sh
echo 'export RBENV_ROOT=/opt/rbenv' >> /etc/profile.d/rbenv.sh
echo 'export PATH="$RBENV_ROOT/bin:$PATH"' >> /etc/profile.d/rbenv.sh
echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh

chmod +x /etc/profile.d/rbenv.sh
source /etc/profile.d/rbenv.sh

# Install ruby-build:
pushd /tmp
  git clone https://github.com/sstephenson/ruby-build.git
  cd ruby-build
  ./install.sh
popd

# Cleanup
rm -rf /tmp/*ruby-build*

# Rehash:
rbenv rehash
