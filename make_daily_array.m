function [Struct] = make_daily_array(filename)
%% puts the values from the TCCON .nc file into an array separated by day
%input: name of the TCCON .nc file

    if strcmp(filename, 'lauder')
        load('Lauder.mat');
        xco2 = Lauder.xco2;
        solzen = Lauder.solzen;
        hour = Lauder.hour;
        time = Lauder.time;
        azim = Lauder.azim;

        temp = Lauder.temp;
         humidity = Lauder.humidity;

         % for my post filtering
        wind_speed = Lauder.wind_speed;
        wind_dir = Lauder.wind_dir;
        pressure = Lauder.pressure;
        pres_alt = Lauder.pressure_altitude;
        mid_trop = Lauder.mid_tropospheric_potential_temperature;
        trop_alt = Lauder.tropopause_altitude;
         else
        xco2 = ncread(filename, 'xco2');
        solzen = ncread(filename, 'solzen');
        hour = ncread(filename, 'hour');
        time = ncread(filename, 'time');
        azim = ncread(filename, 'azim');
       
%reading in the variables that ima use to try and machine learning model
%whether we keep a day
        temp = ncread(filename, 'tout');
         humidity = ncread(filename, 'hout');
         wind_dir = ncread(filename, 'wdir');
         wind_speed = ncread(filename, 'wspd');
         pressure = ncread(filename, 'pout');
         pres_alt = ncread(filename, 'zmin');
         trop_alt = ncread(filename, 'prior_tropopause_altitude');
        mid_trop = ncread(filename, 'prior_mid_tropospheric_potential_temperature');

       
    end

%dealing with date formatting
    calendar_time = datetime(1970,1,1) + seconds(time);
    calendar_time.Format = 'yyyy-MM-dd';

    unique_dates = unique(string(calendar_time));

    %initializing empty arrays
    xco2_daily_array = [];
    hours_daily_array = [];
    solzen_daily_array = [];
    azim_daily_array = [];

     temp_daily_array = [];
    humidity_daily_array = [];

    pressure_daily_array = [];
    wind_speed_daily_array = [];
    wind_dir_daily_array = [];
    pres_alt_daily_array = [];
    trop_alt_daily_array = [];
    mid_trop_daily_array = [];

   
    kept_days = strings(5,1); %5 is arbitrary, so it knows its a string array
    solar_min = [];
    mean_diff_array = [];
    med_diff_array = [];
    rmse_array = [];
    
   

    column_num = 0; %because we skip some days
    for i = 1:length(unique_dates)
        
        disp(unique_dates(i))


        day_index = find(string(calendar_time) == unique_dates(i)); %finding all the points from that day
        xco2_i = xco2(day_index); %grabbing the corresponding values
        hour_i = hour(day_index);
        solzen_i = solzen(day_index);
        azim_i = azim(day_index);
       
        temp_i = temp(day_index);
        humidity_i = humidity(day_index);

        pressure_i = pressure(day_index);
        pres_alt_i = pres_alt(day_index);
        wind_speed_i = wind_speed(day_index);
        wind_dir_i = wind_dir(day_index);
        mid_trop_i = mid_trop(day_index);
        trop_alt_i = trop_alt(day_index);
         

        if length(xco2_i) < 50
            disp(['fewer than 50 points in ', unique_dates(i)])
            continue
        end

        if (max(hour_i) - min(hour_i)) < 4
            disp(['fewer than 4 hours of observations in ', unique_dates(i)])
            continue
        end

        [sorted_hour, sortind] = sort(hour_i);

        solzen_sorted = solzen_i(sortind);

        p = polyfit(sorted_hour,solzen_sorted,2);
        
        d1p = polyder(p);                           % First Derivative
        d2p = polyder(d1p);                         % Second Derivative
        ips = roots(d1p);                           % Inflection Points
        xtr = polyval(d2p, ips);                    % Evaluate ‘d2p’ at ‘ips’
        solar_noon = ips((xtr > 0) & (imag(xtr)==0));   % Find Minima %the actual minimum time
        
        try
        closest_hour = hour_i(findin(solar_noon, hour_i)); %the minimum time we have
        catch
            disp('idk its the weird thing')
            continue
        end

         xco2_i_minus_solzen = xco2_i - mean(xco2_i(find(abs(hour_i - solar_noon)<.5)));

        if (abs(closest_hour - solar_noon) > 0.5)
            disp(['closest hour not close enough', unique_dates(i) ])
            continue
        end

        if (closest_hour + 2 > max(hour_i)) %maybe change this to three hours?
            disp(['not enough hours after solar noon ', unique_dates(i)])
            continue
        end

         if (closest_hour - 2 < min(hour_i)) %maybe change this to three hours?
            disp(['not enough hours before solar noon ', unique_dates(i)])
            continue
         end

       
%makin the features set
%i think i want mean, variance, max, min, and max delta
         points_per_hour(1) = length(hour_i)/(max(hour_i)-min(hour_i));
        if points_per_hour(1) < 5
            points_per_hour(1) = 5;
        end
         
     
     
          %checking how close to the line of best fit it is
        sorted_xco2 = xco2_i_minus_solzen(sortind);
        [xco2_sort_rm,TF] = rmoutliers(sorted_xco2,'movmedian',points_per_hour(1),'SamplePoints',sorted_hour);
        sorted_hour_rm = sorted_hour(~TF);
%mean difference between successive points time
       [~, gof] = fit(sorted_hour_rm,xco2_sort_rm,'poly3' ); %if a 3 doesn't work try a 4, hold to slightly higher standard. .4 v .5 maybe
   

   a = xco2_sort_rm(1:end-1);
   b = xco2_sort_rm(2:end);
   num = b-a;
   
   n = sorted_hour_rm(1:end-1);
   m = sorted_hour_rm(2:end);
   den = m-n;
   
   
   
   mean_dif_succ_points = mean(double(abs(num./den)), 'omitnan');
   med_dif_succ_points = median(double(abs(num./den)), 'omitnan');



 column_num = column_num + 1;

        if column_num > 1
            difference = length(xco2_daily_array(:,1)) - length(xco2_sort_rm);
        end

        solzen_sorted_rm = solzen_sorted(~TF);

        azim_sorted = azim_i(sortind);
        azim_sorted_rm = azim_sorted(~TF);

        temp_sorted = temp_i(sortind);
        temp_sorted_rm = temp_sorted(~TF);
        
          humidity_sorted = humidity_i(sortind);
        humidity_sorted_rm = humidity_sorted(~TF);

        wind_speed_sorted = wind_speed_i(sortind);
        wind_speed_sorted_rm = wind_speed_sorted(~TF);

        wind_dir_sorted = wind_dir_i(sortind);
        wind_dir_sorted_rm = wind_dir_sorted(~TF);

        pressure_sorted = pressure_i(sortind);
        pressure_sorted_rm = pressure_sorted(~TF);

        pres_alt_sorted = pres_alt_i(sortind);
        pres_alt_sorted_rm = pres_alt_sorted(~TF);

        trop_alt_sorted = trop_alt_i(sortind);
        trop_alt_sorted_rm = trop_alt_sorted(~TF);

        mid_trop_sorted = mid_trop_i(sortind);
        mid_trop_sorted_rm = mid_trop_sorted(~TF);


       
        if (column_num>1 && difference>0)
            for x = 1:difference
                xco2_sort_rm = cat(1, xco2_sort_rm, NaN);
                sorted_hour_rm = cat(1, sorted_hour_rm, NaN);
                solzen_sorted_rm = cat(1, solzen_sorted_rm, NaN);
                azim_sorted_rm = cat(1, azim_sorted_rm, NaN);
                 temp_sorted_rm = cat(1, temp_sorted_rm, NaN);
                humidity_sorted_rm = cat(1, humidity_sorted_rm, NaN);
                pressure_sorted_rm = cat(1, pressure_sorted_rm, NaN);
                pres_alt_sorted_rm = cat(1, pres_alt_sorted_rm, NaN);
                wind_speed_sorted_rm = cat(1, wind_speed_sorted_rm, NaN);
                wind_dir_sorted_rm = cat(1, wind_dir_sorted_rm, NaN);
                mid_trop_sorted_rm = cat(1, mid_trop_sorted_rm, NaN);
                trop_alt_sorted_rm = cat(1, trop_alt_sorted_rm, NaN);
               
            end

        elseif (column_num>1 && difference < 0)
            xco2_daily_array( end+1:end+abs(difference), 1: i-1) = NaN;
            hours_daily_array(end+1:end+abs(difference), 1:i-1) = NaN;
            solzen_daily_array(end+1: end+abs(difference), 1:i-1)= NaN;
            azim_daily_array(end+1:end+abs(difference), 1:i-1)= NaN;
             temp_daily_array(end+1:end+abs(difference), 1:i-1)= NaN;
            humidity_daily_array(end+1:end+abs(difference), 1:i-1)= NaN;

            pressure_daily_array(end+1:end+abs(difference), 1:i-1)= NaN;
            pres_alt_daily_array(end+1:end+abs(difference), 1:i-1)= NaN;
            wind_speed_daily_array(end+1:end+abs(difference), 1:i-1)= NaN;
            wind_dir_daily_array(end+1:end+abs(difference), 1:i-1)= NaN;
            mid_trop_daily_array(end+1:end+abs(difference), 1:i-1)= NaN;
            trop_alt_daily_array(end+1:end+abs(difference), 1:i-1)= NaN;



           
        end

        xco2_daily_array(:,column_num) = xco2_sort_rm;
        hours_daily_array(:,column_num) = sorted_hour_rm;
        solzen_daily_array(:, column_num) = solzen_sorted_rm;
        azim_daily_array(:,column_num) = azim_sorted_rm;
        temp_daily_array(:, column_num) = temp_sorted_rm;
         humidity_daily_array(:, column_num) = humidity_sorted_rm;

         pressure_daily_array(:, column_num) = pressure_sorted_rm;
         pres_alt_daily_array(:, column_num) = pres_alt_sorted_rm;
         wind_speed_daily_array(:,column_num) = wind_speed_sorted_rm;
         wind_dir_daily_array(:,column_num) = wind_dir_sorted_rm;
         mid_trop_daily_array(:,column_num) = mid_trop_sorted_rm;
         trop_alt_daily_array(:,column_num) = trop_alt_sorted_rm;

       
        kept_days(column_num) = unique_dates(i);
        solar_min(column_num) = closest_hour;
        mean_diff_array(column_num) = mean_dif_succ_points;
        med_diff_array(column_num) = med_dif_succ_points;
        rmse_array(column_num) = gof.rmse;
      
       
      
    end
    Struct.xco2 = xco2_daily_array;
    Struct.hours = hours_daily_array;
    Struct.solzen = solzen_daily_array;
    Struct.azim = azim_daily_array;
    Struct.days = kept_days;
    Struct.solar_min = solar_min;
    Struct.temp = temp_daily_array;
    Struct.humidity = humidity_daily_array;
    Struct.pressure = pressure_daily_array;
    Struct.pres_alt = pres_alt_daily_array;
    Struct.wind_speed = wind_speed_daily_array;
    Struct.wind_dir = wind_dir_daily_array;
    Struct.trop_alt = trop_alt_daily_array;
    Struct.mid_trop = mid_trop_daily_array;
    Struct.mean_diff = mean_diff_array;
    Struct.med_diff = med_diff_array;
    Struct.rmse = rmse_array;
    
    Struct = remove_extras(Struct);
  
end 
