#!/usr/bin/env python

import scipy
import nds2
import sys
import time
import subprocess
import os.path



#conn = nds2.connection('l1nds0', 8088)
conn = nds2.connection('nds.ligo-la.caltech.edu', 31200)


# Get the gps time to start fetching data at
def getStartTime(filename):
	if  not os.path.isfile(filename) or int(os.stat(filename).st_size) == 0:
		#1084258816 # May 7 2014 22:58:00, first x arm transmission
		return 1085097616 # May 26 2014, oldest data we can retrieve
	last = ''
	f = open(filename, 'r')
	for line in f:
		last = line
	f.close()
	parts = last.split()
	time = parts[0]
	try:
		return int(time) + 60
	except ValueError:
		print "Invalid start time: " + time
		sys.exit()


# Update the file with data from the channel
def updateData(channel, filename):

	gps_start = getStartTime(filename)
	gps_stop = int(subprocess.check_output('tconvert now', shell=True).strip()) - 600 # Current gps time - 10 minutes
	gps_start = gps_start + (60 - gps_start % 60)
	gps_stop = gps_stop - gps_stop % 60
	
	dataFile = open(filename, 'a')
	stride = 120 # Interval to save data in seconds
	saveInterval = stride * 1000	

	try:
		for point in conn.iterate(gps_start, gps_stop, stride, [channel]):
			print point
			gps_current = point[0].gps_seconds
			dataFile.write(str(gps_current) + " " + str(point[0].data[0]) + "\n")

			# Update the file at an interval to reduce risk of data loss
			if (gps_current != gps_start):
				if (gps_current - gps_start) % saveInterval == 0:
					dataFile.close()
					dataFile = open(dataFile.name, dataFile.mode)

	except RuntimeError as e:
		print channel + ': ' + str(e)
		print 'Try again later'

	

	dataFile.close()



if __name__ == "__main__":

	channel = sys.argv[1]
	output = sys.argv[2]
	updateData(channel, output)

