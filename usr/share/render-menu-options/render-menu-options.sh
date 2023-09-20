#!/usr/bin/env bash

# Set Internal Field Separator to newline character to properly read each line of text
IFS=$'\n'

# Assign the first argument passed to the script to the variable "Folder"
folder=$1

# If not exist folder, just exit
if [[ ! -e $folder ]]; then
    exit
fi

renderType=(
SoftwareRender
)
# Check if the "optimus-manager" or "nvidia-prime" utility is installed and append to $renderType
if [ -e "/usr/bin/optimus-manager" -o -e "/usr/bin/prime-run" ]; then
    renderType+=(NvidiaRender)
    renderType+=(IntegratedRender)
# Check for amdGPU
# elif [  ]; then
#     renderType+=(amdGPURender)
#     renderType+=(IntegratedRender)
fi

# Loop over each application listed in the "Applications" variable
for render in ${renderType[@]}; do
    # Find all .desktop files in the specified folder that do not have an "Action $renderType"
    applications=$(grep -sLP "Actions=.*$render" $folder/*.desktop)
    for app in ${applications[@]}; do
        # Extract the "Exec" command from the .desktop file
        exec=$(grep -oPm1 "Exec=\K.*" "$app")
        # Check if the "Actions" line exists in the .desktop file
        if grep -q "Actions=" "$app"; then
            # Append the "renderType" value to the existing "Actions" line
            sed -i "/Actions=/s/$/${render};/" "$app"
        else
            # If "Actions" line doesn't exist, create it and set its value to "renderType"
            echo "
Actions=$render" >> "$app"
        fi
        # Loop over each rendering mode specified in "$renderType"
        echo "
[Desktop Action $render]
Name=${render/Render/ Render}
Exec=$render $exec" >> "$app"
    done
    # Update the desktop database to reflect changes in .desktop files
    update-desktop-database $folder
done


# # Define a function named AddRenderInFile
# AddRenderInFile() {
#     # Loop over each application listed in the "Applications" variable
#     for App in $Applications; do
#         # Extract the "Exec" command from the .desktop file
#         Exec=$(grep -oPm1 "Exec=\K.*" "$App")
#         
#         # Check if the "Actions" line exists in the .desktop file
#         if grep -q "Actions=" "$App"; then
#             # Append the "AddRender" value to the existing "Actions" line
#             sed -i "/Actions=/s/$/$AddRender/" "$App"
#         else
#             # If "Actions" line doesn't exist, create it and set its value to "AddRender"
#             echo "
# Actions=$AddRender" >> "$App"
#         fi
# 
#         # Loop over each rendering mode specified in "AddRender", separated by semicolons
#         IFS=";"; for RenderMode in $AddRender; do
#             # Add a new "[Desktop Action ...]" section for each rendering mode
#             echo "
# [Desktop Action $RenderMode]
# Name=${RenderMode/Render/ Render}
# Exec=$RenderMode $Exec" >> "$App"
#         done
#     done
# }
# 
# # Check if the "optimus-manager" utility is installed
# if [ -e "/usr/bin/optimus-manager" -o -e "/usr/bin/prime-run" ]; then
#     # Find all .desktop files in the specified folder that do not have an "Action NvidiaRender"
#     Applications=$(grep -L 'Action NvidiaRender' $Folder/*.desktop)
#     AddRender="NvidiaRender;IntegratedRender;SoftwareRender;" AddRenderInFile
# else
#     # Find all .desktop files in the specified folder that do not have an "Action SoftwareRender"
#     Applications=$(grep -L 'Action SoftwareRender' $Folder/*.desktop)
#     # Define render mode to add as "SoftwareRender;"
#     AddRender="SoftwareRender;" AddRenderInFile
# fi
# 
# # Update the desktop database to reflect changes in .desktop files
# update-desktop-database $Folder
