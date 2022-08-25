
function [day_struct]=  select_day(date, filename, figure_boolean)
   %% a function for visualizing individual days
   %input the date in format 'yyyy-MM-dd', filename of the .nc file from
   %TCCON, and 0 if you want it to generate figures

    xco2 = ncread(filename, 'xco2');
    solar_zenith = ncread(filename, 'solzen');
    hour = ncread(filename, 'hour');
    time = ncread(filename, 'time');
    azim = ncread(filename, 'azim');

    calendar_time = datetime(1970,1,1) + seconds(time);
    calendar_time.Format = 'yyyy-MM-dd';

    date_index = find(string(calendar_time) == date);
    xco2_day = xco2(date_index);
    hours_day = hour(date_index);
    solzen_day = solar_zenith(date_index);
    azim_day = azim(date_index);

    p = polyfit(hours_day,solzen_day,2);
        
    d1p = polyder(p);                           % First Derivative
    d2p = polyder(d1p);                         % Second Derivative
    ips = roots(d1p);                           % Inflection Points
    xtr = polyval(d2p, ips);                    % Evaluate ‘d2p’ at ‘ips’
    solar_noon = ips((xtr > 0) & (imag(xtr)==0));   % Find Minima

    closest_time = hours_day(findin(solar_noon, hours_day));

    [sorted, sort_ind] = sort(hours_day);
    xco2_day = xco2_day(sort_ind);
    
    points_per_hour(1) = length(hours_day)/(max(hours_day)-min(hours_day));
        if points_per_hour(1) < 5
            points_per_hour(1) = 5;
        end

    [xco2_day,TF] = rmoutliers(xco2_day,'movmedian',points_per_hour(1),'SamplePoints',sorted);
     hours_day = hours_day(~TF);
     sorted= sorted(~TF);
    
    quart_hour_times = solar_noon-3.75:.25:solar_noon + 3.75;
    quart_hour_av = [];

     xco2_minus_solar_noon = xco2_day - mean(xco2_day(find(abs(sorted - solar_noon)<.25)));


   for i = 1:length(quart_hour_times)-1
        time_ind = find(abs(hours_day - quart_hour_times(i)) < .125);
        quart_hour_av(i) = mean(xco2_minus_solar_noon(time_ind), 'omitnan');


    end
    
    a = quart_hour_av(1:end-1);
    b = quart_hour_av(2:end);
    mean_dif_succ_points = mean(abs(b-a),'omitnan');

    day_struct.xco2 = xco2_day;
    day_struct.xco2_minus_solzen = xco2_minus_solar_noon;
    day_struct.hours = hours_day;
    day_struct.solzen = solzen_day;
    day_struct.azim = azim_day;
    day_struct.solar_noon = solar_noon;
    day_struct.closest_time = closest_time;
    day_struct.xco2_at_solar_noon = mean(xco2_day(find(abs(hours_day - solar_noon)<.25)));
    day_struct.mean_diff = mean_dif_succ_points;
    day_struct.pph = points_per_hour;

    if figure_boolean == 0
        
        figure(1)
        scatter(sorted, xco2_day, 10, 'filled')
        xlabel('Hour (UTC)', 'fontsize', 20)
        ylabel('XCO_2', 'fontsize', 20)
        ylim([min(xco2_day) - 0.3, max(xco2_day) + 0.3]);
        title(['XCO_2 Timeseries at ', date], 'fontsize', 20)
    
       figure(2)
        clf
        scatter(sorted, xco2_minus_solar_noon,10,  'filled')
        xlabel('Hour (UTC)', 'fontsize', 20)
        ylabel('XCO_2 Minus Solzen', 'fontsize', 20)
         ylim([min(xco2_minus_solar_noon) - 0.3, max(xco2_minus_solar_noon) + 0.3]);
        title(['Adjusted XCO_2 Timeseries at ', date], 'fontsize', 20)
  

        figure(3)
        clf
         plot(sorted, movmean(xco2_minus_solar_noon, 35), 'b')
        xlabel('hour', 'fontsize', 15)
        ylabel('xco2', 'fontsize', 15)
        title(['Averaged XCO_2 Timeseries at ', date], 'fontsize', 20)

        figure(4)
        clf
        scatter(quart_hour_times(1:end-1), quart_hour_av, 10, 'filled')
        ylim([min(xco2_minus_solar_noon) - 0.3, max(xco2_minus_solar_noon) + 0.3]);
        %xlim([14 26])
        xlabel('Hour (UTC)', 'fontsize', 20)
        ylabel('XCO_2 Minus Solzen', 'fontsize', 20)
        title(['Averaged XCO_2 Timeseries at ', date], 'fontsize', 20)

        figure(4)
        scatter(sorted, day_struct.solzen, 10, 'filled')
         xlabel('Hour (UTC)', 'fontsize', 20)
        ylabel('Solar Zenith Angle', 'fontsize', 20)
        title(['Solar Zenith angle at ', date], 'fontsize', 20)
    end

end