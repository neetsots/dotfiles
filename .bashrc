#------------------------------------------------------------------------------
# Returncode.
#------------------------------------------------------------------------------
function returncode
{
	returncode=$?
	if [ $returncode != 0 ]; then
		echo "[$returncode]"
	else
		echo ""
	fi
}
GIT_PS1_SHOWDIRTYSTATE=true
#------------------------------------------------------------------------------
# Path.
#------------------------------------------------------------------------------
PATH="/bin:/usr/local/opt/usr/local/bin:/usr/local/sbin:$PATH"
PATH="$HOME/.local/bin:$PATH"
PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH

#------------------------------------------------------------------------------
# Prompt.
#------------------------------------------------------------------------------
if [ "$BASH" ]; then
	if [ "`id -u`" -eq 0 ]; then
		# The root prompt is red.
		PS1='\[\033[0;31m\]\u@\h:\w >\[\033[0;37m\] '
	else
		# PS1='\u@\h:\w > '
		PS1='\[\033[0;33m\]$(returncode)\[\033[0;94m\]\u@\h:\[\033[0;36m\]\w\[\033[0;38m\]$(parse_git_branch) \[\033[0;94m\]\n> \[\033[0;38m\]'
	fi	  
else
	if [ "`id -u`" -eq 0 ]; then
		PS1='# '
	else
		PS1='$ '
	fi
fi
export PS1

# Whenever displaying the prompt, write the previous line to .bash_history.
PROMPT_COMMAND='history -a'
PROMPT_DIRTRIM=3

#------------------------------------------------------------------------------
# Bash options.
#------------------------------------------------------------------------------
set -o notify

#------------------------------------------------------------------------------
# Bash shopts.
#------------------------------------------------------------------------------
shopt -s extglob
shopt -s progcomp
shopt -s histappend
shopt -s histreedit
shopt -s histverify
shopt -s cmdhist
shopt -s lithist
shopt -s no_empty_cmd_completion
shopt -s checkhash
shopt -s hostcomplete

# @Completion.
#------------------------------------------------------------------------------
complete -A alias         alias unalias
complete -A command       which
complete -A export        export printenv
complete -A hostname      ssh telnet ftp ncftp ping dig nmap
complete -A helptopic     help
complete -A job -P '%'    fg jobs
complete -A setopt        set
complete -A shopt         shopt
complete -A signal        kill killall
complete -A user          su userdel passwd
complete -A group         groupdel groupmod newgrp
complete -A directory     cd rmdir

# @Git options.
#------------------------------------------------------------------------------
function parse_git_dirty {
	[[ $(git status 2> /dev/null | tail -n1) != "nothing to commit (working directory clean)" ]] && echo "*"
}
function parse_git_branch {
	git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/ (\1)/"
}

# @Colorized ls.
#------------------------------------------------------------------------------
LS_OPTIONS='--color=auto'
alias ls='ls $LS_OPTIONS'

# @Security.
#------------------------------------------------------------------------------
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias ln='ln -i'

# @Typos
#------------------------------------------------------------------------------
alias c=clear
alias cl=clear
alias chmdo=chmod
alias sl=ls
alias tarx='tar x'
alias maek=make
alias act=cat
alias grpe=grep
alias whcih=which
alias nvmi=nvim

# @Miscellaneous
#------------------------------------------------------------------------------
ulimit -c unlimited

# @Environment Variables
#------------------------------------------------------------------------------
export EDITOR=nvim
export LESS=eFRX
