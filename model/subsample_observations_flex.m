function Big_Subsampled = subsample_observations_flex(Daily_Structs,varargin)

A.type = 'oco2-3'; %can also do 'self', or 'create'
A.start_times = [];
A.spacings = [];
A.num_obs = 2;
A.min_num_points = 3;
A.mean = 0;
A.stdev_sp = 0;
A.stdev_st = 0;
A = parse_pv_pairs(A,varargin);

sites = fieldnames(Daily_Structs);
for loc = 1:length(sites)
    %loc
    location_struct = Daily_Structs.(sites{loc});
    rows = length(location_struct.xco2(1,:));
    columns = A.num_obs;
    delta_length = sum(1:A.num_obs-1);
    
    fields = fieldnames(location_struct);
    fields(5:6) = []; %these fields are date, and solar min. We don't subsample from these
    fields(end-1:end) = [];
    %initializing
    for i = 1:length(fields) %initializing my subsampled script. I hate commenting code :( just let it be a mystery
        subsampled_struct.(fields{i}) = nan(rows,columns);
        subsampled_struct.(['delta_',fields{i}]) = nan(rows,delta_length);
    end
    subsampled_struct.daynames = string();
     subsampled_struct.delta_solmin  = nan(rows,1);
      

   for day = 1:length(location_struct.xco2(1,:)) %going through each day in the structure
       subsampled_struct.delta_solmin(day) = nan;
        subsampled_struct.daynames(day,1) = string();
     
       
        solmin = location_struct.solar_min(day);
        count = 0;
        min_length = 0;
        while min_length < A.min_num_points %loop until either its good or we've looped 5 times
            count = count+1;
            times_struct = sample_from_pd_flex(solmin,sites{loc},'type',A.type,'start_times',A.start_times,'spacings',A.spacings,'num_obs',A.num_obs,'stdev_sp',A.stdev_sp,'stdev_st',A.stdev_st);
            
            time_names = fieldnames(times_struct);
            index_length_array = nan(1,length(time_names));
            for time = 1:length(time_names)
                index = find(abs(location_struct.hours(:,day) - times_struct.(time_names{time})) < 0.25); %search for all TCCON points within half an hour of selected times
                index_length_array(time) = length(index);
                index_struct.(time_names{time}) = index;
            end
     
            min_length = min(index_length_array);
          
            quit = 0;
            if count > 4 %don't want to be drawing forever
                quit = 1;
                
                break
            end
        end
        if quit == 1
            continue
        end
     
       subsampled_struct.delta_solmin(day) = times_struct.time_1 - solmin;
        subsampled_struct.daynames(day,1) = location_struct.days(day);
          
        for field = 1:length(fields)
           %field

            if field == length(fields)|| field == length(fields)-1
                continue
            end
            
       
            for point = 1:A.num_obs
                p_ind = index_struct.(time_names{point});
                % Add in error term here: unclear how to average together
                % but for each point in the index subsample from the error
                %for number point do point +
                subsampled_struct.(fields{field})(day,point) = nanmean(location_struct.(fields{field})(p_ind,day));
            end
            all_differences_array = [];
            for dpoint = 1:A.num_obs -1 
                for spoint = dpoint+1:A.num_obs
                 
                   all_differences_array = cat(2,all_differences_array, subsampled_struct.(fields{field})(day,spoint) - subsampled_struct.(fields{field})(day,dpoint));
                end
            end
            subsampled_struct.(['delta_',fields{field}])(day,:) = all_differences_array;
         
        end
 
   end
   subsampled_struct.delta_temp_abs = location_struct.delta_abs.';
   subsampled_struct.delta_temp_reg = location_struct.delta_reg.';

   Big_Subsampled.(sites{loc}) = subsampled_struct;
end