Scatter Analysis Program (SAP)
Author: Hunter Rew

From the scatter directory, you must first run config.m in order to add necessary paths and set constants.

Running scatter.m will: 
	1) update the locally saved data trends, 
	2) search for new locks from these trends, 
	3) update full data for any lock times found,
	4) pull data from the files and organize them into structs,
	5) calculate BRDF values for each PD of each optic,
	6) plot the results

In order to run any script which modifies the files (steps 1 - 3), you'll need to copy the files somewhere that you have write permissions.
You'll need the following in scatter/:
	analyze/
	data/ (You don't have to copy this, but it'll be a lot faster than pulling data from the servers)
	lib/
	load/
	plot/
	python/
	config.m
	scatter.m

If you'd like to only use the data that is already saved, execute the following in MATLAB:
	>> loadLockData
	>> plotLockData
This will do steps 4 through 6 above.

After running loadLockData, either directly or within scatter, you will have the following structs
trans
	.power (The cavity power in each arm)
	.times (Start times for each lock)
	.dP	(The uncertainty in power)
itmx, etmx, itmy, etmy
	.pd(1), .pd(2), .pd(3), .pd(4)
		.times
		.volts (Voltage on the PD for each lock)
		.gain (PD gain for each lock)
		.dV (Uncertainty in voltage)
		.BRDF (The BRDF values for each lock)
		.dBRDF (Uncertainty in BRDF)
		.power (Power on the PD for each lock)
		.dP (Uncertainty in the power)

the *tm* structs and their values represent the PDs installed AT that optic, so the values are the scatter FROM the opposing optic.
When running plotLockData the figure names are adjusted for this. So the "ETMX" figure is a plot of the itmx data, and so on.