# Path to your oh-my-zsh installation.
export ZSH="/Users/elie.mitrani/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
#ZSH_THEME="tetradic"

CASE_SENSITIVE="true"
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# PLUGINS -----------------------------------------------------------------------------
plugins=(
    git
    osx)

source $ZSH/oh-my-zsh.sh

# PATH -----------------------------------------------------------------------------
export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH=$HOME/.cargo/bin:$PATH
export PATH=$HOME/.npm-packages:$PATH
export PATH=/usr/local/lib/node_modules/npm/node_modules:$PATH
export PATH=/usr/local/lib/python3.7/site-packages:/Users/elie.mitrani/Library/Python/3.7/bin:$PATH
export MANPATH="/usr/local/man:$MANPATH"
export PKG_CONFIG_PATH="/usr/local/opt/openssl@1.1/lib/pkgconfig"
fpath+=("$HOME/.zsh/pure")

# LANG -----------------------------------------------------------------------------
export LANG=en_US.UTF-8

# ALIASES -----------------------------------------------------------------------------
alias pip="pip3"
alias python="python3"
alias nim="nvim"
alias vim="nvim"
alias vi="nvim"
alias nvi="nvim"
alias firefox="/Applications/Firefox\ Developer\ Edition.app/Contents/MacOS/firefox"
alias emacs="/usr/local/opt/emacs/bin/emacs-26.2"
alias gcc="gcc-9"
alias g++="g++-9"
alias git="/usr/local/Cellar/git/2.25.0_1/bin/git"

# PROMPT ------------------------------------------------------------------------------
autoload -U promptinit; promptinit
prompt pure

PROMPT='%(?.%F{green}.%F{red}❯%F{green})❯%f '
PURE_PROMPT_SYMBOL='%f%F{red}#%f %F{green}❯'


# MISC -----------------------------------------------------------------------------
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

ssh() {
  local code=0
  local ancien

  ancien=$(tmux display-message -p '#W')

  if [ $TERM = tmux -o $TERM = tmux-256color ]; then

      tmux rename-window "$*"

      command ssh "$@"

      code=$?
  else
      command ssh "$@"

      code=$?
  fi

  tmux rename-window $ancien

  return $code
}

# virtualenv and virtualenvwrapper
export WORKON_HOME=$HOME/.virtualenvs
export VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python3
export NODE_PATH=/usr/local/lib/node_modules
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
