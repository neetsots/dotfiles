# Path to your oh-my-zsh installation.
export ZSH=".config/oh-my-zsh"
ZSH_THEME="pure"

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
plugins=( git )

# LANG -----------------------------------------------------------------------------
export LANG=en_US.UTF-8

# ALIASES -----------------------------------------------------------------------------
alias nim="nvim"
alias vim="nvim"
alias vi="nvim"
alias nvi="nvim"
alias ls='ls --color=auto'

# PROMPT ------------------------------------------------------------------------------
autoload -U promptinit; promptinit

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
