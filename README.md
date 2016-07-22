# rman_log
A simple script to get the status of rman backups

The purpose of this script is to print out the statuses of RMAN backups. The recid, stamp and status of each backup for the supplied date will be returned.

If you pass the recid and stamp of any particular backup using the -R and -S options, you can view the full output for the backup.

It only requires the sid assuming your oracle admin is the standard sidadm account. If it is not, supply the admin name with the -u option.

A good use for this script is to schedule it as a cron job and redirect the output to a log file that can be read later.


Example cron job: 

    59 23 * * * /rman_log.sh -s sid > /nsr/applogs/log.rman.`date +'\%Y\%m\%d'`
    
    Runs the job each night at 11:59 using todays date and logs the output into our networker applogs directory with a date formatted logfile name.
    
## Usage:

-s sid : Supply the sid of your Oracle DB. The only truly required option.

-d DD-MON-YY : Supply a date (will use today if option not set) must be in RMAN format i.e. 15-JUL-16

-u user : Supply the oracle OS user account (will use sidadm if option not set).

-R SESSION_RECID : if a RECID is supplied a STAMP must also be supplied. 

-S SESSION_STAMP : With the STAMP and RECID you can get the full output of the specific job. Helpful when job status is not "COMPLETE"
  


