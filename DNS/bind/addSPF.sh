#!/bin/bash

fileDir=/var/cache/bind
files=($(ls -p $fileDir | grep -v / | grep -v named.stats ))

for f in "${files[@]}"
do
	echo "Dirbu su $f"
	hasSPF=$(grep spf $fileDir/$f | grep -v ";")
	if [ -z "$hasSPF" ]
	then
		echo -e "\e[31mSPF neradau\e[0m"

		serial=$(grep -o "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]" $fileDir/$f)
		echo -e "Serialinis nr. \e[34m$serial\e[0m"

		naujasSerial=$((serial+1))
		echo "Naujas serijos nr. $naujasSerial"

		sed -i -e "s/$serial/$naujasSerial/g" $fileDir/$f
		
		# Pridedu SPF irasa i faila
		#echo "	IN	TXT	\"v=spf1 mx -all\"" >> $fileDir/$f
		sed -i "/NS\tsizifas.gmc.lt/a \\\tIN\tTXT\t\"v=spf1 mx -all\"" $fileDir/$f
	else
		echo -e "\e[92mLSPF radau\e[0m"
		
		# Salinu jei paskutine eilute yra TXT
		# sed -i '${/v=spf1/d}' $fileDir/$f
#		sed -i '{/tIN\tTXT\t"v=spf1 mx -all"/d}' $fileDir/$f
	fi
done
