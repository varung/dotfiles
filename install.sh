if [ -z "$HOME" ]; then
  HOME=/root
fi
mkdir $HOME/.backup
cp -r .vimrc $HOME/
mkdir $HOME/.vim/bundle
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +PluginInstall +qall
