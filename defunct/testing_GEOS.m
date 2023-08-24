load C:\Users\cmarchet\Box\JPL\Processed_Data\Daily_Struct_ETL.mat
load C:\Users\cmarchet\Box\JPL\Processed_Data\Subsampled_Struct.mat
%%
Subsampled_ETL = Subsampled_Struct.ETL;
Daynames = Daily_Struct_ETL.days;
Subsampled_Struct = Subsampled_ETL;
site_name = 'ETL';
solmin_array = Daily_Struct_ETL.solar_min;

years_list = year(Daynames);
years_rep = unique(years_list);
tossers = [];
count = 0;
for i = 1:length(years_rep)
    TCCON_days_in_year = Daynames(years_list == years_rep(i));
    solmin_in_year = solmin_array(years_list == years_rep(i));
    file =  ['C:\Users\cmarchet\Box\JPL\Processed_Data\GEOS_Struct_',num2str(years_rep(i)),'.mat'];
    load(file)
    GEOS_location = GEOS_Struct.(site_name);
    for j = 1:length(TCCON_days_in_year)
        count = count+1;
        index = find(GEOS_Struct.days == datetime(TCCON_days_in_year(j)));
        if ~isempty(index)
            day_pressure = GEOS_location.pressure(:,index);
            day_temp = GEOS_location.temp(:,index);
            day_humidity = GEOS_location.humidity(:,index);
            times = [0:3:21];

            nanind = find(day_temp ==0);
            day_pressure(nanind) = [];
            day_temp(nanind) = [];
            day_humidity(nanind) = [];
            times(nanind) = [];

            sol_min_day = solmin_in_year(j);
            interp_times = sol_min_day-3:sol_min_day+3;

            if sol_min_day -3 < 0

            prev_day_pressure = GEOS_location.pressure(:,index-1);
            prev_day_temp = GEOS_location.temp(:,index-1);
            prev_day_humidity = GEOS_location.humidity(:,index-1);
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

             if sol_min_day +3 > 21
            if index ~= 365
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


            interp_pressure = interp1(times,day_pressure,interp_times);
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