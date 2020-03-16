#!/bin/bash

COMMON_PACKAGES="git vim tig curl wget zsh terminator ncdu firefox"

if [ ! -d ~/.ssh ]; then
  read -e -p "SSH Key Email : " EMAIL
  ssh-keygen -t rsa -b 4096 -C "${EMAIL}"
fi

if [ ! -d ~/tmp ]; then
  mkdir ~/tmp
fi

if [ ! -d ~/installs ]; then
  mkdir ~/installs
fi

if [ ! -d ~/.local/bin ]; then
  mkdir -p ~/.local/bin
fi

# Ubuntu
if [ -f /etc/lsb-release ]; then
  sudo apt-get update
  # fzf is in repos only since Disco
  sudo apt-get install -y fzf
  sudo apt-get install -y ${COMMON_PACKAGES} fonts-firacode

  # bat
  wget -P ~/tmp https://github.com/sharkdp/bat/releases/download/v0.11.0/bat_0.11.0_amd64.deb
  sudo dpkg -i ~/tmp/bat_0.11.0_amd64.deb
  rm -f ~/tmp/bat_0.11.0_amd64.deb

  # thefuck
  sudo apt install -y python3-dev python3-pip python3-setuptools
  sudo pip3 install thefuck

  # tmux
  sudo apt-get install tmux
elif [ -f /etc/redhat-release ]; then
  sudo dnf install -y dnf-plugins-core
  sudo dnf copr enable -y evana/fira-code-fonts
  sudo dnf install -y ${COMMON_PACKAGES} fira-code-fonts fzf

  # bat
  sudo dnf install -y fedora-repos-modular
  sudo dnf module install -y bat

  # thefuck - TODO
  sudo dnf install -y python3-devel
  sudo pip3 install thefuck

  #tmux
  sudo dnf install tmux
fi

# FZF shortcut thingy
wget -P ~/installs https://raw.githubusercontent.com/junegunn/fzf/master/shell/key-bindings.zsh

# PrettyPing
wget -P ~/.local/bin/ https://raw.githubusercontent.com/denilsonsa/prettyping/master/prettyping
chmod u+x ~/.local/bin/prettyping

# Oh my ZSH + plugins
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Vim Vundle
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

# Tmux Plugin Manabger
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

