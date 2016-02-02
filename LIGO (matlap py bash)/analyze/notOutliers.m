function [indices] = notOutliers(data)

	limit = 3; % standard deviations from mean
	differences = abs(data - mean(data));
	indices = find(differences <= limit*std(data));

end