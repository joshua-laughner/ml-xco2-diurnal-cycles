%% plotting my self crossing stuff
figure(1)
%array_to = [Lite_Struct.OCO3b_time] - [Lite_Struct.OCO3a_time];
array_to = [Lite_Struct.time_difference];
histogram(array_to/(60*60))
xlabel('time difference')
%title('OCO3a')

%% want to make a gridded map
Longitudes = -180:10:180;
Latitudes = -55:1:55;

mean_lons = [];
mean_lats = [];
scount = [];

for i = 1:length(Longitudes)-1

    for j = 1:length(Latitudes)-1
        concatenated = [[Lite_Struct.OCO3a_longitude]>=Longitudes(i); [Lite_Struct.OCO3a_longitude]< Longitudes(i+1); [Lite_Struct.OCO3a_latitude]>= Latitudes(j); [Lite_Struct.OCO3a_latitude]< Latitudes(j+1)];
        index = find(all(concatenated,1));
         if isempty(index)
             continue
         end

         londex = [Lite_Struct.OCO3a_longitude];
         latdex = [Lite_Struct.OCO3a_latitude];

         scount = cat(1,scount,length(index));
         mean_lons = cat(1,mean_lons,mean(londex(index)));
         mean_lats = cat(1,mean_lats,mean(latdex(index)));

    end

end
%%
figure(2)
geoscatter(mean_lats,mean_lons,35,scount,'filled','MarkerFaceAlpha',0.7)
geobasemap topographic
cmocean('dense')
colorbar()
title('OCO3 number of self crossings by location')
%%
av_lat = nanmean([[Lite_Struct.OCO3a_latitude];[Lite_Struct.OCO3b_latitude]],1);
av_lon = nanmean([[Lite_Struct.OCO3a_longitude];[Lite_Struct.OCO3b_longitude]],1);

concatenated = [av_lat > 45 ; av_lat < 55 ;av_lon < -55 ; av_lon > -125];
index = find(all(concatenated,1));
       
    
time_diff = [Lite_Struct.time_difference];
time_diff = time_diff(index)/(60*60);
first_time = [Lite_Struct.first_obs_wrt_SN];
first_time = first_time(index);

second_ind = find(first_time > -10);
first_time_f = first_time(second_ind);
time_diff_f = time_diff(second_ind);

figure(1)
clf
histfit(first_time_f)
xlabel('time of first obs wrt SN')
figure(2)
clf
histogram(time_diff_f)
xlabel('difference between obs')

%%
pd_OCO2 = fitdist(first_time.','Kernel');
random(pd_OCO2)
Self_Cross.first = pd_OCO2;
Self_Cross.space = time_diff_f;
