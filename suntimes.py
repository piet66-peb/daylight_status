#!/usr/bin/env python3
"""
suntimes.py.
"""
import sys
import datetime
from suntime import Sun
from settings import LATITUDE, LONGITUDE

#pylint: disable=invalid-name
arg1 = None
if len(sys.argv) >= 2:
    arg1 = sys.argv[1]

sun = Sun(LATITUDE, LONGITUDE)

time_zone = datetime.datetime.now()
sun_rise = sun.get_local_sunrise_time(time_zone)
sun_set = sun.get_local_sunset_time(time_zone)

if arg1 == 'sunrise':
    print("{} = {} = {}".format('sunrise', sun_rise.strftime('%s'), sun_rise))
elif arg1 == 'sunset':
    print("{} = {} = {}".format('sunset', sun_set.strftime('%s'), sun_set))
else:
    print("{} = {} = {}".format('sunrise', sun_rise.strftime('%s'), sun_rise))
    print("{} = {} = {}".format('sunset', sun_set.strftime('%s'), sun_set))
