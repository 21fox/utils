#!/bin/bash

#set audio track and decode tv episodes

. fflib.sh

inmvi="$1"
mode=$2

function checkInput() {
	if [ ! -d "$inmvi" ]
	then
		echo "[err]:set mkv dir"
		exit 1
	fi
	echo -e "\n[info]:start fformat tv episode prompt\n"
}

function setStream() {
	fstrm=$(ls -d "$inmvi"/* | head -1)
	askStream
	readCodec
}

function setOutDir() {
	inmvi=$(rmSlashName "$inmvi")
	dtv="$inmvi"".TV"
		if [ -d "$dtv" ]
		then
			rm -r "$dtv"
		fi
	mkdir "$dtv"
}

function setPrgsMeta() {
	ctall=$(ls "$inmvi" | wc -l | sed 's/ //g')
	ctitr=1
}

function setFileName() {
	fepd="$inmvi/$epd"
	ftv="$dtv/$epd"
	flog="$epd"
}

function setArg() {
	#argdd=""
        ffarg=(\
        	-i "$fepd" -y\
		-map 0:0 -map 0:"$aid"\
		#-c:v libx264 -vf format=yuv420p\
		$argdd "$ftv"\
		-nostdin
	      )
}

function fgFF() {
	elapseTime "start"
	setPrgsMeta
	setStream
	while read epd
	do
		setFileName
		setArg
		ffmpeg "${ffarg[@]}" 2>"/tmp/ffdirty.log" &
		procID=$!
		showProgress
		((ctitr++))
	done <<< $(ls "$inmvi")
		removeLoad
	elapseTime "end"
}

function bgFF() {
	echo "[info]:bg-run video decoder $fulltime"
	while read epd
	do
		setFileName
		setArg
		ffmpeg "${ffarg[@]}" 2>/dev/null
	done <<< $(ls "$inmvi")
	removeLoad
}

function getRun() {
	setOutDir
if [[ -z "$mode" || "$mode" != "-bg" ]]
then
	fgFF
elif [[ "$mode" = "-bg" ]]
then
	bgFF &
fi
}

checkInput
getRun
