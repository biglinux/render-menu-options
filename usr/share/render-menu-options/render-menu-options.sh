#!/usr/bin/env bash

IFS=$'\n'

AddRender() {
for App in $Applications; do
	# Select first Exec in .desktop
	Exec=$(grep -oPm1 "Exec=\K.*" "$App")
	# Verify if Actions exist
	if ! grep -q "Actions=" "$App"; then
		# Add to Actions
		sed -i "/Actions=/s/$/$AddRender/" "$App"
	else
		# Create Actions
		echo "
Actions=$AddRender" >> "$App"
	fi

	# Use ; as separator and add Actions based in $AddRender
	IFS=";"; for RenderMode in $AddRender; do
		echo "
[Desktop Action $RenderMode]
Name=${RenderMode/Render/ Render}
Exec=$RenderMode $Exec" >> "$App"
	done
done
}

if [[ $UUID = 0 ]]; then
	# If running as root, search in native and flatpak folder
	Folder='/var/lib/flatpak/exports/share/applications/*.desktop /usr/share/applications/*.desktop'
else
	# If running as user, search in home folder
	Folder="$HOME/.local/share/applications/*.desktop"
fi


# If have optimus-manager Add nvidia, integrated and software options
# Else only add software option
# Maybe in future need add amdgpu
if [ -e "/usr/bin/optimus-manager" ]; then
	# Verify files in native and flatpak folder without NvidiaRender
	Applications=$(grep -L 'Action NvidiaRender' $Folder)
	AddRender="NvidiaRender;IntegratedRender;SoftwareRender;" AddRender
else
	# Verify files in native and flatpak folder without SoftwareRender
	Applications=$(grep -L 'Action SoftwareRender' $Folder)
	AddRender="SoftwareRender;" AddRender
fi

#Update database of desktop entries
update-desktop-database
