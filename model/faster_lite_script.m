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
    
    %only reading in the oco3 file that I want
    oco3_lite_files = {'oco3_lite_file_1','oco3_lite_file_2','oco3_lite_file_3'};
    oco3_grab_file_ind = Crossing_Struct(i).oco3_file_index_start+1;
    oco3_sounding_id = ncread(Crossing_Struct(i).(oco3_lite_files{oco3_grab_file_ind}),'sounding_id');
    oco3_time = ncread(Crossing_Struct(i).(oco3_lite_files{oco3_grab_file_ind}),'time');
    oco3_latitude = ncread(Crossing_Struct(i).(oco3_lite_files{oco3_grab_file_ind}),'latitude');
    oco3_longitude = ncread(Crossing_Struct(i).(oco3_lite_files{oco3_grab_file_ind}),'longitude');
  
    if Crossing_Struct(i).oco3_file_index_start ~= Crossing_Struct(i).oco3_file_index_end
    oco3_sounding_id = cat(1,oco3_sounding_id,ncread(Crossing_Struct(i).(oco3_lite_files{oco3_grab_file_ind+1}),'sounding_id') );
    oco3_time = cat(1,oco3_time,ncread(Crossing_Struct(i).(oco3_lite_files{oco3_grab_file_ind+1}),'time'));
    oco3_latitude = cat(1,oco3_latitude,ncread(Crossing_Struct(i).(oco3_lite_files{oco3_grab_file_ind+1}),'latitude'));
    oco3_longitude = cat(1,oco3_longitude,ncread(Crossing_Struct(i).(oco3_lite_files{oco3_grab_file_ind+1}),'longitude'));
    end


    start_index = find(oco2_sounding_id == Crossing_Struct(i).oco2_sounding_id_start);
    end_index = find(oco2_sounding_id == Crossing_Struct(i).oco2_sounding_id_end);

    Lite_Struct(i).OCO2_time = nanmean(oco2_time(start_index:end_index));
    Lite_Struct(i).OCO2_latitude = nanmean(oco2_latitude(start_index:end_index));
    Lite_Struct(i).OCO2_longitude = nanmean(oco2_longitude(start_index:end_index));
      
   start_index = find(oco3_sounding_id == Crossing_Struct(i).oco3_sounding_id_start);
   end_index = find(oco3_sounding_id == Crossing_Struct(i).oco3_sounding_id_end);

   Lite_Struct(i).OCO3_time = nanmean(oco3_time(start_index:end_index));
   Lite_Struct(i).OCO3_latitude = nanmean(oco3_latitude(start_index:end_index));
   Lite_Struct(i).OCO3_longitude = nanmean(oco3_longitude(start_index:end_index));
    

end