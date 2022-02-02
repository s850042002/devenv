#!/bin/bash

echo "copy configs to home directory"
cp .bashrc ~/
cp .curlrc ~/
cp .tmux.conf ~/
cp git-prompt.sh ~/
cp git-completion.bash ~/
cp ssh/config ~/.ssh/
cp starship.toml ~/.config/starship.toml

source ~/.bashrc