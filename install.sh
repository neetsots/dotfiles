# Create relevant directories
mkdir -p ~/.config/nvim
mkdir -p ~/.config/bspwm
mkdir -p ~/.config/sxhkd
mkdir -p ~/.config/polybar/scripts
mkdir -p ~/.config/rofi
mkdir -p ~/.config/coc/extensions

# Copy files for installation
cp zshrc ~/.zshrc
cp bashrc ~/.bashrc

cp config/bspwm/bspwmrc ~/.config/bspwm/bspwmrc
cp config/sxhkd/sxhkdrc ~/.config/sxhkd/sxhkdrc
cp config/polybar/config ~/.config/polybar/config
cp -r config/polybar/scripts/ ~/.config/polybar/scripts/
cp config/rofi/config.rasi ~/.config/rofi/config.rasi

cp tmux/tmux.conf ~/.tmux.conf
cp tmux/tmux-status.conf ~/.tmux-status.conf

cp config/nvim/init.vim ~/.config/nvim/init.vim
cp coc/package.json ~/.config/coc/extensions/package.json

cp Xresources ~/.Xresources
xrdb ~/.Xresources
