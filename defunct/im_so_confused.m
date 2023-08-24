location_struct = Daily_Struct_ETL;
min_points_criteria = 3;
PD_struct = PD_Struct.ETL;
%Daynames_Struct = Daynames_Struct.ETL;

rows = length(location_struct.xco2(1,:));
    columns = 2;
    
    fields = fieldnames(location_struct);
   fields(5:6) = [];
  %  fields(5) = [];

    

    %initializing
    for i = 1:length(fields)
        subsampled_struct.(fields{i}) = nan(rows,columns);
    end
    subsampled_struct.daynames = string();

   for day = 1:length(location_struct.xco2(1,:))
     %  day
        solmin = location_struct.solar_min(day);
        OCO2_index = [];
        OCO3_index = [];
        count = 0;
        while (length(OCO2_index)<min_points_criteria || length(OCO3_index)<min_points_criteria)
            count = count+1;
            % now, this is sketchy, because I keep redrawing until I get
            % points in that day
            [time, difference] = sample_from_pd(PD_struct.OCO2,PD_struct.diff);
            OCO2_time = solmin + time;
            OCO3_time = OCO2_time + difference;

            OCO2_index = find(abs(location_struct.hours(:,day) - OCO2_time) < 0.25);
            OCO3_index = find(abs(location_struct.hours(:,day) - OCO3_time)< 0.25);
            quit = 0;
            if count == 5 %don't want to be drawing forever
                quit = 1;
                continue
            end
        end
        if quit == 1
            continue
        end
        subsampled_struct.hours(day,1) = OCO2_time;
        subsampled_struct.hours(day,2) = OCO3_time;
        subsampled_struct.delta_solmin(day) = time;

        subsampled_struct.daynames(1,day) = Daynames_Struct(day);
          
        for field = 1:length(fields)
            field
            if field == 2
                continue
            end
            subsampled_struct.(fields{field})(day,1) = nanmean(location_struct.(fields{field})(OCO2_index,day));
            subsampled_struct.(fields{field})(day,2) = nanmean(location_struct.(fields{field})(OCO3_index,day));


        end
 
   end
   %%
   subsampled_struct.delta_xco2(:) = subsampled_struct.xco2(:,2) - subsampled_struct.xco2(:,1);
   subsampled_struct.delta_temp(:) = subsampled_struct.temp(:,2) - subsampled_struct.temp(:,1);
   subsampled_struct.delta_solzen(:) = subsampled_struct.solzen(:,2) - subsampled_struct.solzen(:,1);
   subsampled_struct.delta_hour(:) = subsampled_struct.hours(:,2) - subsampled_struct.hours(:,1);
   subsampled_struct.delta_azim(:) = subsampled_struct.azim(:,2) - subsampled_struct.azim(:,1);
   subsampled_struct.delta_pressure(:) = subsampled_struct.pressure(:,2) - subsampled_struct.pressure(:,1);
   subsampled_struct.delta_wind_wpeed(:) = subsampled_struct.wind_speed(:,2)- subsampled_struct.wind_speed(:,1);
   subsampled_struct.delta_airmass(:) = subsampled_struct.airmass(:,2) - subsampled_struct.airmass(:,1);
   subsampled_struct.delta_xh2o(:) = subsampled_struct.xh2o(:,2) - subsampled_struct.xh2o(:,1);
   subsampled_struct.prior_diff(:,1) = subsampled_struct.xco2(:,1) - subsampled_struct.prior_xco2(:,1); %i don't really know what priors mean
   subsampled_struct.prior_diff(:,2) = subsampled_struct.xco2(:,2) - subsampled_struct.prior_xco2(:,2);
   