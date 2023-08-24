function [subsampled_struct] = subsample_observations(location_struct, min_points_criteria, Daynames_Struct,PD_struct)
    rows = length(location_struct.xco2(1,:));
    columns = 2;
    
    fields = fieldnames(location_struct);
    fields(5:6) = []; %these fields are date, and solar min. We don't subsample from these


    %initializing
    for i = 1:length(fields) %initializing my subsampled script. I hate commenting code :( just let it be a mystery
        subsampled_struct.(fields{i}) = nan(rows,columns);
    end
    subsampled_struct.daynames = string();

   for day = 1:length(location_struct.xco2(1,:)) %going through each day in the structure
     %  day
        solmin = location_struct.solar_min(day);
        OCO2_index = [];
        OCO3_index = [];
        count = 0;
        while (length(OCO2_index)<min_points_criteria || length(OCO3_index)<min_points_criteria) %loop until either its good or we've looped 5 times
            count = count+1;
            % now, this is sketchy, because I keep redrawing until I get
            % points in that day
            [time, difference] = sample_from_pd(PD_struct.OCO2,PD_struct.diff); %getting the time wrt SN and the time wrt OCO2
            OCO2_time = solmin + time; %for the UTC time, we add the time since solar noon to the time at solar noon
            OCO3_time = OCO2_time + difference; %to get the OCO3 time we add the time since OCO2 to the OCO2 time

            OCO2_index = find(abs(location_struct.hours(:,day) - OCO2_time) < 0.25); %search for all TCCON points within half an hour of selected times
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
        subsampled_struct.delta_solmin(day,1) = time;

        subsampled_struct.daynames(day,1) = Daynames_Struct(day);
          
        for field = 1:length(fields)
          %  field
            if field == 2 %we already have hours in. don't need it again
                continue
            end
            subsampled_struct.(fields{field})(day,1) = nanmean(location_struct.(fields{field})(OCO2_index,day));
            subsampled_struct.(fields{field})(day,2) = nanmean(location_struct.(fields{field})(OCO3_index,day));


        end
 
   end
   %making all the delta variables, which is difference between
   %observations
   subsampled_struct.delta_xco2(:,1) = subsampled_struct.xco2(:,2) - subsampled_struct.xco2(:,1);
   subsampled_struct.delta_temp(:,1) = subsampled_struct.temp(:,2) - subsampled_struct.temp(:,1);
   subsampled_struct.delta_solzen(:,1) = subsampled_struct.solzen(:,2) - subsampled_struct.solzen(:,1);
   subsampled_struct.delta_hour(:,1) = subsampled_struct.hours(:,2) - subsampled_struct.hours(:,1);
   subsampled_struct.delta_azim(:,1) = subsampled_struct.azim(:,2) - subsampled_struct.azim(:,1);
   subsampled_struct.delta_pressure(:,1) = subsampled_struct.pressure(:,2) - subsampled_struct.pressure(:,1);
   subsampled_struct.delta_wind_speed(:,1) = subsampled_struct.wind_speed(:,2)- subsampled_struct.wind_speed(:,1);
   subsampled_struct.delta_airmass(:,1) = subsampled_struct.airmass(:,2) - subsampled_struct.airmass(:,1);
   subsampled_struct.delta_xh2o(:,1) = subsampled_struct.xh2o(:,2) - subsampled_struct.xh2o(:,1);
   subsampled_struct.prior_diff(:,1) = subsampled_struct.xco2(:,1) - subsampled_struct.prior_xco2(:,1); 
   subsampled_struct.prior_diff(:,2) = subsampled_struct.xco2(:,2) - subsampled_struct.prior_xco2(:,2);
   subsampled_struct.h2o_p_diff(:,1) = subsampled_struct.xh2o(:,1) - subsampled_struct.prior_xh2o(:,1);
   end