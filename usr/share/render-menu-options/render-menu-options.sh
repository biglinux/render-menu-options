#!/usr/bin/env bash
# Publishes the render entries Plasma's application menu offers.
#
# Plasma reads /usr/share/plasma/kickeractions and runs the chosen entry with
# the target application's own desktop file as its argument (plasma-workspace,
# applets/kicker/actionlist.cpp). One file therefore reaches every application,
# where this package used to edit every .desktop file it found.
#
# Run once per boot, because a boot is when the GPUs can have changed, and
# because a package installed while building an ISO would otherwise record the
# GPUs of the machine that built it.
#
# The GPU numbers in the template are not detected: switcherooctl numbers the
# GPUs identically in `list` and in `launch -g`, and moves the default one to
# the front, so 0 is always the GPU driving the display and 1 always the first
# other one. All the hardware decides is whether there is a second GPU at all,
# and whether it is a dedicated card or an integrated one -- which is the
# question switcheroo-control exists to answer, and the same one KDE puts to it
# (kio, src/gui/gpudetection.cpp). Asking rather than guessing from PCI vendor
# ids is what keeps "run with the NVIDIA GPU" off a machine whose NVIDIA card
# is already the one driving the display.
#
# Published is the shipped template with its Actions line narrowed. Names
# arrive already translated, from po/ via msgfmt at build time.

set -eu

template=${RENDER_MENU_TEMPLATE:-/usr/share/render-menu-options/render-menu-options.desktop}
target=${RENDER_MENU_TARGET:-/usr/share/plasma/kickeractions/render-menu-options.desktop}

# `switcherooctl list` prints a Device/Name/Default/Discrete/Environment block
# per GPU, and nothing at all when the service cannot be reached -- which
# leaves the software entry alone, the honest offer when the GPUs are unknown.
second_gpu=
device=
while read -r key value; do
    case $key in
    Device:) device=$value ;;
    Discrete:)
        if [[ $device == 1 ]]; then
            if [[ $value == yes ]]; then
                second_gpu=DiscreteGpu
            else
                second_gpu=IntegratedGpu
            fi
        fi
        ;;
    esac
done < <(switcherooctl list)

# A second GPU is what makes "run on the other one" mean anything.
renders=(SoftwareRender)
if [[ -n $second_gpu ]]; then
    renders+=(DefaultGpu "$second_gpu")
fi

# Without this key Plasma reads the file, finds the action groups and shows
# nothing, which looks exactly like the package not being installed.
grep -q '^Actions=' "$template" || {
    printf '%s: no Actions line to narrow\n' "$template" >&2
    exit 1
}

mkdir -p "$(dirname "$target")"
actions=$(
    IFS=';'
    echo "${renders[*]};"
)
trap 'rm -f "$target.new"' EXIT
sed "s/^Actions=.*/Actions=$actions/" "$template" >"$target.new"
mv "$target.new" "$target"
