# Create relevant directories
mkdir -p ~/.config/nvim
mkdir -p ~/.config/coc/extensions

# Copy files for installation
cp zshrc ~/.zshrc
cp bashrc ~/.bashrc
cp tmux/tmux.conf ~/.tmux.conf
cp tmux/tmux-status.conf ~/.tmux-status.conf
cp config/nvim/init.vim ~/.config/nvim/init.vim
cp coc/package.json ~/.config/coc/extensions/package.json
