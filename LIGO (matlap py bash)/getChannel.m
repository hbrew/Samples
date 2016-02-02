function [channel] = getChannel(channelName, channelType)
	global trend_channel full_channel channel_prefix
	channel = [channel_prefix channelName];
	keys = {'trend', 'full'};
	values = {trend_channel, full_channel};
	channelTypes = containers.Map(keys, values);
	channel = [channel channelTypes(channelType)];
end
		