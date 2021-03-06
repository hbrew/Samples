
trans = struct();
itmx = struct();
itmy = struct();
etmx = struct();
etmy = struct();

fprintf('\nLoading arm transmission values\n')
[trans] = loadTransData(channels.input);


fprintf('\nLoading baffle pd data\n')
pd_num = 1:4;
for i = pd_num
	itmx.pd(i) = loadPdData(channels.x.pd.volts(i,:), channels.x.pd.gain(i,:));
	etmx.pd(i) = loadPdData(channels.x.pd.volts(i+4,:), channels.x.pd.gain(i+4,:));
	itmy.pd(i) = loadPdData(channels.y.pd.volts(i,:), channels.y.pd.gain(i,:));
	etmy.pd(i) = loadPdData(channels.y.pd.volts(i+4,:), channels.y.pd.gain(i+4,:));
end

fprintf('\nAnalyzing data:\n')

volts = zeros(length(pd_num),1);
dV = zeros(length(pd_num),1);
gains = zeros(length(pd_num),1);

numLocks = min([length(itmx.pd(1).volts), length(itmx.pd(2).volts), length(itmx.pd(3).volts), length(itmx.pd(4).volts)]);
fprintf('ITMX\n')
for i = 1:numLocks

	for j = pd_num
		volts(j) = itmx.pd(j).volts(i);
		dV(j) = itmx.pd(j).dV(i);
		gains(j) = itmx.pd(j).gain(i);
	end
	[BRDF dBRDF pdPower dP] = baffle_pd(volts, dV, gains, trans.power(i), trans.dP(i));
	for j = pd_num
		itmx.pd(j).BRDF(i) = BRDF(j);
		itmx.pd(j).dBRDF(i) = dBRDF(j);
		itmx.pd(j).power(i) = pdPower(j);
		itmx.pd(j).dP(i) = dP(j);
	end
end

numLocks = min([length(etmx.pd(1).volts), length(etmx.pd(2).volts), length(etmx.pd(3).volts), length(etmx.pd(4).volts)]);
fprintf('ETMX\n')
for i = 1:numLocks

	for j = pd_num
		volts(j) = etmx.pd(j).volts(i);
		dV(j) = etmx.pd(j).dV(i);
		gains(j) = etmx.pd(j).gain(i);
	end
	[BRDF dBRDF pdPower dP] = baffle_pd(volts, dV, gains, trans.power(i), trans.dP(i));
	for j = pd_num
		etmx.pd(j).BRDF(i) = BRDF(j);
		etmx.pd(j).dBRDF(i) = dBRDF(j);
		etmx.pd(j).power(i) = pdPower(j);
		etmx.pd(j).dP(i) = dP(j);
	end
end

numLocks = min([length(itmy.pd(1).volts), length(itmy.pd(2).volts), length(itmy.pd(3).volts), length(itmy.pd(4).volts)]);
fprintf('ITMY\n')
for i = 1:numLocks

	for j = pd_num
		volts(j) = itmy.pd(j).volts(i);
		dV(j) = itmy.pd(j).dV(i);
		gains(j) = itmy.pd(j).gain(i);
	end
	[BRDF dBRDF pdPower dP] = baffle_pd(volts, dV, gains, trans.power(i), trans.dP(i));
	for j = pd_num
		itmy.pd(j).BRDF(i) = BRDF(j);
		itmy.pd(j).dBRDF(i) = dBRDF(j);
		itmy.pd(j).power(i) = pdPower(j);
		itmy.pd(j).dP(i) = dP(j);
	end
end

numLocks = min([length(etmy.pd(1).volts), length(etmy.pd(2).volts), length(etmy.pd(3).volts), length(etmy.pd(4).volts)]);
fprintf('ETMY\n')
for i = 1:numLocks

	for j = pd_num
		volts(j) = etmy.pd(j).volts(i);
		dV(j) = etmy.pd(j).dV(i);
		gains(j) = etmy.pd(j).gain(i);
	end
	[BRDF dBRDF pdPower dP] = baffle_pd(volts, dV, gains, trans.power(i), trans.dP(i));
	for j = pd_num
		etmy.pd(j).BRDF(i) = BRDF(j);
		etmy.pd(j).dBRDF(i) = dBRDF(j);
		etmy.pd(j).power(i) = pdPower(j);
		etmy.pd(j).dP(i) = dP(j);
	end

end

