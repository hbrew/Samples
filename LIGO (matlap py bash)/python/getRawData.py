#!/usr/bin/env python

import scipy
import nds2
import sys
import time
import subprocess
import os.path
from multiprocessing import pool

lockDataDir = 'data/locks/' # Where to save data for each lock

connected = False
server = ('nds.ligo-la.caltech.edu', 31200) # Slow server by default

# find the time for the last saved data
def getLastTime(directory):
	if not os.path.isdir(directory):
		os.makedirs(directory)
	files = os.listdir(directory)
	if len(files) == 0:
		return 0
	files.sort()
	parts = files[-1].split('.dat')
	return int(parts[0])

# read in and return the lock times from the file given
def getLockTimes(filename, threshold):
	f = open(filename)
	lockTimes = []
	for line in f:
		parts = line.split()
		parts = (int(parts[0]),int(parts[1]))
		if parts[0] > threshold:
			lockTimes.append(parts)
	return lockTimes

# Connect to the appropriate nds server based on how far back we're grabbing data
# This should result in opening at most 2 connections
def connect(start_time):
	global conn
	global connected
	global server

	fast_server = ('l1nds0', 8088)
	slow_server = ('nds.ligo-la.caltech.edu', 31200)
	next_server = server

	# if we're on the slow server, decide if the fast server could be used
	if server == slow_server:
		current_time = int(subprocess.check_output('tconvert now', shell=True).strip())
		fast_time = current_time - 12*24*60*60 # earliest time the fast server will have data

		if start_time >= fast_time:
			next_server = fast_server
		if not connected or next_server != server:
			conn = nds2.connection(next_server[0], next_server[1]) # connect to the next server
			connected = True
			server = next_server # set the current server


# Fetches raw data from the channel for times given in the file
def getData(channel, timesFile):
	outputDir = lockDataDir + channel[3:].split('.')[0] + '/'
	print outputDir
	lastSaved = getLastTime(outputDir) # Last time data was retrieved
	lockTimes = getLockTimes(timesFile, lastSaved) # Times we need data for
	for time in lockTimes:
		try:
			connect(time[0]) # Set the connection to the appropriate server
			filePath = outputDir + str(time[0]) + '.dat'
			buffers = conn.fetch(time[0], time[1], [channel])
			f = open(filePath, 'w')
			for point in buffers:
				print point
				for i in range(0,len(point.data)):
					f.write(str(point.gps_seconds + i) + ' ' + str(point.data[i]) + '\n')
			f.close()
		except RuntimeError as e:
			errorMessage = 'Unable to retrieve data from ' + str(time[0]) + ' to ' + str(time[1])
			errorMessage += ' from ' + server[0] + '\n'
			errorMessage += 'Error: ' + str(e)
			print errorMessage
			break # Don't want to continue after missing a lock


if __name__ == "__main__":

	channel = sys.argv[1]
	timesFile = sys.argv[2]
	getData(channel, timesFile)
