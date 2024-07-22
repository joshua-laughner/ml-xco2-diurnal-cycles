%% Lauder comes in 3 parts from TCCON, but for my purposes I need each tccon file to be one file
savepath = '/home/cmarchet/Data/'; %change this to your savepath

xco2_lauder01 = ncread('lauder01.nc', 'xco2');
xco_lauder01 = ncread('lauder01.nc', 'xco');
solzen_lauder01 = ncread('lauder01.nc', 'solzen');
year_lauder01 = ncread('lauder01.nc', 'year');
day_lauder01 = ncread('lauder01.nc', 'day');
hour_lauder01 = ncread('lauder01.nc', 'hour');
time_lauder01 = ncread('lauder01.nc', 'time');
azim_lauder01 = ncread('lauder01.nc', 'azim');
calendar_time_lauder01 = datetime(1970,1,1) + seconds(time_lauder01);
calendar_time_lauder01.Format = 'yyyy-MM-dd';


temp_lauder01 = ncread('lauder01.nc', 'tout');
pressure_lauder01 = ncread('lauder01.nc', 'pout');
wind_speed_lauder01 = ncread('lauder01.nc', 'wspd');
prior_h2o_lauder01 = ncread('lauder01.nc','prior_xh2o');
prior_co2_lauder01 = ncread('lauder01.nc','prior_xco2');
xh2o_error_lauder01 = ncread('lauder01.nc','xh2o_error');
airmass_lauder01 = ncread('lauder01.nc','airmass');
altitude_lauder01 = ncread('lauder01.nc','zobs');
xh2o_lauder01 = ncread('lauder01.nc','xh2o');
xco2_error_lauder01 = ncread('lauder01.nc','xco2_error');
xco_error_lauder01 = ncread('lauder01.nc','xco_error');

xco2_lauder02 = ncread('lauder02.nc', 'xco2');
xco_lauder02 = ncread('lauder02.nc', 'xco');
solzen_lauder02 = ncread('lauder02.nc', 'solzen');
year_lauder02 = ncread('lauder02.nc', 'year');
day_lauder02 = ncread('lauder02.nc', 'day');
hour_lauder02 = ncread('lauder02.nc', 'hour');
time_lauder02 = ncread('lauder02.nc', 'time');
azim_lauder02 = ncread('lauder02.nc', 'azim');
calendar_time_lauder02 = datetime(1970,1,1) + seconds(time_lauder02);
calendar_time_lauder02.Format = 'yyyy-MM-dd';


temp_lauder02 = ncread('lauder02.nc', 'tout');
pressure_lauder02 = ncread('lauder02.nc', 'pout');
wind_speed_lauder02 = ncread('lauder02.nc', 'wspd');
prior_h2o_lauder02 = ncread('lauder02.nc','prior_xh2o');
prior_co2_lauder02 = ncread('lauder02.nc','prior_xco2');
xh2o_error_lauder02 = ncread('lauder02.nc','xh2o_error');
airmass_lauder02 = ncread('lauder02.nc','airmass');
altitude_lauder02 = ncread('lauder02.nc','zobs');
xh2o_lauder02 = ncread('lauder02.nc','xh2o');
xco2_error_lauder02 = ncread('lauder02.nc','xco2_error');
xco_error_lauder02 = ncread('lauder02.nc','xco_error');

xco2_lauder03 = ncread('lauder03.nc', 'xco2');
xco_lauder03 = ncread('lauder03.nc', 'xco');
solzen_lauder03 = ncread('lauder03.nc', 'solzen');
year_lauder03 = ncread('lauder03.nc', 'year');
day_lauder03 = ncread('lauder03.nc', 'day');
hour_lauder03 = ncread('lauder03.nc', 'hour');
time_lauder03 = ncread('lauder03.nc', 'time');
azim_lauder03 = ncread('lauder03.nc', 'azim');
calendar_time_lauder03 = datetime(1970,1,1) + seconds(time_lauder03);
calendar_time_lauder03.Format = 'yyyy-MM-dd';


temp_lauder03 = ncread('lauder03.nc', 'tout');
pressure_lauder03 = ncread('lauder03.nc', 'pout');
wind_speed_lauder03 = ncread('lauder03.nc', 'wspd');
prior_h2o_lauder03 = ncread('lauder03.nc','prior_xh2o');
prior_co2_lauder03 = ncread('lauder03.nc','prior_xco2');
xh2o_error_lauder03 = ncread('lauder03.nc','xh2o_error');
airmass_lauder03 = ncread('lauder03.nc','airmass');
altitude_lauder03 = ncread('lauder03.nc','zobs');
xh2o_lauder03 = ncread('lauder03.nc','xh2o');
xco2_error_lauder03 = ncread('lauder03.nc','xco2_error');
xco_error_lauder03 = ncread('lauder03.nc','xco_error');

Lauder.xco2 = cat(1, xco2_lauder01, xco2_lauder02, xco2_lauder03);
Lauder.xco = cat(1, xco_lauder01, xco_lauder02, xco_lauder03);
Lauder.solzen = cat(1, solzen_lauder01, solzen_lauder02, solzen_lauder03);
Lauder.year = cat(1, year_lauder01, year_lauder02, year_lauder03);
Lauder.day = cat(1, day_lauder01, day_lauder02, day_lauder03);
Lauder.hour = cat(1, hour_lauder01, hour_lauder02, hour_lauder03);
Lauder.time = cat(1, time_lauder01, time_lauder02, time_lauder03);
Lauder.azim = cat(1, azim_lauder01, azim_lauder02, azim_lauder03);
Lauder.calendar_time = cat(1, calendar_time_lauder01, calendar_time_lauder02, calendar_time_lauder03);
Lauder.temp = cat(1, temp_lauder01, temp_lauder02, temp_lauder03);
Lauder.pressure = cat(1, pressure_lauder01, pressure_lauder02, pressure_lauder03);
Lauder.wind_speed = cat(1, wind_speed_lauder01, wind_speed_lauder02, wind_speed_lauder03);
Lauder.prior_xh2o = cat(1,prior_h2o_lauder01,prior_h2o_lauder02,prior_h2o_lauder03);
Lauder.prior_xco2 = cat(1,prior_co2_lauder01,prior_co2_lauder02,prior_co2_lauder03);
Lauder.xh2o_error = cat(1,xh2o_error_lauder01,xh2o_error_lauder02,xh2o_error_lauder03);
Lauder.airmass = cat(1,airmass_lauder01,airmass_lauder02,airmass_lauder03);
Lauder.altitude = cat(1,altitude_lauder01,altitude_lauder02,altitude_lauder03);
Lauder.xh2o = cat(1,xh2o_lauder01,xh2o_lauder02,xh2o_lauder03);
Lauder.xco2_error = cat(1,xco2_error_lauder01,xco2_error_lauder02,xco2_error_lauder03);
Lauder.xco_error = cat(1,xco_error_lauder01,xco_error_lauder02,xco_error_lauder03);

save([savepath,'Lauder.mat'],'Lauder','-v7.3')