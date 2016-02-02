
format long

% fprintf('Loading workspace\n')
% tic
% load('data.mat')
% toc

fprintf('Defining constants\n')

tic
addpath('analyze','lib','load','plot');

global data_dir locks_dir py_dir

data_dir = 'data/';
locks_dir = 'locks/';
py_dir = 'python/';


global channels
channels = struct();

%global xLockTimesFile yLockTimesFile
% xLockTimesFile = [data_dir 'x_lock_times.dat'];
% yLockTimesFile = [data_dir 'y_lock_times.dat'];
% fullLockTimesFile = [data_dir 'full_lock_times.dat'];
global lock_times_file
lock_times_file = [data_dir 'lock_times.dat'];

global trend_channel full_channel channel_prefix
trend_channel = '.mean,m-trend';
full_channel = '.mean,s-trend';
channel_prefix = 'L1:';


% channels.x.trans = ['LSC-X_TR_A_LF_OUTPUT'];
% channels.y.trans = ['LSC-Y_TR_A_LF_OUTPUT'];
% %channels.x.trans = ['ASC-X_TR_A_SUM_INMON'];
% %channels.y.trans = ['ASC-Y_TR_A_SUM_INMON'];
% channels.x.trans_gain = ['ASC-X_TR_A_WHITEN_GAIN'];
% channels.y.trans_gain = ['ASC-Y_TR_A_WHITEN_GAIN'];
% channels.x.trans_norm = ['LSC-TR_X_NORM_OUTPUT'];
% channels.y.trans_norm = ['LSC-TR_Y_NORM_OUTPUT'];

channels.input = ['LSC-POP_A_LF_OUTPUT'];
channels.input_norm = ['LSC-POP_A_LF_NORM_MON'];

channels.x.pd.volts = [];
channels.x.pd.gain = [];
channels.y.pd.volts = [];
channels.y.pd.gain = [];
% itm channels
for i = 1:4
	channels.x.pd.volts = [
		channels.x.pd.volts;
		['AOS-ITMX_BAFFLEPD_' int2str(i) '_VOLTS']
	];
	channels.y.pd.volts = [
		channels.y.pd.volts;
		['AOS-ITMY_BAFFLEPD_' int2str(i) '_VOLTS']
	];
	channels.x.pd.gain = [
		channels.x.pd.gain;
		['AOS-ITMX_BAFFLEPD_' int2str(i) '_GAIN']
	];
	channels.y.pd.gain = [
		channels.y.pd.gain;
		['AOS-ITMY_BAFFLEPD_' int2str(i) '_GAIN']
	];
end
% etm channels
for i = 1:4
	channels.x.pd.volts = [
		channels.x.pd.volts;
		['AOS-ETMX_BAFFLEPD_' int2str(i) '_VOLTS']
	];
	channels.y.pd.volts = [
		channels.y.pd.volts;
		['AOS-ETMY_BAFFLEPD_' int2str(i) '_VOLTS']
	];
	channels.x.pd.gain = [
		channels.x.pd.gain;
		['AOS-ETMX_BAFFLEPD_' int2str(i) '_GAIN']
	];
	channels.y.pd.gain = [
		channels.y.pd.gain;
		['AOS-ETMY_BAFFLEPD_' int2str(i) '_GAIN']
	];
end

% Useful constants
global lock_threshold min_lock_duration stride sample_rate power_calib snr_min

lock_threshold = 20; % Arm transmission where we'll say lock has started or finished
min_lock_duration = 1800; % 15 minutes
stride = 120; % seconds between data points
sample_rate = 1; % for lock data
power_calib = (416*2/pi)/2; % POP output to cavity power (W)
snr_min = 0.5; % minimum signal to noise ratio

who

toc

%channels of interest
%L1:ASC-X_TR_A_WHITEN_GAIN
%L1:ASC-X_TR_A_SUM_INMON

