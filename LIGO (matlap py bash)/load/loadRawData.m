function [times values] = loadRawData(filepath)

	global sample_rate

	cutoff = 0*60; % remove first minutes from each lock
	first = cutoff*sample_rate + 1; % Number of samples to skip
	%last = first - 1;

	data = dlmread(filepath);
	data = data(first:end, :);
	times = data(:,1);
	values = data(:,2);

end