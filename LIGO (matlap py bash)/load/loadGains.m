
% Find the pd gain for each lock
function [data] = loadGains(channel)

	global data_dir

	% All the lock times that we need an offset value for
	lockTimes = loadLockTimes();
	numLocks = length(lockTimes);

	data = zeros(numLocks,1);
	% Minute trend channel data to grab values from
	channelData = dlmread([data_dir channel '.dat']);
	
	global stride
	
	for i = 1:numLocks

		row = [];
		j = 0;
		while (isempty(row))
			row = find(channelData(:,1) == lockTimes(i,1)-j*stride);
			j = j + 1;
		end

		data(i) = channelData(row, 2); % Save the voltage
	end

end