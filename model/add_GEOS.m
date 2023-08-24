function [Subsampled_Struct,tossers] = add_GEOS(Daynames, Subsampled_Struct, site_name,solmin_array)
%GEOS info from GEOS_process_.m and Process_GEOS.m

years_list = year(Daynames); %all the days from the TCCON site that we want to get the GEOS info from as a feature
years_rep = unique(years_list); %how many individual years are there -- these are the GEOS files we need to load in
tossers = [];
count = 0;
for i = 1:length(years_rep) %loop through all the years we have
    TCCON_days_in_year = Daynames(years_list == years_rep(i)); %how many days from that year do we have
    solmin_in_year = solmin_array(years_list == years_rep(i)); %what are the solar min times for each day in that year
    file =  ['C:\Users\cmarchet\Box\JPL\Processed_Data\GEOS_Struct_',num2str(years_rep(i)),'.mat']; %reading in that years processed GEOS file
    load(file)
    GEOS_location = GEOS_Struct.(site_name); %extracting the TCCON site from the GEOS struct
    for j = 1:length(TCCON_days_in_year) %looping over each represented day
        count = count+1;
        index = find(GEOS_Struct.days == datetime(TCCON_days_in_year(j))); %find the GEOS column that matches up to that day
        if ~isempty(index) %GEOS has every day repped, but just in case we don't have that day, we have an if statement
            day_pressure = GEOS_location.pressure(:,index); %taking the corresponding variables from the day of interest
            day_temp = GEOS_location.temp(:,index);
            day_humidity = GEOS_location.humidity(:,index);
            times = [0:3:21]; %these are the possible times from GEOS

            nanind = find(day_temp ==0); %in my script, if GEOS doesn't have a value from that time we make it zero. So this is looking for those instances
            day_pressure(nanind) = []; %get rid of the times when GEOS didn't have the file
            day_temp(nanind) = [];
            day_humidity(nanind) = [];
            times(nanind) = [];

            sol_min_day = solmin_in_year(j);
            interp_times = sol_min_day-3:sol_min_day+3; %were interested in the 6 hours around solar noon. these are those times for this day
%this part is actually so annoying
            if sol_min_day -3 < 0 %if solar_min time -3 is less than zero, it means that some of our data is from the previous day, and we 
                %need to load in a previous file
            if index ~= 1 %if this occurs on the first day of the year, we need to load in the last day from the previous year
            prev_day_pressure = GEOS_location.pressure(:,index-1); %index - 1 for yesterday
            prev_day_temp = GEOS_location.temp(:,index-1);
            prev_day_humidity = GEOS_location.humidity(:,index-1);
            prev_times = [-24:3:-3]; %wrt current day, these are yesterdays times

            nanind = find(prev_day_temp ==0);
            prev_day_pressure(nanind) = [];
            prev_day_temp(nanind) = [];
            prev_day_humidity(nanind) = [];
            prev_times(nanind) = [];

            times = cat(2,prev_times,times);
            day_pressure = cat(1,prev_day_pressure,day_pressure);
            day_temp = cat(1,prev_day_temp,day_temp);
            day_humidity = cat(1,prev_day_humidity,day_humidity);
            else %loading in the prev year
             file =  ['C:\Users\cmarchet\Box\JPL\Processed_Data\GEOS_Struct_',num2str(years_rep(i-1)),'.mat'];
            GEOS_Struct2 = load(file);
             GEOS_location2 = GEOS_Struct2.GEOS_Struct.(site_name);

              prev_day_pressure = GEOS_location2.pressure(:,end); %reading in the last day from that year
            prev_day_temp = GEOS_location2.temp(:,end);
            prev_day_humidity = GEOS_location2.humidity(:,end);
                prev_times = [-24:3:-3];

            nanind = find(prev_day_temp ==0);
            prev_day_pressure(nanind) = [];
            prev_day_temp(nanind) = [];
            prev_day_humidity(nanind) = [];
            prev_times(nanind) = [];

             times = cat(2,prev_times,times);
            day_pressure = cat(1,prev_day_pressure,day_pressure);
            day_temp = cat(1,prev_day_temp,day_temp);
            day_humidity = cat(1,prev_day_humidity,day_humidity);
          
            end

            end

             if sol_min_day +3 > 21 %if the time + 3 is greater than 21 we need to load in tomorrows file
            if index ~= 365 && index ~= 366 %this is because of leap years, but if this occurs on the last day of the year we have to read in next years file
            fut_day_pressure = GEOS_location.pressure(:,index+1);
            fut_day_temp = GEOS_location.temp(:,index+1);
            fut_day_humidity = GEOS_location.humidity(:,index+1);
            fut_times = [24:3:45];

            nanind = find(fut_day_temp ==0);
            fut_day_pressure(nanind) = [];
            fut_day_temp(nanind) = [];
            fut_day_humidity(nanind) = [];
            fut_times(nanind) = [];

            times = cat(2,times,fut_times);
            day_pressure = cat(1,day_pressure,fut_day_pressure);
            day_temp = cat(1,day_temp,fut_day_temp);
            day_humidity = cat(1,day_humidity,fut_day_humidity);

            else % this SUCKS. I have to read in a whole near years file
             file =  ['C:\Users\cmarchet\Box\JPL\Processed_Data\GEOS_Struct_',num2str(years_rep(i+1)),'.mat'];
            GEOS_Struct2 = load(file);
             GEOS_location2 = GEOS_Struct2.GEOS_Struct.(site_name);

              fut_day_pressure = GEOS_location2.pressure(:,1);
            fut_day_temp = GEOS_location2.temp(:,1);
            fut_day_humidity = GEOS_location2.humidity(:,1);
            fut_times = [24:3:45];

            nanind = find(fut_day_temp ==0);
            fut_day_pressure(nanind) = [];
            fut_day_temp(nanind) = [];
            fut_day_humidity(nanind) = [];
            fut_times(nanind) = [];

            times = cat(2,times,fut_times);
            day_pressure = cat(1,day_pressure,fut_day_pressure);
            day_temp = cat(1,day_temp,fut_day_temp);
            day_humidity = cat(1,day_humidity,fut_day_humidity);

   
            end

            end


            interp_pressure = interp1(times,day_pressure,interp_times); %interpolate the times we have onto the times we want
            interp_temp = interp1(times,day_temp,interp_times);
            interp_humidity = interp1(times,day_humidity,interp_times);
            Subsampled_Struct.GEOS_pressure(count,:) = interp_pressure;
            Subsampled_Struct.GEOS_temp(count,:) = interp_temp;
            Subsampled_Struct.GEOS_humidity(count,:) = interp_humidity;
        else
            tossers = cat(1,tossers,find(Daynames == TCCON_days_in_year(j)));
        end

    end

end