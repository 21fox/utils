#!/bin/bash

#merge video with audio and decode anime

. fflib.sh

inmvi="$1"
inaud="$2"
mode="$3"

function checkInput() {
	if [ -z "$inmvi" ]
	then
		echo "[err]:set video dir"
		exit 1
	fi
	if [ -z "$inaud" ]
	then
		echo "[err]:set audio dir"
		exit 1
	fi
	echo "[info]:start fformat anime prompt"
}

function setStream() {
	declare -ga v_epd
	while read vepd
	do
		v_epd+=("$vepd")
	done <<< $(find "$inmvi"\
			 -maxdepth 1 -type f -exec basename {} \; | sort)

	declare -ga a_epd
	while read aepd
	do
		a_epd+=("$aepd")
	done <<< $(ls "$inaud")

	if [ "${#v_epd[@]}" != "${#a_epd[@]}" ]
	then
		echo "[err]:files not equal"
		exit 1
	fi
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
	ctall="${#v_epd[@]}"
	ctitr=1
}

function setFileName() {
	fepd="$inmvi"/"${v_epd[$ind]}"

	inaud=$(rmSlashName "$inaud")
	aepd="$inaud"/"${a_epd[$ind]}"

	ftv="$dtv"/"${v_epd[$ind]}"
	flog="${v_epd[$ind]}"
}

function setArg() {
	ffarg=(-y -i "$fepd" -i "$aepd"\
		-map 0:v -map 1:a\
		-c:v libx264 -preset slow -crf 15\
		-c:a aac\
		-vf format=yuv420p\
		"$ftv"\
		-nostdin)
}

function fgFF() {
	elapseTime "start"
	setPrgsMeta
	for ind in "${!v_epd[@]}"
	do
		setFileName
		setArg
		ffmpeg "${ffarg[@]}" 2>"/tmp/ffdirty.log" &
		procID=$!
		((ctitr=ind+1))
		showProgress
	done
	removeLoad
	elapseTime "end"
}

function bgFF() {
	echo "[info]:bg-run video decoder $fulltime"
	for ind in "${!v_epd[@]}"
	do
		setFileName
		setArg
		ffmpeg "${ffarg[@]}" 2>/dev/null
	done
	removeLoad
}

function getRun() {
	setOutDir
	setStream
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
