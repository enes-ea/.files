function update
    paru -Syu --devel --combinedupgrade --sudoloop
    rustup update
    fisher update
    gh extension upgrade --all
    npm update -g
    uv tool upgrade --all
    nvim -c UpdateAll
end
