#!/usr/bin/env bash

sudo systemctl start render-menu-options.service
sudo systemctl start render-menu-options-flatpak.service
systemctl --user start render-menu-options-user.service
