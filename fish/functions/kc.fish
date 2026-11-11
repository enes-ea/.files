function kc
    set -l old_shell $SHELL
    set -gx SHELL fish
    keychain --eval --quiet git E2F0AA32BE0C869C | source
    set -gx SHELL $old_shell
end

