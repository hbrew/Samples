%Exposure was set to 1 usec, but minimum exposure is 4usec for cameras,
%which is what it sets to when too low values set

distance = 5.8; %meters
offset_to_side = 1; %meters approximate
lens_dia = 4.5/100; % meters
lens_radius = lens_dia/2.0; %meters
%lens_solid_angle = 2*pi*(1-cos(atan(lens_radius/distance)));
lens_solid_angle  = pi*lens_radius^2/distance^2;
lens_transmission = 0.4; %fractional

scatter_angle = atan(offset_to_side/distance); %approximate radians



mono12calib = 0.16; %microseconds nanowatts / mono12count
mono8calib = mono12calib * 16; %4096 mono12counts = 256 mono8counts
exposure = 4; %microseconds
%exposure = 10000;
calib = mono8calib / exposure; % nanowatts / mono8count
%calib = mono12calib / exposure; % nanowatts / mono8count


cavity_power = 2500*1e9; %nanoWatts

data = imread('etmy_fulllock_1us_ETMY_2014-05-28-22-37-58.tiff');
%data = imread('etmx_full_lock_ETMX_2014-05-26-23-37-58.tiff');


figure(1)
image(data)

data(find(data <= 3)) = 0;
figure(2)
image(data)

figure(3)
image(data(202:213,345:353))

count = sum(sum(data(202:213,345:353)))

nW_on_camera = count*calib %nanowatts on camera

nW_on_lens = nW_on_camera / lens_transmission %nanowatts at lens

BRDF = (nW_on_lens / lens_solid_angle)/ (cavity_power * cos(scatter_angle))

ppm = pi*BRDF*1e6


count = sum(sum(data))

nW_on_camera = count*calib %nanowatts on camera

nW_on_lens = nW_on_camera / lens_transmission %nanowatts at lens

BRDF = (nW_on_lens / lens_solid_angle)/ (cavity_power * cos(scatter_angle))

ppm = pi*BRDF*1e6


