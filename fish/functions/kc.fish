function kc
    set -l old_shell $SHELL
    set -gx SHELL fish
    keychain --eval --quiet git CF21183797F5AB25 | source
    set -gx SHELL $old_shell
end

