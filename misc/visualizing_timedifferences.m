%% Crossing Data distributions
%i want to see distributions across latitude and longitude, and then focus
%on the locations around TCCON sites and see what the crossing patterns are

time_difference = [Lite_Struct.OCO2_time] - [Lite_Struct.OCO3_time];

%% difference versus longitude and latitude
figure()
c = [Lite_Struct.OCO2_longitude];
scatter([Lite_Struct.OCO2_latitude],time_difference,2,c,'filled')
h = colorbar;
xlabel('latitude')
ylabel('time difference between observations')
h.Label.String = 'longitude';

figure()
c = [Lite_Struct.OCO2_latitude];
scatter([Lite_Struct.OCO2_longitude],time_difference,2,c,'filled')
h = colorbar;
xlabel('longitude')
ylabel('time difference between observations')
h.Label.String = 'latitude';


%% look at data by TCCON sites
% Park Falls: Lon = 90.273 W, Lat = 45.945 N
site_names = ["Park Falls", "East Trout Lake", "Lauder", "Lamont", "Izana", "Nicosia","Wollongong"];
site_acr = ["PF","ETL","Lau","Lam","Iza","Nic","Wol"];

Longitudes = [-90.273, -104.98, 168.684,-97.486,-16.4991,33.381,150.879];
Latitudes = [45.945,54.35,45.038,36.604,28.309,35.141,34.406];
for i = 1:length(site_names) %for loops, chefs kiss
wgs84 = wgs84Ellipsoid("km");
Lon = Longitudes(i); Lat = Latitudes(i);

OCO2_distance = distance(Lat,Lon,[Lite_Struct.OCO2_latitude],[Lite_Struct.OCO2_longitude],wgs84);
OCO3_distance = distance(Lat,Lon,[Lite_Struct.OCO3_latitude],[Lite_Struct.OCO3_longitude],wgs84);

within_range = find(OCO2_distance<=1000 & OCO3_distance<=1000); %within ~10 degrees of the site

time_diff = time_difference(within_range)/(60*60);
OCO2_time = OCO_time_wrt_SN(within_range);
OCO2_time(OCO2_time < -20) = OCO2_time(OCO2_time <-20) + 24;

figure(2*i-1)
h = histfit(time_diff,[],'kernel');
h(1).FaceColor = [166 189 219]/255;
h(2).Color = [.2 .2 .2];
xlabel('time difference between observations')
ylabel('number of observations')
title([site_names(i),' OCO2/3 time difference Histogram'])
file_name = strcat(site_acr(i),'_OCO23_diff_hist');
print('-dtiff',strcat('C:\Users\cmarchet\Box\JPL\slides and figures\',file_name))

figure(2*i)
h = histfit(OCO2_time,[],'burr');
h(1).FaceColor = [254 227 145]/255;
h(2).Color = [.2 .2 .2];
xlabel('Hours Since Solar Noon')
ylabel('number of observations')
title([site_names(i), ' OCO2 Observation Time Histogram'])
file_name = strcat(site_acr(i),'_OCO2_time');
print('-dtiff',strcat('C:\Users\cmarchet\Box\JPL\slides and figures\',file_name))
end

