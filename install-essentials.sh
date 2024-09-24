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
  apt install unzip -y

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
  # https://github.com/nvm-sh/nvm?tab=readme-ov-file#installing-and-updating
  echo "installing nvm..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

  # install awscli v2
  # https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
  echo "installing awscli v2..."
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
  rm -rf awscliv2.zip aws

  # install starship prompt
  echo "installing starship prompt..."
  sh -c "$(curl -fsSL https://starship.rs/install.sh)"
fi