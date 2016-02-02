function [BRDF, dBRDF, pd_watts, dPs] = baffle_pd(pd_data, dVs, gain, cavity_power, dPi)


	%Baffle PD caclulations

	%YAG 444 photodiode specifications
	resp = 0.25; %responsitivity A/W at 1065 nm  (0.2-0.3)
	dR = 0.05; % Uncertainty in responsivity
	active_area = 100; %mm^2

	%Baffle comes in through Beckhoff, PLC3

	%BAFFLE ITMY EP2316
	%Gain Outputs are 0

	%BAFFLE ITMY EP3174
	%Inputs
	%16 bit data (including sign, so -32768 to +32768) , Differential input
	%from +/- 10 Volts (or 0/4..20mA)
	% So 3.0518e-4 Volts/count

	%This counts -> volts conversion is taken care of in the DCPower.Volts = EL3104(DCPowerIn.Power) call

	%Transimpedance resistor is 20000 Ohms ??? This doesn't look correct
	%(L1:AOS-ITMY_BAFFLEPD_1_VOLTS / 20000) / responsitivity = watts
	%L1:AOS-ITMY_BAFFLEPD_1_VOLTS * 7.1429e-5 watts/volt

	transimpedance = 20000; %ohms
	calib = 1/resp/transimpedance./gain; % watts/volt
	calib = [calib];
	dCalib = calib.*dR./resp;


	%PD are of "TransAmp" type (i.e. L1:AOS-ITMY_BAFFLEPD_1_PHOTODIODETYPE)
	%amplifier is of "Baffle" type (i.e. L1:AOS-ITMY_BAFFLEPD_1_AMPLIFIERTYPE)
	%Offset is 0 (i.e. L1:AOS-ITMY_BAFFLEPD_1_OFFSET)
	%Transimpedance is 20000 (i.e. L1:AOS-ITMY_BAFFLEPD_1_TRANSIMPEDANCE)
	%GainSettings i 0 (i.e. L1:AOS-ITMY_BAFFLEPD_1_GAINSETTING)
	%Gain is 1 (i.e. L1:AOS-ITMY_BAFFLEPD_1_GAIN)
	%Responsivity is 0.10000000149 (i.e. L1:AOS-ITMY_BAFFLEPD_1_RESPONSIVITY)
	%SplitterR is 0 (i.e. L1:AOS-ITMY_BAFFLEPD_1_SPLITTERR)
	%Nominal is 0 (i.e. L1:AOS-ITMY_BAFFLEPD_1_NOMINAL)

	%From DCPower library:
	%DCcurrent = 1000 * (Volts - Offset) / (Gain * Transimpedance)
	%DCPower = DCcurrent / Responsitivity
	%PowerMon = DCPower * (100/SplitterR)
	%Normalized = DCcurrent/Nominal (or -1 when no nominal)




	% %LIGO DCC D1200657
	% %PD positions relative to center of baffle hole
	% %Baffle hole center from bottom right (looking at baffle from arm side,
	% %towards the ITMY
	% baffle_center_x = 8.85 * 25.4; % mm (converted from inches)
	% baffle_center_y = 8.53 * 25.4; % mm (converted from inches)

	% %PD 1 upper right
	% %center measured from bottom right
	% pd1_center_x = 3.192 * 25.4; % mm (converted from inches)
	% pd1_center_y = (2.7+8.64+2.689) * 25.4; % mm (converted from inches)

	% %PD top
	% %center measured from bottom right
	% pd2_center_x = (2.7+8.64+2.689+11.015)*25.4; %mm (converted from inches)
	% pd2_center_y = 14.505*25.4; %mm (converted from inches)

	% %PD far left
	% %center measured from bottom right
	% pd3_center_x = (14.505+11.259) * 25.4; %mm (converted from inches)
	% pd3_center_y = (2.7+8.64) * 25.4; %mm (converted from inches)


	% %PD 4 lower left
	% %center measured from bottom right
	% pd4_center_x = 2.7*25.4; %mm (converted from inches)
	% pd4_center_y = 14.505*25.4; %mm (converted from inches)

	% offset_distance = [sqrt((pd1_center_x - baffle_center_x)^2 + (pd1_center_y - baffle_center_y)^2);
	%     sqrt((pd2_center_x - baffle_center_x)^2 + (pd2_center_y - baffle_center_y)^2);
	%     sqrt((pd3_center_x - baffle_center_x)^2 + (pd3_center_y - baffle_center_y)^2);
	%     sqrt((pd4_center_x - baffle_center_x)^2 + (pd4_center_y - baffle_center_y)^2);];

	% arm_length = 4e6;  %%mm (approx)

	% pd_offset_angle = [0;0;0;0];
	% for x = 1:4
	%     pd_offset_angle(x) = atan(offset_distance(x)/arm_length)
	% end

	% pd_solid_angle = active_area/arm_length^2


	% pd1_dist_from_center = sqrt((pd1_center_x - baffle_center_x)^2 + (pd1_center_y - baffle_center_y)^2) %mm
	% pd2_dist_from_center = sqrt((pd2_center_x - baffle_center_x)^2 + (pd2_center_y - baffle_center_y)^2) %mm
	% pd3_dist_from_center = sqrt((pd3_center_x - baffle_center_x)^2 + (pd3_center_y - baffle_center_y)^2) %mm
	% pd4_dist_from_center = sqrt((pd4_center_x - baffle_center_x)^2 + (pd4_center_y - baffle_center_y)^2) %mm

	% pd1_angle = atan(pd1_dist_from_center/arm_length)
	% pd2_angle = atan(pd2_dist_from_center/arm_length)
	% pd3_angle = atan(pd3_dist_from_center/arm_length)
	% pd4_angle = atan(pd4_dist_from_center/arm_length)-


	pd_offset_angle = [.050101445632955; .110841831715934; .108876021849542; .051575106893689]*1e-3;
	pd_solid_angle = 6.25e-12;



	%Uncertainity +/- 0.002 volts
	%pd_offset = [-0.01;-0.01;-0.01;-0.007];
	% pd_offset = [-0.01;-0.01;-0.01;-0.01];
	% pd1_offset = -0.01; %volts
	% pd2_offset = -0.01; %volts
	% pd3_offset = -0.01; %volts
	% pd4_offset = -0.007; %volts

	% pd_data = [0.038;-0.0026;-0.007;0.012];

	% pd1_data = 0.038; % mean voltage
	% pd2_data = -0.0026; % mean voltage
	% pd3_data = -0.007; % mean voltage
	% pd4_data = 0.012; % mean voltage

	pd_watts = pd_data .* calib; %watts
	dPs = sqrt(calib.^2.*dVs.^2 + (pd_data.*calib.^2).^2.*dCalib.^2);

	%cavity_power = 2500; %Watts May 26

	BRDF = (pd_watts ./ pd_solid_angle) ./ (cavity_power .* cos(pd_offset_angle));
	dBRDF = sqrt((1./pd_solid_angle./cavity_power./cos(pd_offset_angle)).^2.*dPs.^2 + (pd_watts./pd_solid_angle./cavity_power.^2./cos(pd_offset_angle)).^2.*dPi.^2);

end
