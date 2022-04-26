#!/bin/bash
#set audio track and decode movie

. ./lib/ffwrap.sh
. ./lib/ffdb.sh

inmvi=$1
iszip="$2"

function checkInput() {
	if [ ! -f "$inmvi" ]
	then
		echo "[err]:set mkv file"
		exit 1
	fi
	echo -e "\n[info]:start fformat movie prompt\n"
}

function setStream() {
	fstrm="$inmvi"
	askStream
	readCodec
}

function setArg() {
	if [ -z "$iszip" ]
	then
		setStream
		ffarg=(\
			-i "$fepd" -y\
			-map 0:0 -map 0:"$aid"\
			$argdd "$ftv"
		      )
	else
		ffarg=(\
			-i "$fepd" -y\
			-c:v libx264 -crf 19 -preset slow\
			-c:a copy "$ftv"
		      )
	fi
}

function sizeZIP()
{
	fsize=$(wc -c "$ftv" | awk '{printf "%d\n", $0/1024/1024/1024}')
	if [ $fsize -ge 25 ]
	then
		echo "[info]: huge size $fsize start ZIP"
		./movie.sh "$ftv" -zip	
		rm -r "$inmvi"
		exit 0
	fi
}

function fgFF() {
	elapseTime "start"
	ffmpeg "${ffarg[@]}" 2>"/tmp/ffdirty.log" &
	procID=$!
		setPrgsMeta
		showProgress
	elapseTime "end"
	if [ -z "$iszip" ]
	then
		extraMeta
		sizeZIP
	fi
	removeLoad
}

function setPrgsMeta() {
	ctall=1
	ctitr=1
}

function setFileName() {
	fepd="$inmvi"
	if [ -z "$iszip" ]
	then
		ftv=$(sed 's/\.mkv/\.TV\.mkv/' <<< "$inmvi")
	else
		ftv=$(sed 's/\.mkv/\.ZIP\.mkv/' <<< "$inmvi")
	fi
	flog="${inmvi##*/}"
}

function getRun() {
	setFileName
	setArg
	fgFF
}

checkInput
getRun
