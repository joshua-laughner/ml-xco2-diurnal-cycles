%% possibly faster lite file script
clear all
load /home/cmarchet/Data/Self_Crossing_Struct.mat 
%change this path in vim :p

  
oco2_lite_file = '';

parfor i = 1:length(Crossing_Struct)
    i
 

    oco3a_sounding_id = ncread(Crossing_Struct(i).oco3a_lite_file,'sounding_id');
    oco3a_time = ncread(Crossing_Struct(i).oco3a_lite_file,'time');
    oco3a_latitude = ncread(Crossing_Struct(i).oco3a_lite_file,'latitude');
    oco3a_longitude = ncread(Crossing_Struct(i).oco3a_lite_file,'longitude');
    
    %only reading in the oco3 file that I want
    oco3b_lite_files = {'oco3b_lite_file_1','oco3b_lite_file_2','oco3b_lite_file_3'};
    oco3b_grab_file_ind = Crossing_Struct(i).oco3b_file_index_start+1;

    oco3b_sounding_id = ncread(Crossing_Struct(i).(oco3b_lite_files{oco3b_grab_file_ind}),'sounding_id');
    oco3b_time = ncread(Crossing_Struct(i).(oco3b_lite_files{oco3b_grab_file_ind}),'time');
    oco3b_latitude = ncread(Crossing_Struct(i).(oco3b_lite_files{oco3b_grab_file_ind}),'latitude');
    oco3b_longitude = ncread(Crossing_Struct(i).(oco3b_lite_files{oco3b_grab_file_ind}),'longitude');
  
    if Crossing_Struct(i).oco3b_file_index_start ~= Crossing_Struct(i).oco3b_file_index_end
    oco3b_sounding_id = cat(1,oco3b_sounding_id,ncread(Crossing_Struct(i).(oco3b_lite_files{oco3b_grab_file_ind+1}),'sounding_id') );
    oco3b_time = cat(1,oco3b_time,ncread(Crossing_Struct(i).(oco3b_lite_files{oco3b_grab_file_ind+1}),'time'));
    oco3b_latitude = cat(1,oco3b_latitude,ncread(Crossing_Struct(i).(oco3b_lite_files{oco3b_grab_file_ind+1}),'latitude'));
    oco3b_longitude = cat(1,oco3b_longitude,ncread(Crossing_Struct(i).(oco3b_lite_files{oco3b_grab_file_ind+1}),'longitude'));
    end


    start_index = find(oco3a_sounding_id == Crossing_Struct(i).oco3a_sounding_id_start);
    end_index = find(oco3a_sounding_id == Crossing_Struct(i).oco3a_sounding_id_end);

    Lite_Struct(i).OCO3a_time = nanmean(oco3a_time(start_index:end_index));
    Lite_Struct(i).OCO3a_latitude = nanmean(oco3a_latitude(start_index:end_index));
    Lite_Struct(i).OCO3a_longitude = nanmean(oco3a_longitude(start_index:end_index));
      
   start_index = find(oco3b_sounding_id == Crossing_Struct(i).oco3b_sounding_id_start);
   end_index = find(oco3b_sounding_id == Crossing_Struct(i).oco3b_sounding_id_end);

   Lite_Struct(i).OCO3b_time = nanmean(oco3b_time(start_index:end_index));
   Lite_Struct(i).OCO3b_latitude = nanmean(oco3b_latitude(start_index:end_index));
   Lite_Struct(i).OCO3b_longitude = nanmean(oco3b_longitude(start_index:end_index));
    

end

date_array = nan(length(Crossing_Struct),3);
month_names = ["jan";"feb";"mar";"apr";"may";"jun";"jul";"aug";"sep";"oct";"nov";"dec"];

for i = 1:length(Crossing_Struct)
sounding_id = Crossing_Struct(i).oco3_sounding_id_start; %like, close enough right
stringform = num2str(sounding_id);
date_array(i,1) = str2num(stringform(1:4));
date_array(i,2) = str2num(stringform(5:6));
date_array(i,3) = str2num(stringform(7:8));
month_array_separate(i) = month_names(date_array(i,2)); %so annoying but w/e

date_string{i} = strcat(num2str(date_array(i,3)),'-',month_array_separate(i),'-',num2str(date_array(i,1)));
end
av_lat = mean(cat(1,[Lite_Struct.OCO3a_latitude],[Lite_Struct.OCO3b_latitude]),1);
av_lon = mean(cat(1,[Lite_Struct.OCO3a_longitude],[Lite_Struct.OCO3b_longitude]),1);
for i = 1:length(av_lon)
[~,noon] = sunRiseSet(av_lat(i),av_lon(i),0,date_string{i},0);
solar_noon_array(i) = noon;

end

for i = 1:length(date_string)
    array_dt(i) = datetime(date_string{i});

end
X = convertTo(array_dt,'epochtime','Epoch','1970-01-01');
OCO_seconds_of_day = min([Lite_Struct.OCO3a_time],[Lite_Struct.OCO3b_time])-double(X);
OCO_time_wrt_SN = (OCO_seconds_of_day - solar_noon_array)/(60*60); %i'm actually starting on such a terrible foot by not saving anything
OCO_time_wrt_SN(OCO_time_wrt_SN< -24) = OCO_time_wrt_SN(OCO_time_wrt_SN< -24) + 24;
OCO_time_wrt_SN(OCO_time_wrt_SN> 24) = OCO_time_wrt_SN(OCO_time_wrt_SN> 24) -24;


for i = 1:size(Lite_Struct,2)
Lite_Struct(i).time_difference = abs(Lite_Struct(i).OCO3b_time - Lite_Struct(i).OCO3a_time);
Lite_Struct(i).first_obs_wrt_SN = OCO_time_wrt_SN(i);
end

save('C:\Users\cmarchet\Documents\ML_Code\Processed_Data\Self_Lite_Struct.mat','Lite_Struct')