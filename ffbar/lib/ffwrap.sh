#!/bin/bash
# video decode progress bar

outdir="/web/stor/watchtv"
fulltimeTV=0

function askStream()
{
	ffprobe "$fstrm" 2>&1\
		 | grep -E 'Stream.*Audio.*|title'\
		 | sed '/Stream/,$!d'\
		 | sed -n '/.*Subtitle.*/q;p'
	echo
	read -p "[action]:set audio stream:" aid
	echo
}

function readCodec() {
	acodec=( $(ffprobe "$fstrm"\
			-v error\
			-select_streams a:$((aid - 1))\
			-show_entries stream=codec_name\
			-of default=noprint_wrappers=1:nokey=1))
	if [ "$acodec" = "dts" ]
	then
		argdd="-vcodec copy -acodec ac3"
	else
		argdd="-c copy"
	fi
}

function elapseTime() {
	modeTime="$1"
	if [ "$modeTime" = "start" ]
	then
		startime=$(date +%s)
	elif [ "$modeTime" = "end" ]
	then
		endtime=$(date +%s)
		runtime=$((endtime-startime))
		runH=$(($runtime / 3600))
		runM=$((($runtime / 60) % 60))
		runS=$((runtime % 60))
		printf '[info]: elapsed: %02d:%02d:%02d\n' $runH $runM $runS
	fi

}

function timeToSec() {
	sec=$(echo $1\
		| awk -F: '{ print ($1 * 3600) + ($2 * 60) + $3 }')
	echo "$sec"
}

function rmSlashName() {
	dslash="$1"
	chlast="${dslash: -1}"
		if [ $chlast = "/" ]
		then
			dslash="${dslash::-1}"
		fi
	echo "$dslash"
}

function readFullTime() {
	fulltime=( $(ffprobe "$fepd" 2>&1\
			| sed -n "s/^.*Duration: //; s/, start.*$//p"))
	fulltime=${fulltime%.*}
	fullsec=$(timeToSec $fulltime)
}

function sumTimeTV() {
    tvsec=$(echo $fulltime | \
        awk -F: '{ print ($1 * 3600) + ($2 * 60) + $3 }')
    fulltimeTV="$tvsec + $fulltimeTV"
	fulltimeTV=$(echo $fulltimeTV | bc) 
}

function printSumTime() {
    fulltimeTV=$( \
    printf ' %02d:%02d:%02d\n'\
        $((fulltimeTV/3600)) \
        $(((fulltimeTV / 60) % 60)) \
        $((fulltimeTV%60)) \
    )
    echo "[info]: overall TV time: $fulltimeTV"
}

function readNowTime() {
	fftime=$(tail -1 /tmp/ffmpeg.log\
			| sed -n "s/^.*time=//; s/ bitrate.*$//p")
	fftime=${fftime%.*}
	ffsec=$(timeToSec $fftime)

	ffspd=$(tail -1 /tmp/ffmpeg.log\
			| sed 's/^.*speed=//'\
			| sed 's/^ *//g')
}

function showProgress() {
	readFullTime
	echo "[info]:run video decoder $fulltime"
	
	while kill -0 $procID >/dev/null 2>&1
	do
		sleep 2
		tr "\r" "\n" < /tmp/ffdirty.log > /tmp/ffmpeg.log 
		readNowTime
	if [ ! -z "$fftime" ]
	then
		progressLine
	echo -ne "["$ctitr/$ctall"] $progline $ffperc% $fftime $ffspd\r"
	fi

	done
	echo -ne "["$ctitr/$ctall"] $progline    100% $flog\n"
}

function progressLine() {
	ffperc=$(echo "scale=2; $ffsec / $fullsec * 100" | bc -l)
	ffperc=${ffperc%.*}
	percdiv=$(expr $ffperc / 10)

	progline="#"
	progit=1
	while [[ $progit -le $percdiv ]]
	do
		progline=$progline"#"
		((progit++))
	done
}

function removeLoad() {
	if [ ! -z "$dtv" ]
	then
		dlog="${dtv##*/}"
		dlog="$outdir/$dlog"

		mkdir "$dlog"
		while read line
		do
			mv "$line" "$dlog"
		done <<< $(ls "$dtv/"*)
		rm -r "$dtv"
	else
		mv "$ftv" "$outdir"
	fi
	rm -r "$inmvi"
}
