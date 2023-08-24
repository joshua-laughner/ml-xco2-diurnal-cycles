function [quart_hour_av_xco2, tossers, acceptable_daynames, quart_hour_hours,hourly_drawdowns] = calc_hourly_drawdowns(location_struct)

days = length(location_struct.xco2(1,:));
quart_hour_av_xco2 = nan(days,7);
quart_hour_hours = nan(days,7);
for day = 1:days
solar_min = location_struct.solar_min(day);
steps = solar_min - 3:1:solar_min+3;
quart_hour_hours(day,:) = steps;
step_size = length(steps);

    for i = 1:step_size
    %finding the values within half an hour of each point and averaging
    %them together
        timeind = find(abs(location_struct.hours(:,day) - steps(i)) < .25); %used to be .25, if makes worse get rid of it and revert. 
        if isempty(timeind)
            continue
        end
        quart_hour_av_xco2(day, i) = mean(location_struct.xco2(timeind, day),'omitnan');


    end
end
acceptable_day = [];
for day = 1:days
    nanind = find(isnan(quart_hour_av_xco2(day,:))); %furious with my past self for this whole section,,,
    % why couldn't i just have written normal code? 
   % dayspacing = nanind(2:end) - nanind(1:length(nanind)-1);
    if ~isempty(nanind)% (~isempty(find(dayspacing >2)) || nanind(1) > 2 || nanind(end) < (step_size -2)) i did all sorts of weird stuff here but I 
        %think if there are any days with no points within the hour i toss
        %it
        acceptable_day(day) = 0; 
        continue
    end
    acceptable_day(day) = 1;
end
tossers = find(acceptable_day == 0);
acceptable_daynames = location_struct.days;
acceptable_daynames(tossers) = [];
quart_hour_av_xco2(tossers, :) = [];
quart_hour_hours(tossers,:) = [];

hourly_drawdowns = quart_hour_av_xco2(:,2:end)-quart_hour_av_xco2(:,1:end-1);

%for day = 1:length(quart_hour_av_xco2(:,1)) i don't need this because I
%don't have anything with nans
 %   nnanind = find(~isnan(quart_hour_av_xco2(day,:)));
  %  quart_hour_av_xco2(day,:) = interp1(steps(nnanind), quart_hour_av_xco2(day,nnanind), steps, 'spline', 'extrap');

%end

end