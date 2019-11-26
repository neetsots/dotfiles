# ------ PS1
source ~/.config/git/git-prompt.sh
export -f __git_ps1
export PS1='/\e[34m\u\e[37m|\e[33m\w \e[35m $(__git_ps1) \e[37m\n\> '

# ----- Aliases
alias ls='ls --color=auto'
alias mkdir='mkdir -p'
alias vim='nvim'

mk ()
{
    mkdir -p -- "$1" &&
      cd -P -- "$1"
}

