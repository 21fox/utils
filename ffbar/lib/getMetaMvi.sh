#!/bin/bash
# database query

. ./lib/comm.sh

function showHelp() {
	echo -e "\
getMetaMvi options:\n\
\t-m [month] get movie records for m month\n\
\t-l get movie records for all time\n\
\t-g print aggregate time for each month\n\
\t-d [id] cleanup record with d id\n\
\t-h show CLI options"
    exit 1
}

function checkMonth() {
    allmonth="Jan Feb Mar Apr May Jun Jul Aug Sept Oct Nov Dec"
    qmonth=${qmonth^}
        if ! [[ " $allmonth " =~ " $qmonth " ]]
        then
            echo -e "[err]:set correct month -> \n$allmonth"
            exit 1
        else
            qmonth="${qmonth^}-`date +%y`"
        fi
}

function sumTimeTV() {
	tvsec=$(timeToSec $fulltime)
    fulltimeTV="$tvsec + $fulltimeTV"
	fulltimeTV=$(echo $fulltimeTV | bc) 
}

function printSumTime() {
    if [ -z $qmonth ]
    then
        qAll="select * from movie"
        sqlite3 -batch ./lib/cinema.db "$qAll"
    else
        qMonth="select * from movie \
                    where watched='$qmonth'"
        sqlite3 -batch ./lib/cinema.db "$qMonth"
    fi
    echo -e "\nTotal time: $fulltimeTV"
    exit 0
}

function sumTotal() {
    fulltimeTV=0
    while read fulltime
    do
        sumTimeTV
    done <<< $timeTotl
    fulltimeTV=$(timeToDate $fulltimeTV)
}

function getTimeCol() {
    if [ -z $qmonth ]
    then
        qAllTime="select long from movie"
        timeTotl=$(sqlite3 -batch ./lib/cinema.db <<EOF 
.headers off
    $qAllTime
EOF
)
    else
        qMonthTime="select long from movie \
                    where watched='$qmonth'"
        timeTotl=$(sqlite3 -batch ./lib/cinema.db <<EOF 
.headers off
    $qMonthTime
EOF
)
    fi
}

function getGroup() {
    qMonthAll="select distinct watched from movie"
    monthTotl=$(sqlite3 -batch ./lib/cinema.db <<EOF 
.headers off
    $qMonthAll
EOF
)
    gmonth="month\t\ttotal\n"
    while read mnth
    do
        qmonth=$mnth
        getTimeCol
        sumTotal
            gmonth+="${mnth}\t\t${fulltimeTV}\n"
    done <<< $monthTotl
    gmonth=${gmonth::-2}
    echo -e "$gmonth"
    exit 0
}

function checkNumID() {
    nre='^[0-9]+$'
    if ! [[ $delid =~ $nre ]]
    then
        echo "[err]: $delid not a number"
        exit 1
    fi
}

function delRecord() {
    sqlite3 -batch ./lib/cinema.db \
                    "delete from movie \
                        where id='$delid'"
    exit 0
}

function readArg() {
    OPTERR=0
    while getopts ":m:d:lgh" opt
    do
        case $opt in
        m)
            qmonth=$OPTARG
            checkMonth
            getTimeCol
            sumTotal
            printSumTime
            ;;
        l)
            getTimeCol
            sumTotal
            printSumTime
            ;;
        g)
            getGroup
            ;;
        d)
            delid=$OPTARG
            checkNumID
            delRecord
            ;;
        h)
            showHelp
            ;;
        :)
			echo "[err]: -$OPTARG requires arg"
			showHelp
            ;;
		*)
			echo "[err]: no option: -$OPTARG"
			showHelp
            ;;
        esac
    done
}

readArg "$@"

qmonth=`date +%h-%y`
    getTimeCol
    sumTotal
    printSumTime