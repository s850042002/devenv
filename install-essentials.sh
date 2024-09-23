#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root" 
  exit 1
else
  echo "updating and upgrading"
  apt update && apt upgrade -y

  apt install build-essential
  apt install tmux
  apt install curl

  # install git
  echo "installing git..."
  sudo add-apt-repository -y ppa:git-core/ppa
  sudo apt-get update
  sudo apt-get install git -y

  # install golang 1.23.1
  echo "installing golang 1.23.1..."
  curl -L -o go1.23.1.linux-amd64.tar.gz https://golang.org/dl/go1.23.1.linux-amd64.tar.gz
  rm -rf /usr/local/go
  tar -C /usr/local -xzf go1.23.1.linux-amd64.tar.gz

  # install nvm
  echo "installing nvm..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

  # install starship prompt
  echo "installing starship prompt..."
  sh -c "$(curl -fsSL https://starship.rs/install.sh)"
fi