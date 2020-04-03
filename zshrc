# GIT setup
autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst

# Prompt
PROMPT="%F{208}%~%F{123} "\$vcs_info_msg_0_' '$'\n'"%F{208}%(!.#.>) %f"
zstyle ':vcs_info:git:*' formats '%b'

# Settings
export LANG=en_US.UTF-8
alias vi="nvim"
