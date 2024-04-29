%% possibly faster lite file script
clear all
load /home/cmarchet/Data/Crossing_Struct.mat
  
oco2_lite_file = '';

parfor i = 1:length(Crossing_Struct)
    i
 

    oco2_sounding_id = ncread(Crossing_Struct(i).oco2_lite_file,'sounding_id');
    oco2_time = ncread(Crossing_Struct(i).oco2_lite_file,'time');
    oco2_latitude = ncread(Crossing_Struct(i).oco2_lite_file,'latitude');
    oco2_longitude = ncread(Crossing_Struct(i).oco2_lite_file,'longitude');
    oco2_uncertainty = ncread(Crossing_Struct(i).oco2_lite_file,'xco2_uncertainty');
    
    
    %only reading in the oco3 file that I want
    oco3_lite_files = {'oco3_lite_file_1','oco3_lite_file_2','oco3_lite_file_3'};
    oco3_grab_file_ind = Crossing_Struct(i).oco3_file_index_start+1;
   
    oco3_sounding_id = ncread(Crossing_Struct(i).(oco3_lite_files{oco3_grab_file_ind}),'sounding_id');
    oco3_time = ncread(Crossing_Struct(i).(oco3_lite_files{oco3_grab_file_ind}),'time');
    oco3_latitude = ncread(Crossing_Struct(i).(oco3_lite_files{oco3_grab_file_ind}),'latitude');
    oco3_longitude = ncread(Crossing_Struct(i).(oco3_lite_files{oco3_grab_file_ind}),'longitude');
    oco3_uncertainty = ncread(Crossing_Struct(i).(oco3_lite_files{oco3_grab_file_ind}),'xco2_uncertainty');

    if Crossing_Struct(i).oco3_file_index_start ~= Crossing_Struct(i).oco3_file_index_end
    oco3_sounding_id = cat(1,oco3_sounding_id,ncread(Crossing_Struct(i).(oco3_lite_files{oco3_grab_file_ind+1}),'sounding_id') );
    oco3_time = cat(1,oco3_time,ncread(Crossing_Struct(i).(oco3_lite_files{oco3_grab_file_ind+1}),'time'));
    oco3_latitude = cat(1,oco3_latitude,ncread(Crossing_Struct(i).(oco3_lite_files{oco3_grab_file_ind+1}),'latitude'));
    oco3_longitude = cat(1,oco3_longitude,ncread(Crossing_Struct(i).(oco3_lite_files{oco3_grab_file_ind+1}),'longitude'));
    oco3_uncertainty = cat(1,oco3_uncertainty,ncread(Crossing_Struct(i).(oco3_lite_files{oco3_grab_file_ind+1}),'xco2_uncertainty'));
   
    end


    start_index = find(oco2_sounding_id == Crossing_Struct(i).oco2_sounding_id_start);
    end_index = find(oco2_sounding_id == Crossing_Struct(i).oco2_sounding_id_end);

    Lite_Struct(i).OCO2_time = nanmean(oco2_time(start_index:end_index));
    Lite_Struct(i).OCO2_latitude = nanmean(oco2_latitude(start_index:end_index));
    Lite_Struct(i).OCO2_longitude = nanmean(oco2_longitude(start_index:end_index));
    Lite_Struct(i).OCO2_uncertainty = nanmean(oco2_uncertainty(start_index:end_index));
      
   start_index = find(oco3_sounding_id == Crossing_Struct(i).oco3_sounding_id_start);
   end_index = find(oco3_sounding_id == Crossing_Struct(i).oco3_sounding_id_end);
   
   Lite_Struct(i).OCO3_time = nanmean(oco3_time(start_index:end_index));
   Lite_Struct(i).OCO3_latitude = nanmean(oco3_latitude(start_index:end_index));
   Lite_Struct(i).OCO3_longitude = nanmean(oco3_longitude(start_index:end_index));
   Lite_Struct(i).OCO3_uncertainty = nanmean(oco3_uncertainty(start_index:end_index));
    

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

%save('C:\Users\cmarchet\Documents\ML_Code\Processed_Data\date_string.mat','date_string')

av_lat = mean(cat(1,[Lite_Struct.OCO2_latitude],[Lite_Struct.OCO3_latitude]),1);
av_lon = mean(cat(1,[Lite_Struct.OCO2_longitude],[Lite_Struct.OCO3_longitude]),1);
for i = 1:length(av_lon)
[~,noon] = sunRiseSet(av_lat(i),av_lon(i),0,date_string{i},0);
solar_noon_array(i) = noon;

end
% okay now that I have my values of solar noon (with respect to UTC) i can do some subtraction to see when OCO2 observes a location
% first I need to convert the OCO2 time to the hour of that day, rather
% than the total seconds since Jan 1 1970
for i = 1:15722
    array_dt(i) = datetime(date_string{i});

end
X = convertTo(array_dt,'epochtime','Epoch','1970-01-01');

OCO_seconds_of_day = [Lite_Struct.OCO2_time]-double(X);
OCO_time_wrt_SN = (OCO_seconds_of_day - solar_noon_array)/(60*60); %i'm actually starting on such a terrible foot by not saving anything
OCO_time_wrt_SN(OCO_time_wrt_SN< -24) = OCO_time_wrt_SN(OCO_time_wrt_SN< -24) + 24;
OCO_time_wrt_SN(OCO_time_wrt_SN> 24) = OCO_time_wrt_SN(OCO_time_wrt_SN> 24) -24;
Lite_Struct.OCO_time_wrt_SN = OCO_time_wrt_SN;
time_difference = ([Lite_Struct.OCO3_time] - [Lite_Struct.OCO2_time])/(60*60);
Lite_Struct.time_difference = time_difference;
