function getLockTimes(fileIn, fileOut)
	global lock_threshold min_lock_duration stride


	transData = dlmread(fileIn);

	% Remove rows from transData that have already been analyzed
	existingData = [0,0];
	if (exist(fileOut, 'file') == 2) % Is there already data?
		existingData = dlmread(fileOut);
		existingData = existingData(end,:);
	else
		fclose(fopen(fileOut, 'w')); % Create the file
	end
	new_start = find(transData(:,1) > existingData(2), 1);
	transData = transData(new_start:end, :);

	% Find all rows that could be a lock
	lockIndex = find(transData(:,2) > lock_threshold);

	% Create an empty matrix to fill with lock start and end times
	rows = length(lockIndex);
	lockTimes = zeros(rows, 2);

	m = 1; % row
	n = 1; % column
	for i = 1:rows
		index = lockIndex(i);
		time = transData(index,1);
		if (n == 2)
			if (lockTimes(m,n) == 0)
				if (time ~= lockTimes(m,1) + stride)
					m = m + 1;
					n = 1;
				end
			elseif (time ~= lockTimes(m,n) + stride)
				m = m + 1;
				n = 1;
			end
		end
		lockTimes(m,n) = time;
		n = 2;
	end

	% Get the start and end times that have at least a certain number of points between them
	lockTimes2 = [];
	for i = 1:rows
		lock = lockTimes(i,:);
		first = lock(1);
		last = lock(2);
		if ((last - first) > min_lock_duration)
			lockTimes2 = [lockTimes2; first, last];
		end
	end

	% Save the new data
	[numLocks, c] = size(lockTimes2);
	dlmwrite(fileOut, lockTimes2, '-append', 'delimiter', ' ', 'precision', 10);
	fprintf('%u new locks\n', numLocks);

end