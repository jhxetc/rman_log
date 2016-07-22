#!/bin/bash

## The purpose of this script is to print out the statuses of RMAN backups. The recid, stamp and status of each backup for the supplied date will be returned.
## If you pass the recid and stamp of any particular backup using the -R and -S options, you can view the full output for the backup.
## It only requires the sid assuming your oracle admin is the standard sidadm account. If it is not, supply the admin name with the -u option.
## A good use for this script is to schedule it as a cron job and redirect the output to a log file that can be read later.

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin

RMAN_LOG_DATE=
RMAN_RECID=
RMAN_STAMP=
RMAN_OUTPUT=
ORA_BIN=
ORA_SID=
ORA_USR=

#Get the recid, stamp and status of the backups for the supplied date. If no date is set, we will use todays date.
get_rman_status ()
{
	
	local SQL="set pagesize 1000\n select SESSION_RECID,SESSION_STAMP,START_TIME,END_TIME,STATUS from V\"'$'\"RMAN_STATUS where START_TIME like '$RMAN_LOG_DATE' order by SESSION_RECID;"
	RMAN_OUTPUT=$(su - "$ORA_USR" -c "echo \"$SQL\" | sqlplus -s '/ as sysdba'")
}
#END run_rman_status

get_rman_output ()
{
	local SQL="set pagesize 50000\n select OUTPUT from GV\"'$'\"RMAN_OUTPUT where SESSION_RECID = '$RMAN_RECID' and SESSION_STAMP = '$RMAN_STAMP' order by SESSION_RECID;"
	RMAN_OUTPUT=$(su - "$ORA_USR" -c "echo \"$SQL\" | sqlplus -s '/ as sysdba'")
}
#END run_rman_output

#Parse the options
while getopts "d:s:u:R:S:" OPTION; do
	case "${OPTION}" in
		d)
			#Format must be DD-MON-YY i.e. 15-JUL-16
			RMAN_LOG_DATE="$OPTARG"
		;;
		s)
			#3 letter security identifier for your Oracle instance
			ORA_SID=$(echo "$OPTARG" | tr [A-Z] [a-z])
		;;
		u)
			#Oracle OS admin account
			ORA_USR="$OPTARG"
		;;
		R)
			#SESSION_RECID
			RMAN_RECID="$OPTARG"
		;;
		S)
			#SESSION_STAMP
			RMAN_STAMP="$OPTARG"
		;;
		?)
			echo "Invalid option: '-$OPTION $OPTARG'"
			echo
			echo "Usage: $(basename $0) -s 'sid' -u 'username' -d 'date' -R 'recid' -S 'session stamp'"
			exit 1
		;;
	esac
done

if [[ -z "$ORA_SID" && -z "$ORA_USR" ]]; then
	echo "Error: SID was not set with option -s"
	exit 1
elif [[ -n "$ORA_SID" && -z "$ORA_USR" ]]; then
	ORA_USR="ora${ORA_SID}"
fi
	
if [[ -z "$RMAN_LOG_DATE" ]]; then
	RMAN_LOG_DATE=$(date +'%y-%b-%d' | tr [a-z] [A-Z])
fi

if [[ -z "$RMAN_RECID" && -z "$RMAN_STAMP" ]]; then
	get_rman_status
	echo "$RMAN_OUTPUT"
elif [[ -n "$RMAN_RECID" && -n "$RMAN_STAMP" ]]; then
	get_rman_output
	echo "$RMAN_OUTPUT"
else
	echo "Error: Options -R and -S must both be set."
	exit 1
fi
	