function [times values sd] = loadAvgData(channel)

	lockTimes = loadLockTimes();
	lockTimes = lockTimes(:,1); % Lock start times
	numLocks = length(lockTimes);
	times = zeros(numLocks, 1);
	values = zeros(numLocks, 1);
	sd = zeros(numLocks, 1);
	for i = 1:numLocks
		filepath = [getDir(channel) num2str(lockTimes(i)) '.dat'];
		[rawTimes rawValues] = loadRawData(filepath);
		times(i) = rawTimes(1); % lock start time
		sd(i) = std(rawValues);
		values(i) = median(rawValues); % avg channel value
		
	end
end