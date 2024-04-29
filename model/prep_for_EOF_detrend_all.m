function [big_quart_hour_av_xco2, big_quart_hour_hours,big_location_struct] = prep_for_EOF_detrend_all(big_location_struct,badmonths_struct)

locations = fieldnames(big_location_struct);
load Delta_Temp_Struct.mat

for loc = 1:length(locations)
    location_struct = big_location_struct.(locations{loc});

    days = length(location_struct.xco2(1,:));
    quart_hour_av_xco2 = nan(days,27); %27 because of 6.5 hours centered around solar noon, quarter hour interals
    quart_hour_hours = nan(days,27);

    for day = 1:days
    solar_min = location_struct.solar_min(day);
    %this section here detrends our data!
    near_sn = find(abs(location_struct.hours(:,day) - solar_min)<0.5 );
    xco2_at_noon = mean(location_struct.xco2(near_sn,day));
    location_struct.xco2(:,day) = location_struct.xco2(:,day) - xco2_at_noon;

    steps = solar_min - 3.25:0.25:solar_min+3.25; % the time intervals
    quart_hour_hours(day,:) = steps; %recording the UTC times
    step_size = length(steps);

    for i = 1:step_size
    % this section is the direct quarter hour averaging
        timeind = find(abs(location_struct.hours(:,day) - steps(i)) < .5); 
        if isempty(timeind)
            continue
        end
        if length(timeind)<2 
            continue
        end
        quart_hour_av_xco2(day, i) = mean(location_struct.xco2(timeind, day),'omitnan');


    end

    end

years = year(location_struct.days);
months = month(location_struct.days);
acceptable_day = [];
for day = 1:days
    nanind = find(~isnan(quart_hour_av_xco2(day,:)));

    if isempty(nanind)
        acceptable_day(day) = 0;
        continue
    end
    dayspacing = nanind(2:end) - nanind(1:length(nanind)-1);
    if (~isempty(find(dayspacing >2)) || nanind(1) > 1 || nanind(end) < (step_size)) %don't want big gaps or too much extrapolation
        acceptable_day(day) = 0;
        continue
    end

    if years(day) < 2009 %get rid of anything pre 2009 because GEOS starts in 2009
   acceptable_day(day) = 0;
   continue
    end

    if badmonths_struct.(locations{loc})(day) == 0 %flagging for not growing season, the cutoffs are given
    acceptable_day(day) = 0;
    continue
    end
    acceptable_day(day) = 1;


end
tossers = find(acceptable_day == 0); %getting rid of days where the day isn't good
quart_hour_hours(tossers,:) = [];
quart_hour_av_xco2(tossers,:) = [];

for day = 1:length(quart_hour_av_xco2(:,1))
    nnanind = find(~isnan(quart_hour_av_xco2(day,:)));
    quart_hour_av_xco2(day,:) = interp1(steps(nnanind), quart_hour_av_xco2(day,nnanind), steps, 'spline', 'extrap');

end

location_struct.delta_reg = Delta_Temp_Struct.(locations{loc}).reg.';
location_struct.delta_abs = Delta_Temp_Struct.(locations{loc}).abs.';
location_struct = remove_tossers(location_struct, tossers);


big_location_struct.(locations{loc}) = location_struct;
big_quart_hour_av_xco2.(locations{loc}) = quart_hour_av_xco2;
big_quart_hour_hours.(locations{loc}) = quart_hour_hours;

end
end