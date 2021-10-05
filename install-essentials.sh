#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root" 
  exit 1
else
  echo "updating and upgrading"
  apt update && apt upgrade -y

  apt install build-essential
  apt install git
  apt install tmux
  apt install curl

  # install golang 1.17.1
  curl -L -o go1.17.1.linux-amd64.tar.gz https://golang.org/dl/go1.17.1.linux-amd64.tar.gz
  rm -rf /usr/local/go
  tar -C /usr/local -xzf go1.17.1.linux-amd64.tar.gz
fi