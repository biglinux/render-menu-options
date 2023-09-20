#!/usr/bin/env bash

IFS=$'\n'

folderType=(
/usr/share/applications
)
#if the flatpak directory exists add it to $folderType
if [ -d /var/lib/flatpak/exports/share/applications ];then
	folderType+=(/var/lib/flatpak/exports/share/applications)
fi
#add users to $folderType
for user in $(awk -F':' '{ if ($3 >= 1000 && $1 != "nobody") print $1 }' /etc/passwd); do
	if [ -e /home/"${user}"/.local/share/applications ];then
		folderType+=(/home/"${user}"/.local/share/applications)
	fi
done

RenderType=(
NvidiaRender
IntegratedRender
)

for render in ${RenderType[@]}; do
	for folder in ${folderType[@]}; do
		Applications=$(grep -sl "Action $render" $folder/*.desktop)
		for App in ${Applications[@]}; do
			#remove app from action=
			sed -i "/Actions=/s/$render;//g" $App
			#remove Desktop Action
			sed -i "/Desktop Action $render/,/^$/d" $App
		done
	update-desktop-database -q $folder
	done
done
