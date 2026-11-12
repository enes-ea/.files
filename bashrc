# vim: ft=bash

# ---- toolchain homes (XDG) ----
export RUSTUP_HOME="$HOME/.local/share/rustup"
export CARGO_HOME="$HOME/.local/share/cargo"
export GOPATH="$HOME/.local/share/go"
export npm_config_cache="$HOME/.local/cache/npm"
export npm_config_prefix="$HOME/.npm-global"

[[ $- != *i* ]] && return

# ── Env ────────────────────────────────────────────────────────
export EDITOR=nvim
export VISUAL=nvim
export PAGER=bat
export MANPAGER="sh -c 'col -bx | bat -l man -p'"   # cleaner than the awk approach
export GPG_TTY=$(tty)

# ── PATH ───────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$HOME/.local/share/cargo/bin:$HOME/.local/share/go/bin:$PATH"

# ── Colors ─────────────────────────────────────────────────────
export LS_COLORS="$(vivid generate catppuccin-mocha)"
export MANROFFOPT="-c"

# ── Tools ──────────────────────────────────────────────────────
export FZF_DEFAULT_OPTS=" \
--layout=reverse \
--color=bg+:#313244,bg:#1E1E2E,spinner:#F5E0DC,hl:#F38BA8 \
--color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
--color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
--color=selected-bg:#45475A \
--color=border:#6C7086,label:#CDD6F4"
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
# ── Aliases ────────────────────────────────────────────────────
alias ls='eza --color=always --icons=always'
alias ll='eza -la --color=always --icons=always --git'
alias lt='eza --tree --color=always --icons=always --level=2'
alias grep='grep --color=auto'
alias cat='bat --paging=never'
alias cd='z'        # zoxide
alias vim='nvim'
alias g='git'

# ── Zoxide ─────────────────────────────────────────────────────
eval "$(zoxide init bash)"

# ── Prompt ─────────────────────────────────────────────────────
PS1='[\u@\h \W]\$ '


export PATH="$HOME/.local/bin:$PATH"
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk
export ANDROID_HOME="$HOME/Android/Sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$HOME/Projects/.development/flutter/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/emulator:$PATH"

# Mason tools last: system binaries win
export PATH="$PATH:$HOME/.local/share/nvim/mason/bin"
