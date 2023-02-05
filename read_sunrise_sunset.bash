#!/bin/bash
#h-------------------------------------------------------------------------------
#h
#h Name:         readsunrise_sunset.bash
#h Type:         Linux shell script
#h Purpose:      prints sunrise + sunset
#h Project:      
#h Usage:        ./readsunrise_sunset.bash
#h Result:       
#h Examples:     
#h Outline:      
#h Resources:    
#h Platforms:    Linux
#h Authors:      peb piet66
#h Version:      V1.0.0 2023-01-10/peb
#v History:      V1.0.0 2022-12-11/peb first version
#h Copyright:    (C) piet66 2022
#h License:      MIT
#h
#h-------------------------------------------------------------------------------

MODULE='readsunrise_sunset.bash';
VERSION='V1.0.0'
WRITTEN='2023-01-10/peb'

#b set python environment
#------------------------
cd `dirname $0`
. ./00_constants

python3 ./suntimes.py sunrise
python3 ./suntimes.py sunset


