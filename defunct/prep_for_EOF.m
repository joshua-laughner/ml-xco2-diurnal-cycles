function [quart_hour_av_xco2, tossers, acceptable_daynames, quart_hour_hours] = prep_for_EOF(location_struct)

days = length(location_struct.xco2(1,:));
quart_hour_av_xco2 = nan(days,27);
quart_hour_hours = nan(days,27);
for day = 1:days
    
solar_min = location_struct.solar_min(day);
%this section here detrends our data!
near_sn = find(abs(location_struct.hours(:,day) - solar_min)<0.5 );
xco2_at_noon = mean(location_struct.xco2(near_sn,day));
location_struct.xco2(:,day) = location_struct.xco2(:,day) - xco2_at_noon;

steps = solar_min - 3.25:0.25:solar_min+3.25;
quart_hour_hours(day,:) = steps;
step_size = length(steps);

    for i = 1:step_size
    
        timeind = find(abs(location_struct.hours(:,day) - steps(i)) < .5); %used to be .25, if makes worse get rid of it and revert. 
        if isempty(timeind)
            continue
        end
        if length(timeind)<5 % lets see what happens but I do think I'd like there to be some averaging going on -- lest one point drive things weird

            continue
        end
        quart_hour_av_xco2(day, i) = mean(location_struct.xco2(timeind, day),'omitnan');


    end
end
acceptable_day = [];
for day = 1:days
    nanind = find(~isnan(quart_hour_av_xco2(day,:)));
    %nanind
    if isempty(nanind)
        acceptable_day(day) = 0;
        continue
    end
    dayspacing = nanind(2:end) - nanind(1:length(nanind)-1);
    if (~isempty(find(dayspacing >1)) || nanind(1) > 1 || nanind(end) < (step_size))
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

for day = 1:length(quart_hour_av_xco2(:,1))
    nnanind = find(~isnan(quart_hour_av_xco2(day,:)));
    quart_hour_av_xco2(day,:) = interp1(steps(nnanind), quart_hour_av_xco2(day,nnanind), steps, 'spline', 'extrap');

end

end