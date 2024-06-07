function [pd_OCO2,pd_diff,time_diff,OCO2_time,OCO3_timee] = fit_prob_dist(Lat,Lon,varargin)
%addpath /home/cmarchet/Processed_Data
%these are made in the scripts making_litefile_struct.m and
%mean_lite_file.m

%load Lite_Struct.mat
%load time_difference.mat
%load OCO_time_wrt_SN.mat 
load Lite_Struct

time_difference = [Lite_Struct.time_difference];
OCO_time_wrt_SN = [Lite_Struct.OCO_time_wrt_SN];
OCO3_time = [Lite_Struct.OCO3_wrt_SN];

A.fig = 0;
A.site_num = 0;
A.min_diff = 0;
A = parse_pv_pairs(A,varargin);

wgs84 = wgs84Ellipsoid("km");

%finding the distance between OCO_2 and TCCON, and OCO-3 and tccon
OCO2_distance = distance(Lat,Lon,[Lite_Struct.OCO2_latitude],[Lite_Struct.OCO2_longitude],wgs84);
OCO3_distance = distance(Lat,Lon,[Lite_Struct.OCO3_latitude],[Lite_Struct.OCO3_longitude],wgs84);

%we are only interested when the crossing is occuring within 1000 km of the
%site
within_range = find(OCO2_distance<=1000 & OCO3_distance<=1000); %within ~10 degrees of the site

time_diff = time_difference(within_range);
OCO2_time = OCO_time_wrt_SN(within_range);
OCO2_time(OCO2_time < -20) = OCO2_time(OCO2_time <-20) + 24;

OCO3_timee = OCO3_time(within_range);
OCO3_timee(OCO3_timee < -20) = OCO3_timee(OCO3_timee < -20) + 24;

too_small_ind = find(abs(time_diff)<A.min_diff);
time_diff(too_small_ind) = [];
OCO2_time(too_small_ind) = [];
OCO3_timee(too_small_ind) = [];

bool_array = time_diff>A.min_diff;

pd_OCO2 = fitdist(OCO2_time.','burr');
pd_diff = fitdist(time_diff.','kernel');
%pd_diff = fitdist(time_diff.','Kernel','By',bool_array);


if A.fig == 1
site_names = ["Park Falls", "East Trout Lake", "Lauder", "Lamont", "Izana", "Nicosia","Wollongong"];
site_acr = ["PF","ETL","Lau","Lam","Iza","Nic","Wol"];

%if you want figures showing the probability distributions
figure(1)
clf
h = histfit(time_diff(bool_array==1),[],'kernel');
h(1).FaceColor = [166 189 219]/255;
h(2).Color = [.2 .2 .2];
hold on
h = histfit(time_diff(bool_array==0),[],'kernel');
h(1).FaceColor = [166 189 219]/255;
h(2).Color = [.2 .2 .2];
%h = histfit(time_diff,[],'kernel');
%h(1).FaceColor = [166 189 219]/255;
%h(2).Color = [.2 .2 .2];
xlabel('time difference between observations')
ylabel('number of observations')
title([site_names(A.site_num),' OCO2/3 time difference Histogram'])
file_name = strcat(site_acr(A.site_num),'_OCO23_diff_2_1');
%print('-dtiff',strcat('C:\Users\cmarchet\Box\JPL\slides and figures\',file_name))

figure(2)
clf
h = histfit(OCO2_time,[],'burr');
h(1).FaceColor = [254 227 145]/255;
h(2).Color = [.2 .2 .2];
xlabel('Hours Since Solar Noon')
ylabel('number of observations')
title([site_names(A.site_num), ' OCO2 Observation Time Histogram'])
file_name = strcat(site_acr(A.site_num),'_OCO2_time');
%print('-dtiff',strcat('C:\Users\cmarchet\Box\JPL\slides and figures\',file_name))
end
