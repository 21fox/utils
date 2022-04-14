#!/bin/bash
#set audio track and decode movie

. fflib.sh

inmvi=$1

function checkInput() {
	if [ ! -f "$inmvi" ]
	then
		echo "[err]:set mkv file"
		exit 1
	fi
	echo -e "\n[info]:start fformat movie prompt\n"
}

function parseMode() {
	shift 1
	for mod in "$@"
	do
		case $mod in
			-zip)
				iszip=1;;
			-bg)	
				isbg=1;;
		esac
	done
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
		echo "[info]: huge size $fsizeG start ZIP"
		if [ -z "$isbg" ]
		then
			./movie.sh "$ftv" -zip
		else
			./movie.sh "$ftv" -zip -bg &>/dev/null
		fi
		rm -r "$inmvi"
		exit 0
	fi
}

function bgFF() {
	echo "[info]:bg-run video decoder $fulltime"
	ffmpeg "${ffarg[@]}" 2>"/dev/null" 
	if [ -z "$iszip" ]
	then
		sizeZIP &>/dev/null
	fi
	removeLoad
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

	if [ -z "$isbg" ]
	then
		fgFF
	else
		bgFF &
	fi
}

checkInput
parseMode "$@"
getRun
