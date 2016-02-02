function [first, last] = stable(trans)

	first = 1;
	last = length(trans.power);

	good = find(trans.power > 2000);
	sets = zeros(length(good), 2);
	m = 1; % row in sets
	n = 1; % column in sets
	for i = 1:length(good)
		if (n == 2)
			if (sets(m,2) == 0)
				if (good(i) ~= sets(m,1) + 1)
					n = 1;
					m = m + 1;
				end
			elseif (good(i) ~= sets(m,2) + 1)
				n = 1;
				m = m + 1;
			end
		end
		sets(m,n) = good(i);
		n = 2;
	end
	[bleh, best] = max(sets(:,2) - sets(:,1));
	first = sets(best,1);
	last = sets(best,2);

	% [maxima imax minima imin] = extrema(power(first:last));
	% if (length(maxima) > 1)
	% 	maxima = sortrows([imax, maxima]);
	% 	minima = sortrows([imin, minima]);
	% 	if (maxima(1,1) < minima(1,1))
	% 		maxima = maxima(2:end, :);
	% 	end
	% 	if (minima(end,1) > maxima(end,1))
	% 		minima = minima(1:end-1, :);
	% 	end
	% 	changes = [];
	% 	for i = 1:length(maxima) - 1
	% 		changes = [
	% 			changes;
	% 			abs(maxima(i,2) - maxima(i+1,2)), maxima(i,1)
	% 		];
	% 	end
	% 	%changes = [[maxima(:,2) - minima(:,2)], minima(:,1), maxima(:,1) ];
	% 	good = find(changes(:,1) < 500);
	% 	sets = zeros(length(good), 2);
	% 	m = 1; % row in sets
	% 	n = 1; % column in sets
	% 	for i = 1:length(good)
	% 		if (n == 2)
	% 			if (sets(m,2) == 0)
	% 				if (good(i) ~= sets(m,1) + 1)
	% 					n = 1;
	% 					m = m + 1;
	% 				end
	% 			elseif (good(i) ~= sets(m,2) + 1)
	% 				n = 1;
	% 				m = m + 1;
	% 			end
	% 		end
	% 		sets(m,n) = good(i);
	% 		n = 2;
	% 	end

	% 	[bleh, best] = max(sets(:,2) - sets(:,1));
	% 	last = changes(sets(best,2), 2) + 1 + first;
	% 	first = changes(sets(best,1), 2) + first;
		
	% end

end