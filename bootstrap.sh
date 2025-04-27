sudoIfAvailable() {
  if command -v sudo; then
    sudo "$@"
  else
    "$@"
  fi
}

# install git
sudoIfAvailable apt-get update
sudoIfAvailable apt-get install -y git-all

# setup workspace
mkdir -p ~/workspace
cd ~/workspace

# clone repo
git clone git@github.com:dbuzinski/.dotfiles.git
cd .dotfiles

# run script
chmod +x setup.sh
./setup.sh
