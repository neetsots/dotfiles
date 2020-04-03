# GIT setup
autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst

# Prompt
PROMPT="%F{220}%~%F{208} "\$vcs_info_msg_0_' '$'\n'"%(!.#.>) %f"
RPROMPT="%F{123}%*"
zstyle ':vcs_info:git:*' formats '%b'

# Settings
export LANG=en_US.UTF-8
alias vi="nvim"
