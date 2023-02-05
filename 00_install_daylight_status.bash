#!/bin/bash
#h-------------------------------------------------------------------------------
#h
#h Name:         install_daylight_status.bash
#h Type:         Linux shell script
#h Purpose:      install python and daylight_status
#h Project:      
#h Usage:        copy folder to target place
#h               ./install_daylight_status.bash
#h Result:       
#h Examples:     
#h Outline:      
#h Resources:    
#h Platforms:    Debian Linux (Raspberry Pi OS, Ubuntu)
#h Authors:      peb piet66
#h Version:      V1.0.0 2023-01-16/peb
#v History:      V1.0.0 2022-12-09/peb first version
#h Copyright:    (C) piet66 2022
#h License:      http://opensource.org/licenses/MIT
#h
#h-------------------------------------------------------------------------------

MODULE='install_daylight_status.bash';
VERSION='V1.0.0'
WRITTEN='2023-01-16/peb'

#exit when any command fails
set -e

#set path constants
. `dirname $(readlink -f $0)`/00_constants

umask 000

# install python3
sudo apt install -y python3
python3 -V

#install pip3
sudo apt install -y python3-pip

#create and activate python environment
sudo apt install -y python3-venv
python3 -m venv $VIRTUAL_ENV
source $VIRTUAL_ENV/bin/activate

#newly create requirements.txt
#pip3 install pipreqs
#export PATH=$PATH:~/.local/bin
#pipreqs .

#install necessary packages
pip3 install -r requirements.txt

#display installed python packages
pip3 freeze

#install cron
function cron_add_line {
    l="$1"
    crontab -l
    if [ $? -eq 0 ]
    then
        echo remove line if existing:
        X=`crontab -l | sed "\:$l:d"`
        crontab -r 
        echo "$X" | crontab -
    fi

    echo add new line
    cat <(crontab -l) <(echo "$l") | crontab -
}

echo ''
echo installing cron-job for user $USER...
set +e
cron_add_line "@reboot $PACKET_PATH/$PACKET_NAME.bash >/dev/null 2>&1"  >/dev/null 2>&1

echo ''
echo start process with: ./11_get_procid.bash

