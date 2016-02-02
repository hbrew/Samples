
% Find the pd voltage before each lock to use as an offset
function [data] = loadDarkData(channel)

	global data_dir

	% All the lock times that we need an offset value for
	lockTimes = loadLockTimes();
	numLocks = length(lockTimes);

	data = zeros(numLocks,1);
	% Minute trend channel data to grab values from
	channelData = dlmread([data_dir channel '.dat']);
	
	global stride
	
	for i = 1:numLocks
		lastLock = 0;
		if (i > 1)
			lastLock = lockTimes(i-1,1);
		end
		fromLeft = find(channelData(:,1) > lastLock);
		fromRight = find(channelData(:,2) < lockTimes(i,1));
		darkDataIndex =  intersect(fromLeft, fromRight);
		darkDataIndex = sortrows(darkDataIndex);
		darkData = channelData(darkDataIndex, 2);
		data(i) =  min(darkData);

		% row = [];
		% j = 1;
		% while (isempty(row))
		% 	row = find(channelData(:,1) == lockTimes(i,1)-j*stride);
		% 	j = j + 1;
		% end

		%data(i) = channelData(row, 2); % Save the voltage
	end

end