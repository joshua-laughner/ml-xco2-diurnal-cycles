function [quart_hour_av_xco2, tossers, acceptable_daynames, quart_hour_hours] = prep_for_weekly_EOF_2(location_struct)
%% redone so the days are done first and the weeks are grouped -- ensures we're averaging together good days
days = length(location_struct.xco2(1,:));
quart_hour_av_xco2 = nan(days,27);
quart_hour_hours = nan(days,27);
points_per_day = zeros(days,27);
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
        if length(timeind)<2 % lets see what happens but I do think I'd like there to be some averaging going on -- lest one point drive things weird

            continue
        end
        quart_hour_av_xco2(day, i) = mean(location_struct.xco2(timeind, day),'omitnan');
        points_per_day(day,i) = length(timeind);

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

unq_weeks = groupby_commonweek(acceptable_daynames);
weeks = unq_weeks(end);

quart_hour_av_xco2_2 = nan(weeks,27);
quart_hour_hours_2 = nan(weeks,27);

for i = 1:weeks
    week_ind = find(unq_weeks == i);
    week_section = quart_hour_av_xco2(week_ind,:);
    hours_section = quart_hour_hours(week_ind,:);
    weights_section = points_per_day(week_ind,:);
    week_weighted = week_section.*weights_section;
    hours_weighted = hours_section.*weights_section;
    quart_hour_av_xco2_2(i,:) = nanmean(week_weighted,1)./nansum(weights_section,1);
    quart_hour_hours_2(i,:) = nanmean(hours_weighted,1)./nansum(weights_section,1);
end
for day = 1:length(quart_hour_av_xco2_2(:,1))
    nnanind = find(~isnan(quart_hour_av_xco2_2(day,:)));
    quart_hour_av_xco2_2(day,:) = interp1(steps(nnanind), quart_hour_av_xco2_2(day,nnanind), steps, 'spline', 'extrap');
end



end