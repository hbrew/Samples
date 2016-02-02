function [pd] = loadPdData(voltsChannel, gainChannel)
	global snr_min

	pd = struct();
	[pd.times pd.volts sd] = loadAvgData(voltsChannel);
	pd.gain = loadGains(gainChannel);
	offsets = loadVoltsOffsets(voltsChannel);
	pd.volts = abs(pd.volts - offsets);
	pd.dV = abs(sd); % Uncertainty in voltage

	% Keep values above minimum SNR
	% snr = abs((volts - offsets) ./ offsets);
	% usable = find(snr >= snr_min);
	% pd.times = pd.times(usable);
	% pd.gain = pd.gain(usable);
	% pd.volts = abs(volts(usable) - offsets(usable));
	% pd.dV = pd.dV(usable);

end