#!/bin/bash
# watch cinema reporting

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
    qMonthTemp="create table totlmonth (watched, total);"
    qMonthAll="select distinct watched from movie"
    monthTotl=$(sqlite3 -batch ./lib/cinema.db <<EOF 
.headers off
    $qMonthTemp
    $qMonthAll
EOF
)
    while read mnth
    do
        qmonth=$mnth
        getTimeCol
        sumTotal
        sqlite3 -batch ./lib/cinema.db \
            "insert into totlmonth values(\"$mnth\", \"$fulltimeTV\");"
    done <<< $monthTotl
}

function countMovie() {
    getGroup
    qMovieCount="select \
                    mstc.watched, \
                    coalesce(sum(seasons), 0) as seasons, \
                    coalesce(sum(movies), 0) as movies, \
                    ttm.total \
                from ( \
                    select mst.*, \
                        case when mst.season='seasons' \
                            then number end as 'seasons', \
                        case when mst.season='movies' \
                            then number end as 'movies' \
                    from ( \
                                select watched, \
                                    case when eps=1 then 'movies' \
                                    else 'seasons' end as season, \
                                    count(id) as number \
                                from movie\
                                group by watched, season \
                    ) mst \
                ) mstc \
                inner join totlmonth ttm \
                    on mstc.watched = ttm.watched \
                group by mstc.watched;"

qMonthDrop="drop table if exists totlmonth"
cnTotl=$(sqlite3 -batch ./lib/cinema.db <<EOF 
    $qMovieCount
    $qMonthDrop
EOF
)
    echo "$cnTotl"
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
            countMovie
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