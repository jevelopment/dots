
git init --bare $HOME/dotfiles
alias config='/usr/bin/git --git-dir=$HOME/dotfiles/ --work-tree=$HOME' (add this alias to .bashrc)
bash
config config --local status.showUntrackedFiles no

Basic usage example:

config add /path/to/file
config commit -m "A short message"
config push

to sync the files back down to a system :
config checkout
