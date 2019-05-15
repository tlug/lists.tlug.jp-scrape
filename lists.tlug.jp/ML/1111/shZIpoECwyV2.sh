#!/bin/bash -x
# br, sept 2007 - Dec 2010
# 
# NAME
#	backup.sh - a remote backup over ssh using specific rsync facilities.
#
# SYNOPSIS
#	backup.sh [-ymwd]
#	-ymwd: performs yearly/monthly/weekly/daily backup
#
#	More than one argument can be given.
#	If no argument is given, the script will decide by itself:
#		- everytime invoked, daily backup
#		- if invoked on Monday, weekly backup
#		- if invoked on 1st of current month, monthly backup
#		- if invoked on Jan 1st, yearly backup
#
# HOWTO
#	Just change the script name if you need more than one (recommended anyway).
#	Ensure your ssh setup is correct: You must be able to ssh the target machine
#	without password.
#	Change variables in setup section just below. They are self explanatory.
#	
# BUGS
#	Many. Especially: This works on a "terastation" server, which is a kind of light Linux.
#
# TODO
#	week/month/year should be moved in an unique loop.
#	Setup section to be moved in a config file.
#	

############################################### SETUP SECTION
SOURCEDIR=/home/br		# full path
SERVER=terastation		# could also be user@hostname
DESTDIR=/mnt/array1/br		# full path, or relative to home directory on target machine

NYEARS=3
NMONTHS=12
NWEEKS=4
NDAYS=7

EXCLUDE="	--exclude .adobe \
		--exclude .cache \
		--exclude .gvfs \
		--exclude .dvdcss \
		--exclude .local \
		--exclude Cache \
		--exclude .thumbnails \
		--exclude gnutella \
		--exclude bittorent \
		--exclude .macromedia/* \
		--exclude perso \
		--exclude Private \
		--exclude mnt \
		--exclude tera
"
echo EXCL=$EXCLUDE

############################################### END OF SETUP SECTION

cd ${SOURCEDIR}

YEARLY=n
MONTHLY=n
WEEKLY=n
DAILY=n

# decide which backup(s) to perform.
if [ $# = 0 ]
then
	dayweek=`date +%u`
	[ ${dayweek} -eq 1 ] && WEEKLY=y
	daymonth=`date +%d`
	[ ${daymonth} -eq 1 ] && MONTHLY=y
	month=`date +%m`
	[ ${month} -eq 1 ] && [ ${daymonth} -eq 1 ] && YEARLY=y
	DAILY=y
else
	while getopts ymwd todo
	do
		case "${todo}" in
		y)	YEARLY=y;;
		m)	MONTHLY=y;;
		w)	WEEKLY=y;;
		d)	DAILY=y;;
		*)	echo "usage: $0 \[-ymwd\]"; exit 1;;
		esac
	done
fi

echo +++++++++++++++++++++++++++ starting $0 Y=${YEARLY} M=${MONTHLY} W=${WEEKLY} D=${DAILY} at `date`

DOIT="ssh ${SERVER}"
EXIST="${DOIT} test -e"
MOVE="${DOIT} mv"
CREATE="${DOIT} mkdir"
TOUCH="${DOIT} touch"
REMOVE="${DOIT} rm -rf"
COPYHARD="${DOIT} rsync -ar"

# builds number list, decreasing (2 digits only).
function build_numbers () {
	awk -v nb=$1 'BEGIN { for (i = nb; i >= 0; i--) { printf "%02d\n", i };}'
}

# rotate files. $1-$2 are base names, such as weekly-01. $2 is first removed then replaced by $2-1, etc...
function rotate-files () {
	filename=${1}
	let last=${2}
	let tomove=0
	files=(`build_numbers ${last}`)
	echo $files
	echo ${files[0]}	

	echo ${EXIST} "${DESTDIR}/${filename}-${files[0]}" && ${REMOVE} "${DESTDIR}/${filename}-${files[0]}"
	${EXIST} "${DESTDIR}/${filename}-${files[0]}" && ${REMOVE} "${DESTDIR}/${filename}-${files[0]}"

	while [ $tomove != $last ]
	do
		let from=$tomove+1
		${EXIST} "${DESTDIR}/${filename}-${files[$from]}" && ${MOVE} "${DESTDIR}/${filename}-${files[$from]}" "${DESTDIR}/${filename}-${files[$tomove]}"
		let tomove++
	done
}

# Daily backup.
if [ A${DAILY} =  Ay ]
then
	echo daily backup...
	${EXIST} "${DESTDIR}/daily-00" && \
		echo "Ooops: ${DESTDIR}/daily-00 already exists. Please cleanup or check last backup is over. Exiting." && \
		exit 1

	rsync	\
		-ai \
		--delete \
		--delete-excluded \
		${EXCLUDE} \
		--modify-window=1 \
		--link-dest="../daily-01" \
		. \
		${SERVER}:${DESTDIR}/daily-00

	${TOUCH} "${DESTDIR}/daily-00"

	rotate-files daily ${NDAYS}
fi

if [ A${WEEKLY} =  Ay ]
then
	echo weekly backup...

	${EXIST} "${DESTDIR}/weekly-00" && \
		echo "Ooops: ${DESTDIR}/weekly-00 already exists. Please cleanup or check last backup is over. Exiting." && \
		exit 1

	! ${EXIST} "${DESTDIR}/daily-01" && \
		echo "Ooops: ${DESTDIR}/daily-01 does not exist. Exiting." && \
		exit 1

	${COPYHARD} --link-dest="${DESTDIR}/daily-01" "${DESTDIR}/daily-01/" "${DESTDIR}/weekly-00"
	rotate-files weekly ${NWEEKS}
fi

if [ A${MONTHLY} =  Ay ]
then
	echo monthly backup...

	${EXIST} "${DESTDIR}/monthly-00" && \
		echo "Ooops: ${DESTDIR}/monthly-00 already exists. Please cleanup or check last backup is over. Exiting." && \
		exit 1

	! ${EXIST} "${DESTDIR}/daily-01"  && \
		echo "Ooops: ${DESTDIR}/daily-01 does not exist. Exiting." && \
		exit 1

	${COPYHARD} --link-dest="${DESTDIR}/daily-01" "${DESTDIR}/daily-01/" "${DESTDIR}/monthly-00"
	rotate-files monthly ${NMONTHS}
fi

if [ A${YEARLY} =  Ay ]
then
	echo yearly backup...

	${EXIST} "${DESTDIR}/yearly-00" && \
		echo "Ooops: ${DESTDIR}/yearly-00 already exists. Please cleanup or check last backup is over. Exiting." && \
		 exit 1

	! ${EXIST} "${DESTDIR}/daily-01" && \
		echo "Ooops: ${DESTDIR}/daily-01 does not exist. Exiting." && \
		exit 1

	${COPYHARD} --link-dest="${DESTDIR}/daily-01" "${DESTDIR}/daily-01/" "${DESTDIR}/yearly-00"
	rotate-files yearly ${NYEARS}
fi

echo +++++++++++++++++++++++++++ ending $0 backup at `date`
exit 0
