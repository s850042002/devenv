#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root" 
  exit 1
else
  echo "updating and upgrading"
  apt update && apt upgrade -y

  apt install build-essential -y
  apt install tmux -y
  apt install curl -y

  # install openjdk 21
  echo "installing openjdk 21..."
  apt install openjdk-21-jdk -y

  # install git
  echo "installing git..."
  sudo add-apt-repository -y ppa:git-core/ppa
  sudo apt-get update
  sudo apt-get install git -y

  # install/upgrade golang
  echo "installing/upgrading golang..."
  ./golang-upgrade.sh

  # install nvm
  echo "installing nvm..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

  # install starship prompt
  echo "installing starship prompt..."
  sh -c "$(curl -fsSL https://starship.rs/install.sh)"
fi