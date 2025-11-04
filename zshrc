##### Homebrew & PATHs #####
# Homebrew (Apple Silicon default)
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Rust (cargo) if installed via rustup
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# Go
export GOPATH="$HOME/go"
export GOBIN="$GOPATH/bin"
export PATH="$GOBIN:$PATH"

# Python: prefer python3 and uv-managed venvs
alias python=python3
alias pip="python -m pip"

##### Zsh options #####
export ZDOTDIR="$HOME"
export EDITOR="nvim"
export VISUAL="$EDITOR"

# History
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=100000
export SAVEHIST=100000
setopt INC_APPEND_HISTORY SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS

# Completion
autoload -Uz compinit
zmodload zsh/complist
compinit -d "$HOME/.zcompdump"
setopt COMPLETE_IN_WORD MENU_COMPLETE
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Keybindings
bindkey -e        # emacs-style
bindkey '^P' up-history
bindkey '^N' down-history
bindkey '^R' history-incremental-search-backward

##### Prompt (starship) #####
eval "$(starship init zsh)"

##### Jumping (zoxide) #####
eval "$(zoxide init zsh)"
alias j="z"      # quick jump

##### fzf (fuzzy find) #####
# keybindings + completion provided by installer
[[ -f "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh" ]] && source "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh"
[[ -f "$(brew --prefix)/opt/fzf/shell/completion.zsh"    ]] && source "$(brew --prefix)/opt/fzf/shell/completion.zsh"

# Better defaults
export FZF_DEFAULT_COMMAND='fd --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

##### humane ls/cat, git pager #####
alias ls='eza --group-directories-first --icons --git'
alias ll='eza -l --group-directories-first --icons --git'
alias la='eza -la --group-directories-first --icons --git'
alias cat='bat --paging=never'
export GIT_PAGER='delta'

##### Quality-of-life aliases #####
alias ..='cd ..'
alias ...='cd ../..'
alias gs='git status -sb'
alias ga='git add -A'
alias gc='git commit -m'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gp='git push'
alias gl='git pull --rebase --autostash'
alias gd='git diff'
alias gds='git diff --staged'
alias v='nvim'

##### Language tooling helpers #####
# Rust
alias cb='cargo build'
alias cr='cargo run'
alias ct='cargo test'

# Go
export GO111MODULE=on
alias gob='go build ./...'
alias got='go test ./...'
alias gor='go run'

# Python (uv) — instant venvs & reproducible workflows
# Create .venv and activate it
mkvenv() {
  uv venv .venv && source .venv/bin/activate
  echo "✅ .venv created & activated"
}
# If a .venv exists in a directory you `cd` into, auto-activate it
autoload -U add-zsh-hook
_auto_venv_activate() {
  if [[ -f ".venv/bin/activate" ]]; then
    source .venv/bin/activate
  elif [[ -n "$VIRTUAL_ENV" ]]; then
    deactivate 2>/dev/null
  fi
}
add-zsh-hook chpwd _auto_venv_activate

##### Kitty niceties #####
# Use kitty’s terminfo to avoid $TERM weirdness
if command -v kitty >/dev/null 2>&1; then
  export TERM="xterm-kitty"
fi

##### Prompt tweaks for git/diff tools #####
export GIT_EDITOR="$EDITOR"
export DELTA_FEATURES='line-numbers decorations'

# Final PATH touches (Homebrew first)
export PATH="/opt/homebrew/bin:$GOBIN:$HOME/.cargo/bin:$HOME/.local/bin:$PATH"
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
