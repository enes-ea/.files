function univpn
    sudo openconnect \
        --user=enesemre.aydogan21@ogr.atauni.edu.tr \
        --protocol=gp \
        --csd-wrapper=/usr/lib/openconnect/hipreport.sh \
        --script "vpn-slice 172.17.12.0/24" \
        sslportal.atauni.edu.tr
end
