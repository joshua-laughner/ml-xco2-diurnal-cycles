function [drawdown] = calc_drawdown_real(loc_struct)
%% calculates drawdown from un gridded TCCON data
%input: loc_struct is the Daily Array Structure for a particular location. 
% ex: [real_drawdown_ETL] = calc_drawdown_real(Daily_Struct_ETL)

      solar_mins = loc_struct.solar_min;
      hours = loc_struct.hours;
      xco2 = loc_struct.xco2;
    for i = 1:length(solar_mins)
     
        day_solmin = solar_mins(i);

        day_hours = hours(:,i);

        day_xco2 = xco2(:,i);

        starttime = find(abs(day_hours - (day_solmin - 3)) < 0.5);
        endtime = find(abs(day_hours - (day_solmin + 3)) < 0.5);

        drawdown(i) = (nanmean(day_xco2(endtime)) - nanmean(day_xco2(starttime)));

    end


end