function [times] = loadLockTimes(channel)

	global lock_times_file
	times = dlmread(lock_times_file);

end