
% Save the current path and the system path
matlabPath = getenv('LD_LIBRARY_PATH');
libPath = getenv('PATH');

%---- Generate the commands to call python and update the local data
commands = struct();

%-- Trend data commands
commands.input_norm_trend = [
	['python ' py_dir 'getTrendData.py ' getChannel(channels.input_norm, 'trend') ' ' data_dir channels.input_norm '.dat'];
];
commands.input_trend = [
	['python ' py_dir 'getTrendData.py ' getChannel(channels.input, 'trend') ' ' data_dir channels.input '.dat'];
];
commands.volts_trend = [];
commands.gain_trend = [];
for i = 1:length(channels.x.pd.volts(:,1))
	commands.volts_trend = [
		commands.volts_trend;
		['python ' py_dir 'getTrendData.py ' getChannel(channels.x.pd.volts(i,:), 'trend') ' ' data_dir channels.x.pd.volts(i,:) '.dat'];
		['python ' py_dir 'getTrendData.py ' getChannel(channels.y.pd.volts(i,:), 'trend') ' ' data_dir channels.y.pd.volts(i,:) '.dat']
	];
	commands.gain_trend = [
		commands.gain_trend;
		['python ' py_dir 'getTrendData.py ' getChannel(channels.x.pd.gain(i,:), 'trend') ' ' data_dir channels.x.pd.gain(i,:) '.dat'];
		['python ' py_dir 'getTrendData.py ' getChannel(channels.y.pd.gain(i,:), 'trend') ' ' data_dir channels.y.pd.gain(i,:) '.dat']
	];
end

%-- Full data commands
commands.input = [
	['python ' py_dir 'getRawData.py ' getChannel(channels.input, 'full') ' ' lock_times_file];
];
commands.volts = [];
commands.gain = [];
for i = 1:length(channels.x.pd.volts(:,1))
	commands.volts = [
		commands.volts;
		['python ' py_dir 'getRawData.py ' getChannel(channels.x.pd.volts(i,:), 'full') ' ' lock_times_file];
		['python ' py_dir 'getRawData.py ' getChannel(channels.y.pd.volts(i,:), 'full') ' ' lock_times_file]
	];
end


%---- Save the commands to files which a python script will read

%-- Write the trend data file
trendCommandsFile = [py_dir 'trend_commands.txt'];
f = fopen(trendCommandsFile, 'w');
fprintf(f, '%s\n', commands.input_trend);
fprintf(f, '%s\n', commands.input_norm_trend);
for i = 1:length(commands.volts_trend(:,1))
	fprintf(f, '%s\n', commands.volts_trend(i,:));
end
for i = 1:length(commands.gain_trend(:,1))
	fprintf(f, '%s\n', commands.gain_trend(i,:));
end
fclose(f);

%-- Write the raw data file
rawCommandsFile = [py_dir 'raw_commands.txt'];
f = fopen(rawCommandsFile, 'w');
fprintf(f, '%s\n', commands.input);
for i = 1:length(commands.volts(:,1))
	fprintf(f, '%s\n', commands.volts(i,:));
end
fclose(f);

%---- Update minute trend data
fprintf('\nUpdating minute trend data\n')
setenv('LD_LIBRARY_PATH', libPath);
tic
system(['python ' py_dir 'multiCall.py ' trendCommandsFile]);
setenv('LD_LIBRARY_PATH', matlabPath);
toc

%---- Update arm lock times
fprintf('\nUpdating lock times\n')
tic
getLockTimes([data_dir channels.input_norm '.dat'], lock_times_file);
toc

%---- Update raw data
fprintf('\nUpdating raw channel data\n')
setenv('LD_LIBRARY_PATH', libPath);
tic
system(['python ' py_dir 'multiCall.py ' rawCommandsFile]);
toc
setenv('LD_LIBRARY_PATH', matlabPath);

%---- Load, sort, and analyze data
tic
loadLockData
toc

%---- Plot the brdf data
fprintf('\nPlotting BRDF data\n')
tic
plotLockData
toc

%---- Save workspace variables so this doesn't need to be ran everyday
fprintf('\nSaving workspace\n')
tic
save('data.mat')
toc