# ---- toolchain homes (XDG) ----
set -gx RUSTUP_HOME "$HOME/.local/share/rustup"
set -gx CARGO_HOME "$HOME/.local/share/cargo"
set -gx GOPATH "$HOME/.local/share/go"
set -gx npm_config_cache "$HOME/.local/cache/npm"
set -gx npm_config_prefix "$HOME/.npm-global"

if status is-interactive

    # -- delete when mobile done
    set -gx JAVA_HOME /usr/lib/jvm/java-21-openjdk
    set -gx ANDROID_HOME $HOME/Android/Sdk
    set -gx ANDROID_SDK_ROOT $ANDROID_HOME

    fish_add_path $HOME/Projects/.development/flutter/bin
    fish_add_path $ANDROID_HOME/platform-tools
    fish_add_path $ANDROID_HOME/cmdline-tools/latest/bin
    fish_add_path $ANDROID_HOME/emulator
    # -- delete when mobile done

    fish_add_path ~/.bin
    fish_add_path ~/.local/bin
    fish_add_path ~/.local/share/cargo/bin
    fish_add_path ~/.local/share/nvim/mason/bin
    fish_add_path ~/.local/share/go/bin
    fish_add_path ~/.npm-global/bin

    set -g fish_history_size 10000
    set -gx EDITOR nvim
    set -g async_prompt_functions _pure_prompt_git

    fish_config theme choose catppuccin-mocha --color-theme dark

    alias eza='eza --icons=always --color=always -h'
    alias l='eza -l --sort=type'
    alias la='eza -al --sort=type'
    alias lg='eza -l --sort=type --git'
    alias lag='eza -al --sort=type --git'
    alias ld='eza -lD'
    alias lS='eza -al --sort=size'
    alias lm='eza -al --sort=modified'
    alias lt='eza -l --tree'
    alias ltg='eza -l --tree --git'
    alias vim='nvim'
    alias rm='rm -r -i'
    alias on='z ~/Documents/Notes && nvim notes.md'
    alias t='go-task'

    function v
        if test (count $argv) -gt 0
            nvim $argv
        else
            set file (fd -t f -t l --color=always --strip-cwd-prefix=always | \
				fzf --height 30% --ansi --preview 'bat --style=numbers --color=always --line-range :200 {}')
            if test -n "$file"
                nvim "$file"
            end
        end
    end

    function vh
        if test (count $argv) -gt 0
            nvim $argv
        else
            set file (fd -H -t f -t l --color=always --strip-cwd-prefix=always | \
				fzf --height 30% --ansi --preview 'bat --style=numbers --color=always --line-range :200 {}')
            if test -n "$file"
                nvim "$file"
            end
        end
    end

    function y
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        yazi $argv --cwd-file="$tmp"
        if read -z cwd <"$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
            builtin cd -- "$cwd"
        end
        rm -f -- "$tmp"
    end

    function fzf
        functions -e fzf
        fzf --fish | source
        fzf $argv
    end

    function z
        functions -e z
        zoxide init fish | source
        z $argv
    end

    function zi
        functions -e zi
        zoxide init fish | source
        zi $argv
    end

    source ~/.config/fish/keybinds.fish

end

function zndev-lab
    bash -c 'set -a; . ./.env.lab; set +a; exec go run ./cmd/zndev "$@"' -- $argv
end

# Added by Antigravity CLI installer
set -gx PATH "/home/enes/.local/bin" $PATH
