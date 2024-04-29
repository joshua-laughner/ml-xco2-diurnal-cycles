%% possibly faster lite file script
clear all
load Crossing_Struct.mat
Big_Crossing_Struct = Crossing_Struct;
oco2_lite_file = '';


start_inds = [1,1573,3145,4718,6290,7862,9434,11006,12579,14151,15723];
for j = 1:10
    j
   
    f = {'oco2_latitude','oco2_longitude','oco2_xco2','oco2_xco2_uncertainty','oco2_xco2_quality_flag','oco2_xco2_apriori',...
        'oco2_time','oco2_windspeed','oco2_airmass','oco2_pressure','oco2_temp','oco2_solar_azimuth','oco2_num_soundings',...
        'oco3_latitude','oco3_longitude','oco3_xco2','oco3_xco2_uncertainty','oco3_xco2_quality_flag','oco3_xco2_apriori',...
        'oco3_time','oco3_windspeed','oco3_airmass','oco3_pressure','oco3_temp','oco3_solar_azimuth','oco3_num_soundings'};
    f{2,1} = {};
    Big_Lite_Struct = struct(f{:});
    lengt = start_inds(j+1) - start_inds(j);
    Big_Lite_Struct(lengt).oco2_latitude = nan;
    Crossing_Struct = Big_Crossing_Struct(start_inds(j):start_inds(j+1)-1);
parfor i = 1:length(Crossing_Struct)
    i
 
    oco2_filename = Crossing_Struct(i).oco2_lite_file;
    %OCO2 first because its easier :P 
    oco2_sounding_id = ncread(oco2_filename,'sounding_id');
    start_index = find(oco2_sounding_id == Crossing_Struct(i).oco2_sounding_id_start);
    end_index = find(oco2_sounding_id == Crossing_Struct(i).oco2_sounding_id_end);
    num_files_2 = end_index - start_index+1; %because of how indexing works here
    
    Scs = struct('sounding_id', [start_index num_files_2 1]);
  
    C = ncstruct(oco2_filename,'latitude','longitude','xco2','xco2_uncertainty','xco2_quality_flag','xco2_apriori','time', Scs);
    windspeed = ncread(oco2_filename,'/Retrieval/windspeed',start_index,num_files_2);
    airmass = ncread(oco2_filename,'/Sounding/airmass',start_index,num_files_2);
    pressure = ncread(oco2_filename,'/Retrieval/psurf',start_index,num_files_2);
    t700 =  ncread(oco2_filename,'/Retrieval/t700',start_index,num_files_2);
    solar_azimuth = ncread(oco2_filename,'/Sounding/solar_azimuth_angle',start_index,num_files_2);
  %  land_water = ncread(oco2_filename,'/Sounding/land_water_indicator',start_index,num_files_2);

    oco2_goodind = find(C.xco2_quality_flag == 0); %land_water == 0 &

    fieldies = fieldnames(C);
    for f = 1:length(fieldies)
        Big_Lite_Struct(i).(['oco2_',fieldies{f}]) = nanmean(C.(fieldies{f})(oco2_goodind));
    end
   
    Big_Lite_Struct(i).oco2_windpseed = nanmean(windspeed(oco2_goodind));
    Big_Lite_Struct(i).oco2_airmass = nanmean(airmass(oco2_goodind));
    Big_Lite_Struct(i).oco2_pressure = nanmean(pressure(oco2_goodind));
    Big_Lite_Struct(i).oco2_temp = nanmean(t700(oco2_goodind));
    Big_Lite_Struct(i).oco2_solar_azimuth = nanmean(solar_azimuth(oco2_goodind));
    Big_Lite_Struct(i).oco2_num_soundings = length(oco2_goodind);
  
    % OCO3 time 
   
    oco3_lite_files = {'oco3_lite_file_1','oco3_lite_file_2','oco3_lite_file_3'};
    oco3_grab_file_ind = Crossing_Struct(i).oco3_file_index_start+1;
    oco3_filename = Crossing_Struct(i).(oco3_lite_files{oco3_grab_file_ind});
    
    if Crossing_Struct(i).oco3_file_index_start == Crossing_Struct(i).oco3_file_index_end
        oco3_sounding_id = ncread(oco3_filename,'sounding_id');
        start_index = find(oco3_sounding_id == Crossing_Struct(i).oco3_sounding_id_start);
        end_index = find(oco3_sounding_id == Crossing_Struct(i).oco3_sounding_id_end);
        num_files_3 = end_index - start_index+1; %because of how indexing works here
   
        Scs = struct('sounding_id', [start_index num_files_3 1]);
  
        C = ncstruct(oco3_filename,'latitude','longitude','xco2','xco2_uncertainty','xco2_quality_flag','xco2_apriori','time', Scs);
        windspeed = ncread(oco3_filename,'/Retrieval/windspeed',start_index,num_files_3);
        airmass = ncread(oco3_filename,'/Sounding/airmass',start_index,num_files_3);
        pressure = ncread(oco3_filename,'/Retrieval/psurf',start_index,num_files_3);
        t700 =  ncread(oco3_filename,'/Retrieval/t700',start_index,num_files_3);
        solar_azimuth = ncread(oco3_filename,'/Sounding/solar_azimuth_angle',start_index,num_files_3);
        land_water = ncread(oco3_filename,'/Sounding/land_water_indicator',start_index,num_files_3);
        
        oco3_goodind = find(C.xco2_quality_flag == 0); %land_water == 0 &

        fieldies = fieldnames(C);
        for f = 1:length(fieldies)
            Big_Lite_Struct(i).(['oco3_',fieldies{f}]) = nanmean(C.(fieldies{f})(oco3_goodind));
        end
   
        Big_Lite_Struct(i).oco3_windspeed = nanmean(windspeed(oco3_goodind));
        Big_Lite_Struct(i).oco3_airmass = nanmean(airmass(oco3_goodind));
        Big_Lite_Struct(i).oco3_pressure = nanmean(pressure(oco3_goodind));
        Big_Lite_Struct(i).oco3_temp = nanmean(t700(oco3_goodind));
        Big_Lite_Struct(i).oco3_solar_azimuth = nanmean(solar_azimuth(oco3_goodind));
        Big_Lite_Struct(i).oco3_num_soundings = length(oco3_goodind);
    else
        oco3_lite_files = {'oco3_lite_file_1','oco3_lite_file_2','oco3_lite_file_3'};
        oco3_grab_file_ind = Crossing_Struct(i).oco3_file_index_start+1;
   
        oco3_sounding_id = ncread(Crossing_Struct(i).(oco3_lite_files{oco3_grab_file_ind}),'sounding_id');
        oco3_time = ncread(Crossing_Struct(i).(oco3_lite_files{oco3_grab_file_ind}),'time');
        oco3_latitude = ncread(Crossing_Struct(i).(oco3_lite_files{oco3_grab_file_ind}),'latitude');
        oco3_longitude = ncread(Crossing_Struct(i).(oco3_lite_files{oco3_grab_file_ind}),'longitude');
        oco3_uncertainty = ncread(Crossing_Struct(i).(oco3_lite_files{oco3_grab_file_ind}),'xco2_uncertainty');
        oco3_xco2 = ncread(Crossing_Struct(i).(oco3_lite_files{oco3_grab_file_ind}),'xco2');
        oco3_xco2_apriori = ncread(Crossing_Struct(i).(oco3_lite_files{oco3_grab_file_ind}),'xco2_apriori');
        windspeed = ncread(Crossing_Struct(i).(oco3_lite_files{oco3_grab_file_ind}),'/Retrieval/windspeed');
        airmass = ncread(Crossing_Struct(i).(oco3_lite_files{oco3_grab_file_ind}),'/Sounding/airmass');
        pressure = ncread(Crossing_Struct(i).(oco3_lite_files{oco3_grab_file_ind}),'/Retrieval/psurf');
        t700 =  ncread(Crossing_Struct(i).(oco3_lite_files{oco3_grab_file_ind}),'/Retrieval/t700');
        solar_azimuth = ncread(Crossing_Struct(i).(oco3_lite_files{oco3_grab_file_ind}),'/Sounding/solar_azimuth_angle');
     %   land_water = ncread(Crossing_Struct(i).(oco3_lite_files{oco3_grab_file_ind}),'/Sounding/land_water_indicator');
        xco2_quality_flag = ncread(Crossing_Struct(i).(oco3_lite_files{oco3_grab_file_ind}),'xco2_quality_flag');

        oco3_sounding_id = cat(1,oco3_sounding_id,ncread(Crossing_Struct(i).(oco3_lite_files{oco3_grab_file_ind+1}),'sounding_id') );
        oco3_time = cat(1,oco3_time,ncread(Crossing_Struct(i).(oco3_lite_files{oco3_grab_file_ind+1}),'time'));
        oco3_latitude = cat(1,oco3_latitude,ncread(Crossing_Struct(i).(oco3_lite_files{oco3_grab_file_ind+1}),'latitude'));
        oco3_longitude = cat(1,oco3_longitude,ncread(Crossing_Struct(i).(oco3_lite_files{oco3_grab_file_ind+1}),'longitude'));
        oco3_uncertainty = cat(1,oco3_uncertainty,ncread(Crossing_Struct(i).(oco3_lite_files{oco3_grab_file_ind+1}),'xco2_uncertainty'));
        oco3_xco2 = cat(1,oco3_xco2,ncread(Crossing_Struct(i).(oco3_lite_files{oco3_grab_file_ind+1}),'xco2'));
        oco3_xco2_apriori = cat(1,oco3_xco2_apriori,ncread(Crossing_Struct(i).(oco3_lite_files{oco3_grab_file_ind+1}),'xco2_apriori'));
        windspeed = cat(1,windspeed,ncread(Crossing_Struct(i).(oco3_lite_files{oco3_grab_file_ind+1}),'/Retrieval/windspeed'));
        airmass = cat(1,airmass,ncread(Crossing_Struct(i).(oco3_lite_files{oco3_grab_file_ind+1}),'/Sounding/airmass'));
        pressure = cat(1,pressure,ncread(Crossing_Struct(i).(oco3_lite_files{oco3_grab_file_ind+1}),'/Retrieval/psurf'));
        t700 = cat(1,t700,ncread(Crossing_Struct(i).(oco3_lite_files{oco3_grab_file_ind+1}),'/Retrieval/t700'));
        solar_azimuth = cat(1,solar_azimuth,ncread(Crossing_Struct(i).(oco3_lite_files{oco3_grab_file_ind+1}),'/Sounding/solar_azimuth_angle'));
      %  land_water = cat(1,land_water,ncread(Crossing_Struct(i).(oco3_lite_files{oco3_grab_file_ind+1}),'/Sounding/land_water_indicator'));
        xco2_quality_flag = cat(1,xco2_quality_flag,ncread(Crossing_Struct(i).(oco3_lite_files{oco3_grab_file_ind+1}),'xco2_quality_flag'));
       
        oco3_goodind = find(xco2_quality_flag == 0); %land_water == 0 
        
        Big_Lite_Struct(i).oco3_time = nanmean(oco3_time(oco3_goodind));
        Big_Lite_Struct(i).oco3_latitude = nanmean(oco3_latitude(oco3_goodind));
        Big_Lite_Struct(i).oco3_longitude = nanmean(oco3_longitude(oco3_goodind));
        Big_Lite_Struct(i).oco3_xco2_uncertainty = nanmean(oco3_uncertainty(oco3_goodind));
        Big_Lite_Struct(i).oco3_xco2 = nanmean(oco3_xco2(oco3_goodind));
        Big_Lite_Struct(i).oco3_xco2_apriori = nanmean(oco3_xco2_apriori(oco3_goodind));
        Big_Lite_Struct(i).oco3_windspeed = nanmean(windspeed(oco3_goodind));
        Big_Lite_Struct(i).oco3_airmass = nanmean(airmass(oco3_goodind));
        Big_Lite_Struct(i).oco3_pressure = nanmean(pressure(oco3_goodind));
        Big_Lite_Struct(i).oco3_temp = nanmean(t700(oco3_goodind));
        Big_Lite_Struct(i).oco3_solar_azimuth = nanmean(solar_azimuth(oco3_goodind));
        Big_Lite_Struct(i).oco3_num_soundings = length(oco3_goodind);



    end
   
end
save(['Big_Lite_Struct_',num2str(j),'.mat'],'Big_Lite_Struct')
end