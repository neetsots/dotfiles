
# ------ PS1
source ~/.config/git/git-prompt.sh
export -f __git_ps1
export PS1='/\e[34m\u\e[37m|\e[33m\w \e[35m$(__git_ps1)\e[37m\n\> '

# ------ Improving Bash completion
[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && \
	. "/usr/local/etc/profile.d/bash_completion.sh"

# ------ Git Bash completion
[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion || {
    # if not found in /usr/local/etc, try the brew --prefix location
    [ -f "$(brew --prefix)/etc/bash_completion.d/git-completion.bash" ] && \
        . $(brew --prefix)/etc/bash_completion.d/git-completion.bash
	}

# ----- Aliases
alias ls='ls -G'
alias ll='ls -lG'
alias mkdir='mkdir -p'

