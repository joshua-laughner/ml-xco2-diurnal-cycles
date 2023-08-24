function [quart_hour_av_xco2_2,quart_hour_hours,poly_coeffs] = fit_poly(location_struct)
%% this is so ANNOYING!!!!!!!!!!!!
days = length(location_struct.xco2(1,:));
quart_hour_av_xco2 = nan(days,27);
quart_hour_av_xco2_2 = nan(days,27);
quart_hour_hours = nan(days,27);
poly_coeffs = nan(days,6);
for day = 1:days
solar_min = location_struct.solar_min(day);
steps = solar_min - 3.25:0.25:solar_min+3.25;
quart_hour_hours(day,:) = steps;
step_size = length(steps);

goodind = find(~isnan(location_struct.hours(:,day)));
h = polyfit( location_struct.hours(goodind,day)-location_struct.solar_min(day),location_struct.detrended_xco2(goodind,day),5);
poly_coeffs(day,:) = h;
f1 = polyval(h,-3.25:0.25:3.25);
quart_hour_av_xco2_2(day,:) = f1;
end


end