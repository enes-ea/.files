function update-firmware
    command -q fwupdmgr; or begin
        echo "fwupd not installed"
        return 1
    end
    fwupdmgr refresh --force
    fwupdmgr get-updates
    fwupdmgr update
end
