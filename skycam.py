import os
import gphoto2 as gp
import math
import time
from suncalc import get_position, get_times
from datetime import datetime


lon = 34.8
lat = 31.9

#os.chdir("/home/ocs/Desktop")
#camera = gp.Camera()
#camera.init()

#while(true):
#
#    date = datetime.now()
#    sunpos = get_position(date, lon, lat)
#    sunalt = math.degrees(sunpos['altitude'])
#
#    if(sunalt < -5):
#        
#
#    else:
#        time.sleep(60)
