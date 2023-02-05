#!/bin/bash
#h-------------------------------------------------------------------------------
#h
#h Name:         daylight_status.bash
#h Type:         Linux shell script
#h Purpose:      in an infinite loop:
#h                 - reads sunsrise and sunset time 
#h                 - stores the light status into a RRD database
#h Project:        
#h Installation: - 00_install_daylight_status.bash
#h               - add settings to settings file
#h Usage:        ./daylight_status.bash
#h               start manually:
#h                 DAYLIGHT=/media/ZWay_USB/daylight_status
#h                 cd $DAYLIGHT
#h                 $DAYLIGHT/daylight_status.bash >/dev/null 2>&1 &
#h               run at boot:
#h                 crontab -e (not as root !!!)
#h                 and enter:
#h                   DAYLIGHT=/media/ZWay_USB/daylight_status
#h                   #@reboot $DAYLIGHT/daylight_status.bash >$DAYLIGHT/daylight_status.bash.log 2>&1
#h                   @reboot  $DAYLIGHT/daylight_status.bash >/dev/null 2>&1
#h
#h               invoke suntimes.py manually:
#h                 python3 ./suntimes.py sunrise
#h                 python3 ./suntimes.py sunset
#h Result:       
#h Examples:     
#h Outline:      
#h Resources:    python3, suntimes.py, rrd_info.bash, store_data.bash, rrdtool
#h Platforms:    Linux
#h Authors:      peb piet66
#h Version:      V1.0.0 2023-01-09/peb
#v History:      V1.0.0 2022-12-09/peb first version
#h Copyright:    (C) piet66 2022
#h License:      MIT
#h
#h-------------------------------------------------------------------------------

VERSION='V1.0.0'
WRITTEN='2023-01-09/peb'

cd `dirname $0`
umask a+rw
LOG=`basename $0`.log
date >$LOG

echo EUID=$EUID
if [ -z $EUID ]
then 
      echo "can't run as root"
      exit 1
fi
if [ $EUID == 0 ]
then 
      echo "can't run as root"
      exit 1
fi

#b constants
#-----------
_self="${0##*/}"
GET_SUNRISE='python3 suntimes.py sunrise'
GET_SUNSET='python3 suntimes.py sunset'

#b set python environment
#------------------------
cd `dirname $0`
. ./00_constants >>$LOG 2>&1

#b take settings
#---------------
. ./settings >>$LOG 2>&1

#b read rrb parameters
#---------------------
. ./rrd_info.bash >>$LOG 2>&1

if [ "$LONGITUDE" != "" ]
then
    echo "#changed by $_self" > ./settings.py
    echo "LONGITUDE = $LONGITUDE" >> ./settings.py
    echo "LATITUDE = $LATITUDE" >> ./settings.py
fi

#b functions
#-----------
function delay() {
    next=$1
    T=$(date +%s)             #current time in seconds
    #echo $T
    (( delay=NEXT-T ));       # delay time in seconds
    echo $delay
}

function get_sun_data() {
    SUNRISE_LONG=`$GET_SUNRISE`
    SUNRISE=`echo $SUNRISE_LONG | cut -f3 -d' '`
    SUNSET_LONG=`$GET_SUNSET`
    SUNSET=`echo $SUNSET_LONG | cut -f3 -d' '`
    lastmidnight=$(date -d "$today 0" +%s)
    nextmidnight=$((lastmidnight + 86400))
    echo $SUNRISE_LONG
    echo $SUNSET_LONG
    echo sunrise: $SUNRISE
    echo sunset: $SUNSET
    echo nextmidnight: $nextmidnight
}

function get_times() {
    step=$1
    currhour=$(date +%_H)
    currtime=$(date +%s)
    (( rrd_time=(currtime/step)*step ));
    (( next_sleep=rrd_time + step - currtime ));
    echo step=$step
    echo currtime=$currtime
    echo rrd_time=$rrd_time
    echo next_sleep=$next_sleep
    echo currhour=$currhour
}

#b commands
#----------
    #b delay to synchronize with rrd database
    #----------------------------------------
    delay_secs=`delay $NEXT`
    echo sleeping for $delay_secs seconds
    sleep $delay_secs

    #b get initial values
    #--------------------
    get_sun_data
    lasthour=$(date +%_H)
    if [ "$SUNRISE" == "" ]
    then
        echo 'error getting sunrise, break.'
        echo ''
        $GET_SUNRISE
        echo ''
        exit 1
    fi

    #b infinite loop
    #---------------
    echo invoke infinite loop
    while true
    do
        #b examine daylight value
        #------------------------
        get_times $STEP
        if (( $currtime <= $SUNRISE ))
        then
            VALUE=$NIGHT
        elif (( $currtime <= $SUNSET ))
        then
            VALUE=$DAY
        elif (( $currtime <= $nextmidnight ))
        then
            VALUE=$NIGHT
        else
            get_sun_data    #next day
            VALUE=$NIGHT
        fi

        #b store value to database
        #-------------------------
        if [ "$STORE_LOCAL_RBB" == true ]
        then
            echo ./store_rrd_local.bash $rrd_time $VALUE
            ./store_rrd_local.bash $rrd_time $VALUE
        fi

        if [ "$STORE_REMOTE_RBB" == true ]
        then
            echo ./store_rrd_remote.bash $rrd_time $VALUE
            /store_rrd_remote.bash $rrd_time $VALUE
        fi

        #b get sun data again in case of switching daylight saving time
        #--------------------------------------------------------------
        if (( $currhour > 3 )) && (( $lasthour <= 3 ))
        then
            get_sun_data
        fi
        lasthour=$currhour

        #b wait for next run
        #-------------------
        sleep $next_sleep
    done
