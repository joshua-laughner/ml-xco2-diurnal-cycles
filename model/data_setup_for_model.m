%% setup stuff for the model
%this script creates and saves data that doesn't need to be run everytime,
%but is more relevant than the data created outside of the
%detrended_process script

%% options
%make_daily_arrays takes the 1D TCCON XCO2 variable, and puts it into a 2D
%array where each column is one day of observations

%delta_temp uses 3D tccon files to find the temperature at 700mb, and then
%finds the difference in temperature at 700mb during the day, both as
%absolute value and regular

%make_prob_dists takes the Lat/Lon information from the crossing files,
%filters by tccon site and fits probability distributions to the crossing
%times -- used to subsampling TCCON data for self crossing and OCO-2/3
%crossing simulations


%data_setup_for_model(‘make_daily_arrays’,1,’delta_temp’,1,’make_prob_dists’,1)
%or
%data_setup_for_model()

function data_setup_for_model(varargin)
savepath = 'C:\Users\cmarchet\Documents\ML_Code\Processed_Data\';

A.make_daily_arrays = 0;
A.delta_temp = 0;
A.make_prob_dists = 0;

A = parse_pv_pairs(A,varargin);

%here we make our probability distributions for the two default cases
if A.make_prob_dists
Longitudes = [-90.273, -104.98, 168.684,-97.486,-16.4991,33.381,150.879]; %the coordinates of the TCCON sites in order of the names listed
Latitudes = [45.945,54.35,-45.038,36.604,28.309,35.141,-34.406];
site_names = ["Park Falls", "East Trout Lake", "Lauder", "Lamont", "Izana", "Nicosia","Wollongong"];
site_acr = ["PF","ETL","Lauder","Lamont","Iza","Nic","Wol"];

%this section is taking the OCO-2/3 crossings, filtering by TCCON site, and
%fitting a probability distribution to the time OCO-2 crosses and the time
%OCO-3 crosses 
for i = 1:length(site_names) %this fits probability distributions by site
[pd_OCO,pd_diff,~,~] = fit_prob_dist(Latitudes(i),Longitudes(i),'fig',0,'site_num',i,'min_diff',0);
PD_Struct.(site_acr{i}).OCO2 = pd_OCO;
PD_Struct.(site_acr{i}).diff = pd_diff;
end

save([savepath,'PD_Struct.mat'],'PD_Struct','-v7.3')

load Self_Lite_Struct.mat
av_lat = nanmean([[Lite_Struct.OCO3a_latitude];[Lite_Struct.OCO3b_latitude]],1);
av_lon = nanmean([[Lite_Struct.OCO3a_longitude];[Lite_Struct.OCO3b_longitude]],1);

concatenated = [av_lat > 45 ; av_lat < 55 ;av_lon < -55 ; av_lon > -125]; %where the majority of self crossings are
index = find(all(concatenated,1));
       
    
time_diff = [Lite_Struct.time_difference];
time_diff = time_diff(index)/(60*60);
first_time = [Lite_Struct.first_obs_wrt_SN];
first_time = first_time(index);

second_ind = find(first_time > -10);
first_time_f = first_time(second_ind);
time_diff_f = time_diff(second_ind);

pd_OCO2 = fitdist(first_time_f.','Kernel');
Self_Cross.first = pd_OCO2;
Self_Cross.space = time_diff_f;

save([savepath,'Self_PD_Struct.mat'],'Self_Cross','-v7.3')
end

if A.make_daily_arrays
addpath C:\Users\cmarchet\Documents\ML_Code\Data\ %change this to whatever your path with the TCCON data is on

Daily_Struct_ETL = make_daily_array('etl.nc');
Daily_Struct_Lamont = make_daily_array('lamont.nc');
Daily_Struct_Lauder = make_daily_array('lauder');
Daily_Struct_PF = make_daily_array('park_falls.nc');
Daily_Struct_Iza = make_daily_array('izana.nc');
Daily_Struct_Nic = make_daily_array('nicosia.nc');

save([savepath,'Daily_Struct_ETL.mat'],'Daily_Struct_ETL','-v7.3')
save([savepath,'Daily_Struct_Lamont.mat'],'Daily_Struct_Lamont','-v7.3')
save([savepath,'Daily_Struct_Lauder.mat'],'Daily_Struct_Lauder','-v7.3')
save([savepath,'Daily_Struct_PF.mat'],'Daily_Struct_PF','-v7.3')
save([savepath,'Daily_Struct_Iza.mat'],'Daily_Struct_Iza','-v7.3')
save([savepath,'Daily_Struct_Nic.mat'],'Daily_Struct_Nic','-v7.3')

end

if A.delta_temp

[delta_reg_ETL,delta_abs_ETL] = add_delta_temp_eff('etl.nc', Daily_Struct_ETL.days);
[delta_reg_Lam,delta_abs_Lam] = add_delta_temp_eff('lamont.nc', Daily_Struct_Lamont.days);
[delta_reg_PF,delta_abs_PF] = add_delta_temp_eff('park_falls.nc', Daily_Struct_PF.days);
[delta_reg_Nic,delta_abs_Nic] = add_delta_temp_eff('nicosia.nc', Daily_Struct_Nic.days);
[delta_reg_Iza,delta_abs_Iza] = add_delta_temp_eff('izana.nc', Daily_Struct_Iza.days);
ind1 = find(isbetween(datetime(Daily_Struct_Lauder.days),datetime('2004-06-28'),datetime('2010-02-19')));
ind2 = find(isbetween(datetime(Daily_Struct_Lauder.days),datetime('2013-01-02'),datetime('2018-09-30')));
ind3 = find(isbetween(datetime(Daily_Struct_Lauder.days),datetime('2018-10-02'),datetime('2023-03-31')));
[reg_Lau1,abs_Lau1] = add_delta_temp_eff('lauder01.nc',Daily_Struct_Lauder.days(ind1));
[reg_Lau2,abs_Lau2] = add_delta_temp_eff('lauder02.nc',Daily_Struct_Lauder.days(ind2));
[reg_Lau3,abs_Lau3] = add_delta_temp_eff('lauder_03.nc',Daily_Struct_Lauder.days(ind3));
delta_abs_Lau = cat(2,abs_Lau1,abs_Lau2,abs_Lau3);
delta_reg_Lau = cat(2, reg_Lau1,reg_Lau2,reg_Lau3);


Delta_Temp_Struct.ETL.reg = delta_reg_ETL;
Delta_Temp_Struct.ETL.abs = delta_abs_ETL;
Delta_Temp_Struct.Lamont.reg = delta_reg_Lam;
Delta_Temp_Struct.Lamont.abs = delta_abs_Lam;
Delta_Temp_Struct.Lauder.reg = delta_reg_Lau;
Delta_Temp_Struct.Lauder.abs = delta_abs_Lau;
Delta_Temp_Struct.PF.reg = delta_reg_PF;
Delta_Temp_Struct.PF.abs = delta_abs_PF;
Delta_Temp_Struct.Nic.reg = delta_reg_Nic;
Delta_Temp_Struct.Nic.abs = delta_abs_Nic;
Delta_Temp_Struct.Iza.reg = delta_reg_Iza;
Delta_Temp_Struct.Iza.abs = delta_abs_Iza;

save([savepath,'Delta_Temp_Struct.mat'],'Delta_Temp_Struct','-v7.3')
end
end