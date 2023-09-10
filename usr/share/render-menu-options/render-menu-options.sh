#!/usr/bin/env bash

IFS=$'\n'

native=$(find /usr/share/applications/ -iname "*.desktop")
flatpak=$(find /var/lib/flatpak/exports/share/applications/ -iname "*.desktop")

nvidiaRender() {
#lista todos os .desktop da pasta /usr/share/applications/
for i in $native $flatpak; do
	#verificar se o arquivo existe
	if [ -f "$i" ];then
		#Verificar se já tem nvidiaRender no .desktop, evita duplicar
		if [ -z "$(grep nvidiaRender "$i")" ];then
			#executavel do .desktop
			exec=$(grep -oPm1 "Exec=\K.*" "$i")
			#verifica se já tem Actions
			if [ -n "$(grep "Actions=" "$i")" ];then
				#adiciona ao Action
				sed -i '/Actions=/s/$/nvidiaRender;/' "$i"
			else
				#cria um Action
				echo "
Actions=nvidiaRender;" >> "$i"
			fi
			#Escrever no arquivo
			echo "
[Desktop Action nvidiaRender]
Name=Nvidia Render
Exec=nvidia-render $exec" >> "$i"
		fi
	fi
done
}

# amdgpuRender(){
#
# }

integratedRender() {
for i in $native $flatpak; do
	#verificar se o arquivo existe
	if [ -f "$i" ];then
		#Verificar se já tem nvidiaOffLoad no .desktop, evita duplicar
		if [ -z "$(grep integratedRender "$i")" ];then
			#executavel do .desktop
			exec=$(grep -oPm1 "Exec=\K.*" "$i")
			#verifica se já tem Actions
			if [ -n "$(grep "Actions=" "$i")" ];then
				#adiciona ao Action
				sed -i '/Actions=/s/$/integratedRender;/' "$i"
			else
				#cria um Action
				echo "
Actions=integratedRender;" >> "$i"
			fi
			#Escrever no arquivo
			echo "
[Desktop Action integratedRender]
Name=Integrated Render
Exec=integrated-render $exec" >> "$i"
		fi
	fi
done
}

softwareRender() {
for i in $native $flatpak; do
	#verificar se o arquivo existe
	if [ -f "$i" ];then
		#Verificar se já tem nvidiaOffLoad no .desktop, evita duplicar
		if [ -z "$(grep softwareRender "$i")" ];then
			#executavel do .desktop
			exec=$(grep -oPm1 "Exec=\K.*" "$i")
			#verifica se já tem Actions
			if [ -n "$(grep "Actions=" "$i")" ];then
				#adiciona ao Action
				sed -i '/Actions=/s/$/softwareRender;/' "$i"
			else
				#cria um Action
				echo "
Actions=softwareRender;" >> "$i"
			fi
			#Escrever no arquivo
			echo "
[Desktop Action softwareRender]
Name=Software Render
Exec=software-render $exec" >> "$i"
		fi
	fi
done
}

# if hybrid
#nvidia
if [ -e "/usr/bin/optimus-manager" ]; then
	nvidiaRender
	integratedRender
#amdgpu
#elif [  ];then
	
fi

#softwareRender
softwareRender

#Update database of desktop entries
update-desktop-database /usr/share/applications
