# ------ PS1
source ~/.config/git/git-prompt.sh
export -f __git_ps1
export PS1='/\e[34m\u\e[37m|\e[33m\w \e[35m $(__git_ps1) \e[37m\n\> '

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
alias chrome=' /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome'
alias python='python3'
alias pip='pip3'
alias vim='nvim'

mk ()
{
    mkdir -p -- "$1" &&
      cd -P -- "$1"
}

# tabtab source for serverless package
# uninstall by removing these lines or running `tabtab uninstall serverless`
[ -f /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/serverless.bash ] && . /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/serverless.bash
# tabtab source for sls package
# uninstall by removing these lines or running `tabtab uninstall sls`
[ -f /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/sls.bash ] && . /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/sls.bash
# tabtab source for slss package
# uninstall by removing these lines or running `tabtab uninstall slss`
[ -f /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/slss.bash ] && . /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/slss.bash
