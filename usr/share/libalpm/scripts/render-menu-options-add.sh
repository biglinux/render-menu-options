#!/usr/bin/env bash

systemctl start render-menu-options.service
systemctl start render-menu-options-flatpak.service
for user in $(awk -F':' '{ if ($3 >= 1000 && $1 != "nobody") print $1 }' /etc/passwd); do
    if [ -e /home/"${user}"/.local/share/applications ];then
        /usr/share/render-menu-options/render-menu-options.sh "/home/"${user}"/.local/share/applications/"
    fi
done
