function [directory] = getDir(channel)
	global data_dir locks_dir
	directory = [data_dir locks_dir channel '/'];
end