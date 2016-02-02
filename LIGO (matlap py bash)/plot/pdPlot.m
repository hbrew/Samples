function pdPlot(optic)
	disp('');
	table_string = '';
	for i = 1:length(optic.pd)
		plot_index = 2*i - 1;

		subplot(4,2,plot_index)
		hold all
		transverse = 1:length(optic.pd(i).BRDF);
		plot(transverse, optic.pd(i).BRDF + optic.pd(i).dBRDF, 'g')
		plot(transverse, optic.pd(i).BRDF - optic.pd(i).dBRDF, 'r')
		plot(transverse, optic.pd(i).BRDF, 'b')
		title(['Pd' int2str(i)])
		xlabel('Lock Number')
		ylabel('BRDF')
		legend('+ Uncertainty', '- Uncertainty', 'Calculated Value')
		grid on


		h = subplot(4,2,plot_index + 1);
		BRDF = optic.pd(i).BRDF;
		outliers = find_outliers_Thompson(BRDF);
		nonOutliers = setdiff([1:length(BRDF)], outliers);
		BRDF = BRDF(nonOutliers);
		average = mean(BRDF);
		n = length(BRDF);
		standardDeviation= std(BRDF);
		standardError = standardDeviation/sqrt(n);
		dBRDF = optic.pd(i).dBRDF;
		dAverage = sqrt(sum(dBRDF.^2))/n;
		[average, dAverage] = sigFigs(average, dAverage);
		formatString = [ ...
			'mean: %s\\pm%s\n' ...
			'std: %f\n' ...
			'stde: %f\n' ...
		];
		description = sprintf( ...
			formatString, ...
			average, ... 
			dAverage, ...
			standardDeviation, ...
			standardError ...
		);
		formatString = '\t<tr><td>%u</td><td>%s&#177;%s</td><td>%0.2f</td><td>%0.2f</td></tr>\n';
		table_string = [table_string sprintf( ...
			formatString, ...
			i, ...
			average, ... 
			dAverage, ...
			standardDeviation, ...
			standardError ...
		)];
		hist(BRDF, 20)
		legend(description)
		set(h, 'YAxisLocation', 'right');
		title(['Pd' num2str(i)])
		ylabel('Count')
		xlabel('BRDF')
	end
	disp(table_string);
	hold off

end