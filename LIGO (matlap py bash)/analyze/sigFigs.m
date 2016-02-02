function [value delta] = sigFigs(value, delta)

	delta = roundsd(delta, 1);
	delta = num2str(delta);
	decimalPoint = find(delta == '.');
	if isempty(decimalPoint)
		decimalPoint = length(delta) + 1;
	else
		delta(decimalPoint) = '0';
	end
	nonZero = find(delta ~= '0', 1);
	if decimalPoint < length(delta)
		delta(decimalPoint) = '.';
	end
	precision = decimalPoint - nonZero;
	if (precision > 0)
		precision = precision - 1;
	end
	
	value = roundn(value, precision);
	value = num2str(value);
	if not(isempty(find(value == '.')))
		value = value(1:find(value ~= '0', 1, 'last'));
	end
	if not(isempty(find(delta == '.'))) % only removing trailing 0's if there is a decimal
		delta = delta(1:find(delta ~= '0', 1, 'last'));
		if length(value) == 1
			value = [value '.0']; % roundn removes decimal if its .0
		end
	end
end