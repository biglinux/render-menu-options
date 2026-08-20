#!/usr/bin/env bash
# Starts the application a .desktop file describes as a child of this process,
# so the render environment the caller set reaches it.
#
# `gio launch` does the reading -- the Exec key, its field codes and Terminal=
# are the Desktop Entry Specification's business, not this package's. What it
# cannot be asked to skip is DBusActivatable=true, and that is why the key is
# dropped from a copy first: with it present GLib calls Activate on the session
# bus instead of spawning, and D-Bus activation carries no environment. The app
# then opens on the default GPU with no error, and nothing shows that the entry
# did nothing. KIO activates the same way (kio, src/gui/kprocessrunner.cpp), so
# there is no launcher to delegate this to.
#
# The copy keeps the original file name: GLib derives the application id from
# it, and that id is what groups the window.

set -eu

desktop=${1:?usage: ${0##*/} DESKTOP-FILE}

staged=${XDG_RUNTIME_DIR:-/tmp}/render-menu-options
mkdir -p "$staged"
# Space around the equals sign is legal in a desktop entry, so the key is not
# matched by its name alone.
grep -vE '^[[:space:]]*DBusActivatable[[:space:]]*=' "$desktop" >"$staged/${desktop##*/}"

exec gio launch "$staged/${desktop##*/}"
