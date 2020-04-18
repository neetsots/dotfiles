autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst
#
# Lines configured by zsh-newuser-install
#
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/mehandes/.zshrc'

autoload -Uz compinit
compinit
# GIT setup

# Prompt
PROMPT="%F{208}%~%F{123} "\$vcs_info_msg_0_' '$'\n'"%F{208}%(!.#.>) %f"
zstyle ':vcs_info:git:*' formats '%b'

# Settings
export LANG=en_US.UTF-8
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced
alias ls='ls --color=auto'
alias vi="nvim"

