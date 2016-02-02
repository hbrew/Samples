function [trans] = loadTransData(channel)
	global power_calib snr_min

	trans = struct();
	[trans.times power sd] = loadAvgData(channel);
	offsets = 3.129; % From L1:LSC-POP_A_LF_OFFSET
	offsets = offsets*power_calib;
	trans.power = power*power_calib - offsets;
	trans.dP = sd*power_calib; % Uncertainty in power

	% Keep values above minimum SNR
	% snr = abs((trans.power - offsets) ./ offsets);
	% usable = find(snr >= snr_min);
	% trans.power = trans.power(usable) - offsets(usable);
	% trans.times = trans.times(usable);
	% trans.dP = trans.dP(usable);

end