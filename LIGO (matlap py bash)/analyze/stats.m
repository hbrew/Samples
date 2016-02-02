function stats(optic)

	for i = 1:length(optic.pd)
		BRDF = optic.pd(i).BRDF;
		outliers = find_outliers_Thompson(BRDF);
		nonOutliers = unique([[1:length(BRDF)]'; outliers]);
		BRDF = BRDF(nonOutliers);
		average = mean(BRDF);
		n = length(BRDF);
		standardDeviation= std(BRDF);
		standardError = standardDeviation/sqrt(n);
		dBRDF = optic.pd(i).dBRDF;
		dAverage = sqrt(sum(dBRDF.^2))/n;
		description = sprintf('mean: %f\nstd: %f\nstde: %f\nUncertainty: %f\n\n', average, standardDeviation, standardError, dAverage);
		subplot(2,2,i)
		hist(BRDF, 20)
		legend(description)
		title(['Pd' num2str(i)])
		ylabel('Count')
		xlabel('BRDF')
	end

end