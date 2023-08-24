function [ tossers, acceptable_daynames] = first_round_prep(location_struct)
%% this is so ANNOYING!!!!!!!!!!!!
days = length(location_struct.xco2(1,:));
quart_hour_av_xco2 = nan(days,27);
poly_coeffs = nan(days,6);
for day = 1:days
solar_min = location_struct.solar_min(day);
steps = solar_min - 3.25:0.25:solar_min+3.25;
step_size = length(steps);

    for i = 1:step_size
    
        timeind = find(abs(location_struct.hours(:,day) - steps(i)) < .5); %used to be .25, if makes worse get rid of it and revert. 
        if isempty(timeind)
            continue
        end
        if length(timeind)<3 % lets see what happens but I do think I'd like there to be some averaging going on -- lest one point drive things weird

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


end