#!/bin/bash

answer_is_yes() {
  [[ "$REPLY" =~ ^[Yy]$ ]] \
    && return 0 \
    || return 1
}

ask() {
  print_question "$1"
  read
}

ask_for_confirmation() {
  print_question "$1 (y/n) "
  read -n 1
  printf "\n"
}

execute() {
  $1 &> /dev/null
  echo $1
  print_result $? "${2:-$1}"
}

symlink() {
  targetFile="$2"
  sourceFile="$1"

  if [[ -d "$targetFile" ]]; then
    targetFile="${targetFile}$(basename ${sourceFile})"
  fi

  if [[ ! -d $(dirname "$targetFile") ]]; then
    mkdir -p $(dirname "$targetFile")
  fi

  if [ ! -e "$targetFile" ]; then
    execute "ln -fs $sourceFile $targetFile" "$targetFile → $sourceFile"
  elif [ "$(readlink "$targetFile")" == "$sourceFile" ]; then
    print_success "$targetFile → $sourceFile"
  else
    ask_for_confirmation "'$targetFile' already exists, do you want to overwrite it?"
    if answer_is_yes; then
      rm -rf "$targetFile"
      execute "ln -fs $sourceFile $targetFile" "$targetFile → $sourceFile"
    else
      print_error "$targetFile → $sourceFile"
    fi
  fi

}

symlink_multiple_destination() {
  for directory in $2; do
    symlink $1 $directory
  done
}

print_error() {
  # Print output in red
  printf "\e[0;31m  [✖] $1 $2\e[0m\n"
}

print_info() {
  # Print output in purple
  printf "\n\e[0;35m $1\e[0m\n\n"
}

print_question() {
  # Print output in yellow
  printf "\e[0;33m  [?] $1\e[0m"
}

print_result() {
  [ $1 -eq 0 ] \
    && print_success "$2" \
    || print_error "$2"

  [ "$3" == "true" ] && [ $1 -ne 0 ] \
    && exit
}

print_success() {
  # Print output in green
  printf "\e[0;32m  [✔] $1\e[0m\n"
}

process_post_install() {
  print_info "Processing post install:"
  vim +PluginInstall +qall
  print_result $? "Install Vim plugins"

  echo "emulate sh -c 'source /etc/profile.d/apps-bin-path.sh'" >> /etc/zsh/zprofile
}

# dotfiles directory
dir=~/.dotfiles
# old dotfiles backup directory
dir_backup=~/.dotfiles_old

# Install default packages if asked
read -p "Do you want to install default packages? [y/n]" -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    ${BASH_SOURCE%/*}/init.sh
fi

# Create dotfiles_old in homedir
if [ ! -d $dir_backup ]; then
  echo -n "Creating $dir_backup for backup of any existing dotfiles in ~... "
  mkdir -p $dir_backup
  echo "done"
fi

# Change to the dotfiles directory
echo -n "Changing to the $dir directory... "
cd $dir
echo "done"

declare -A FILES_TO_SYMLINK=(

  ['.gitconfig']='git/gitconfig'
  ['.gitignore']='git/gitignore'
  ['.zshrc']='zsh/zshrc'
  ['.config/terminator/config']='terminator/config'
  ['.vimrc']='vim/vimrc'
  ['.tmux.conf']='tmux/tmux.conf'
  ['.mozilla/firefox/*default*/']='firefox/user.js'
  ['.mozilla/firefox/*default*/chrome/']='firefox/userChrome.css'
  ['.config/fontconfig/conf.d/99-fira-code-light-color-emoji.conf']='font/99-fira-code-light-color-emoji.conf'

)

# Manually initialize Firefox chrome folder
for profile in ~/.mozilla/firefox/*default*/; do
  if [[ ! -d "${profile}chrome" ]]; then
    mkdir "${profile}chrome"
  fi
done

# for key in ${!FILES_TO_SYMLINK[@]}; do
#     echo ${key} ${FILES_TO_SYMLINK[${key}]}
# done
# exit

# Move any existing dotfiles in homedir to dotfiles_old directory,
# then create symlinks from the homedir to any files in the ~/dotfiles directory specified in $files

for key in ${!FILES_TO_SYMLINK[@]}; do
  echo "Moving any existing dotfiles from ~ to $dir_backup"
  execute "mv ~/${key} ${dir_backup}"
done

for key in ${!FILES_TO_SYMLINK[@]}; do
  sourceFile="${dir}/${FILES_TO_SYMLINK[${key}]}"
  targetFile="$HOME/${key}"

  if [[ "$targetFile" == *"*"* ]]; then
    symlink_multiple_destination "$sourceFile" "$targetFile"
  else
    symlink "$sourceFile" "$targetFile"
  fi


done

process_post_install
