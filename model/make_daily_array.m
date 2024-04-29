function [Struct] = make_daily_array(filename)
%% puts the values from the TCCON .nc file into an array separated by day
%input: name of the TCCON .nc file

    if strcmp(filename, 'lauder') %lauder comes in three parts so i already took things out and made one .mat file
        %lauder file is made in processing_lauder_files
        load /home/cmarchet/Data/Lauder.mat
        xco2 = Lauder.xco2;
        solzen = Lauder.solzen;
        hour = Lauder.hour;
        time = Lauder.time;
        azim = Lauder.azim;

        temp = Lauder.temp;
        pressure = Lauder.pressure;
        wind_speed = Lauder.wind_speed;
        prior_xh2o = Lauder.prior_xh2o;
        prior_xco2 = Lauder.prior_xco2;
        xh2o_error = Lauder.xh2o_error;
        airmass = Lauder.airmass;
        altitude = Lauder.altitude;
        xh2o = Lauder.xh2o;
        xco2_error = Lauder.xco2_error;

    else % reading in the data from the netcdf files. big long arrays
        xco2 = ncread(filename, 'xco2');
        solzen = ncread(filename, 'solzen');
        hour = ncread(filename, 'hour');
        time = ncread(filename, 'time');
        azim = ncread(filename, 'azim');
        temp = ncread(filename, 'tout');
        pressure = ncread(filename, 'pout');
        wind_speed = ncread(filename, 'wspd');
        prior_xh2o = ncread(filename,'prior_xh2o');
        prior_xco2 = ncread(filename,'prior_xco2');
        xh2o_error = ncread(filename,'xh2o_error');
        airmass = ncread(filename,'airmass');
        altitude = ncread(filename,'zobs');
        xh2o = ncread(filename,'xh2o');
        xco2_error = ncread(filename,'xco2_error'); 
        xco = ncread(filename,'xco');
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
     pressure_daily_array = [];
     wind_speed_daily_array = [];
     prior_xh2o_daily_array = [];
     prior_xco2_daily_array = [];
     xh2o_error_daily_array = [];
     airmass_daily_array = [];
     altitude_daily_array = [];
     xh2o_daily_array = [];
     xco2_error_daily_array = [];
     xco_daily_array = [];

   
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
        pressure_i = pressure(day_index);
        wind_speed_i = wind_speed(day_index);
        prior_xh2o_i = prior_xh2o(day_index);
        prior_xco2_i = prior_xco2(day_index);
        xh2o_error_i = xh2o_error(day_index);
        airmass_i = airmass(day_index);
        altitude_i = altitude(day_index);
        xh2o_i = xh2o(day_index);
        xco2_error_i = xco2_error(day_index);
        xco_i = xco(day_index);
         
%things that we flag for
        if length(xco2_i) < 30
            disp(['fewer than 30 points in ', unique_dates(i)])
            continue
        end

        if (max(hour_i) - min(hour_i)) < 4
            disp(['fewer than 4 hours of observations in ', unique_dates(i)])
            continue
        end

        %okay here we're sorting the values by time (just in case its not
        %by time?) and fitting a parabola to solar zenith to find the solar
        %noon time
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

        %want to make sure we have times near solar noon
         if (abs(closest_hour - solar_noon) > 0.5)
            disp(['closest hour not close enough', unique_dates(i) ])
            continue
        end
% want to make sure we have a wide enough range of times
        if (closest_hour + 2 > max(hour_i)) 
            disp(['not enough hours after solar noon ', unique_dates(i)])
            continue
        end

         if (closest_hour - 2 < min(hour_i)) 
            disp(['not enough hours before solar noon ', unique_dates(i)])
            continue
         end

      
         points_per_hour(1) = length(hour_i)/(max(hour_i)-min(hour_i));
        if points_per_hour(1) < 5
            points_per_hour(1) = 5;
        end
         
     
     %removing crazy TCCON outliers
        sorted_xco2 = xco2_i(sortind);
        [xco2_sort_rm,TF] = rmoutliers(sorted_xco2,'movmedian',points_per_hour(1),'SamplePoints',sorted_hour);
        sorted_hour_rm = sorted_hour(~TF);

        %this is adding nans to make sure all the columns are the same
        %length
        column_num = column_num + 1;

        if column_num > 1
            difference = length(xco2_daily_array(:,1)) - length(xco2_sort_rm);
        end

        solzen_sorted_rm = solzen_sorted(~TF);

        azim_sorted = azim_i(sortind);
        azim_sorted_rm = azim_sorted(~TF);

        temp_sorted = temp_i(sortind);
        temp_sorted_rm = temp_sorted(~TF);
        
        pressure_sorted = pressure_i(sortind);
        pressure_sorted_rm = pressure_sorted(~TF);

        wind_speed_sorted = wind_speed_i(sortind);
        wind_speed_sorted_rm = wind_speed_sorted(~TF);

        prior_xh2o_sorted = prior_xh2o_i(sortind);
        prior_xh2o_sorted_rm = prior_xh2o_sorted(~TF);

        prior_xco2_sorted = prior_xco2_i(sortind);
       prior_xco2_sorted_rm = prior_xco2_sorted(~TF);

        xh2o_error_sorted = xh2o_error_i(sortind);
        xh2o_error_sorted_rm = xh2o_error_sorted(~TF);

        airmass_sorted = airmass_i(sortind);
        airmass_sorted_rm = airmass_sorted(~TF);

        altitude_sorted = altitude_i(sortind);
        altitude_sorted_rm = altitude_sorted(~TF);

        xh2o_sorted = xh2o_i(sortind);
        xh2o_sorted_rm = xh2o_sorted(~TF);

        xco2_error_sorted = xco2_error_i(sortind);
        xco2_error_sorted_rm = xco2_error_sorted(~TF);

        xco_sorted = xco_i(sortind);
        xco_sorted_rm = xco_sorted(~TF);


       
        if (column_num>1 && difference>0)
            for x = 1:difference
                xco2_sort_rm = cat(1, xco2_sort_rm, NaN);
                sorted_hour_rm = cat(1, sorted_hour_rm, NaN);
                solzen_sorted_rm = cat(1, solzen_sorted_rm, NaN);
                azim_sorted_rm = cat(1, azim_sorted_rm, NaN);
                 temp_sorted_rm = cat(1, temp_sorted_rm, NaN);
               pressure_sorted_rm = cat(1,pressure_sorted_rm,NaN);
               wind_speed_sorted_rm = cat(1,wind_speed_sorted_rm,NaN);
               prior_xh2o_sorted_rm = cat(1,prior_xh2o_sorted_rm,NaN);
              prior_xco2_sorted_rm = cat(1,prior_xco2_sorted_rm,NaN);
               xh2o_error_sorted_rm = cat(1,xh2o_error_sorted_rm,NaN);
               airmass_sorted_rm = cat(1,airmass_sorted_rm,NaN);
               altitude_sorted_rm = cat(1,altitude_sorted_rm,NaN);
               xh2o_sorted_rm = cat(1,xh2o_sorted_rm,NaN);
               xco2_error_sorted_rm = cat(1,xco2_error_sorted_rm, NaN);
               xco_sorted_rm = cat(1,xco_sorted_rm, NaN);
            end

        elseif (column_num>1 && difference < 0)
            xco2_daily_array( end+1:end+abs(difference), 1: i-1) = NaN;
            hours_daily_array(end+1:end+abs(difference), 1:i-1) = NaN;
            solzen_daily_array(end+1: end+abs(difference), 1:i-1)= NaN;
            azim_daily_array(end+1:end+abs(difference), 1:i-1)= NaN;
             temp_daily_array(end+1:end+abs(difference), 1:i-1)= NaN;
             pressure_daily_array(end+1:end+abs(difference), 1:i-1)= NaN;
             wind_speed_daily_array(end+1:end+abs(difference), 1:i-1)= NaN;
          %   prior_pressure_daily_array(end+1:end+abs(difference), 1:i-1)= NaN;
             prior_xh2o_daily_array(end+1:end+abs(difference), 1:i-1)= NaN;
             prior_xco2_daily_array(end+1:end+abs(difference), 1:i-1)= NaN;
             xh2o_error_daily_array(end+1:end+abs(difference), 1:i-1)= NaN;
             airmass_daily_array(end+1:end+abs(difference), 1:i-1)= NaN;
             altitude_daily_array(end+1:end+abs(difference), 1:i-1)= NaN;
             xh2o_daily_array(end+1:end+abs(difference), 1:i-1)= NaN;
             xco2_error_daily_array(end+1:end+abs(difference), 1:i-1)= NaN;
             xco_daily_array(end+1:end+abs(difference), 1:i-1)= NaN;

           
        end

        xco2_daily_array(:,column_num) = xco2_sort_rm;
        hours_daily_array(:,column_num) = sorted_hour_rm;
        solzen_daily_array(:, column_num) = solzen_sorted_rm;
        azim_daily_array(:,column_num) = azim_sorted_rm;
        temp_daily_array(:, column_num) = temp_sorted_rm;

        pressure_daily_array(:, column_num) = pressure_sorted_rm;
        wind_speed_daily_array(:, column_num) = wind_speed_sorted_rm;
        prior_xh2o_daily_array(:, column_num) = prior_xh2o_sorted_rm;
        prior_xco2_daily_array(:, column_num) = prior_xco2_sorted_rm;
        xh2o_error_daily_array(:, column_num) = xh2o_error_sorted_rm;
        airmass_daily_array(:, column_num) = airmass_sorted_rm;
        altitude_daily_array(:, column_num) = altitude_sorted_rm;
        xh2o_daily_array(:, column_num) = xh2o_sorted_rm;
        xco2_error_daily_array(:, column_num) = xco2_error_sorted_rm;
        xco_daily_array(:, column_num) = xco_sorted_rm;
  
       
        kept_days(column_num) = unique_dates(i);
        solar_min(column_num) = closest_hour;     
       
      
    end
    Struct.xco2 = xco2_daily_array;
    Struct.hours = hours_daily_array;
    Struct.solzen = solzen_daily_array;
    Struct.azim = azim_daily_array;
    Struct.days = kept_days;
    Struct.solar_min = solar_min;
    Struct.temp = temp_daily_array;
   Struct.pressure = pressure_daily_array;
   Struct.wind_speed = wind_speed_daily_array;
    Struct.prior_xh2o = prior_xh2o_daily_array;
   Struct.prior_xco2 = prior_xco2_daily_array;
   Struct.xh2o_error = xh2o_error_daily_array;
   Struct.airmass = airmass_daily_array;
   Struct.altitude = altitude_daily_array;
   Struct.xh2o = xh2o_daily_array;
   Struct.xco2_error = xco2_error_daily_array;
   Struct.xco = xco_daily_array;
    
   %sometimes there are weird blank columns at the end? this gets rid of
   %them
    Struct = remove_extras(Struct);
  
end 
