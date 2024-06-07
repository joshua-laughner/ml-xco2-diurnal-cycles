function [quart_hour_av_xco2, tossers, acceptable_daynames, quart_hour_hours] = prep_for_weekly_EOF(location_struct,min_days)
unq_weeks = groupby_commonweek(location_struct.days);
weeks = unq_weeks(end);
quart_hour_av_xco2 = nan(weeks,27);
quart_hour_hours = nan(weeks,27);
for num = 1:weeks
    week_index = find(unq_weeks == num);
   
solar_min = nanmean(location_struct.solar_min(week_index));

%this section here detrends our data!
near_sn = find(abs(location_struct.hours(:,week_index) - solar_min)<0.5 );
xco2_at_noon = location_struct.xco2(:,week_index);
xco2_at_noon = mean(xco2_at_noon(near_sn));
location_struct.xco2(:,week_index) = location_struct.xco2(:,week_index) - xco2_at_noon;

steps = solar_min - 3.25:0.25:solar_min+3.25;
quart_hour_hours(num,:) = steps;
step_size = length(steps);

    for i = 1:step_size
    
        timeind = find(abs(location_struct.hours(:,week_index) - steps(i)) < .5); %used to be .25, if makes worse get rid of it and revert. 
        if isempty(timeind)
            continue
        end
        if length(timeind)<5 % lets see what happens but I do think I'd like there to be some averaging going on -- lest one point drive things weird

            continue
        end
        placeholder = location_struct.xco2(:,week_index);
        quart_hour_av_xco2(num, i) = mean(placeholder(timeind),'omitnan');


    end
end
acceptable_day = [];
for day = 1: weeks
    week_index = find(unq_weeks == day);
    acceptable_daynames(day) = location_struct.days(week_index(1));
    if length(week_index)< min_days
        acceptable_day(day) = 0;
        continue
    end
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
acceptable_daynames(tossers) = [];
quart_hour_av_xco2(tossers, :) = [];
quart_hour_hours(tossers,:) = [];

for day = 1:length(quart_hour_av_xco2(:,1))
    nnanind = find(~isnan(quart_hour_av_xco2(day,:)));
    quart_hour_av_xco2(day,:) = interp1(steps(nnanind), quart_hour_av_xco2(day,nnanind), steps, 'spline', 'extrap');

end

end