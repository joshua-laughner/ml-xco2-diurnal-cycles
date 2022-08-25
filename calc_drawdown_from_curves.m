function [predicted_drawdown] = calc_drawdown_from_curves(solar_mins, hours_pred, xco2_predicted)
    %% calculates drawdown based on the created XCO2 diurnal cycles from machine learning predicted PCs
    % [predicted_drawdown] = calc_drawdown_from_curves(solar_mins,
    % hours_pred, xco2_predicted) 
    % creates an array of drawdowns from the
    % solar_min array, the array of quarter hour averaged xco2 points, and
    % the corresponding array of the times of the quarter hour averaged
    % points. It uses the time array and the solar min array to find which
    % xco2 values to subtract from eachother. 

    %solar min array, hours_pred array and xco2_predicted array should have
    %the same length


    for i = 1:length(solar_mins)
        day_solmin = solar_mins(i);

        day_hours_pred = hours_pred(i,:);
        day_xco2_pred = xco2_predicted(i,:);
       
        starttime_pred = find(abs(day_hours_pred - (day_solmin - 3)) < 0.5);
        endtime_pred = find(abs(day_hours_pred - (day_solmin + 3)) < 0.5);

        predicted_drawdown(i) = (mean(day_xco2_pred(endtime_pred)) - mean(day_xco2_pred(starttime_pred)));
     
    end


end