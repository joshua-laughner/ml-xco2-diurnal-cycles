%% doing eof stuff
Park_Falls_quart_hour_av_xco2 = nan(497,28);

for i = 1:28
    steps = 14.75:.25:21.5;
    for day = 1:497
        timeind = find(abs(Park_Falls_Features.hours(:,day) - steps(i)) < .25);
        if isempty(timeind)
            continue
        end
        Park_Falls_quart_hour_av_xco2(day, i) = nanmean(Park_Falls_Features.xco2(timeind, day));
    end
end

%%
acceptable_day = [];
for day = 1:497
    nanind = find(~isnan(Park_Falls_quart_hour_av_xco2(day,:)));
    dayspacing = nanind(2:end) - nanind(1:length(nanind)-1);
    if (~isempty(find(dayspacing >2)) | nanind(1) > 2 | nanind(end) < 26)
        acceptable_day(day) = 0;
        continue
    end
    acceptable_day(day) = 1;
end
%%
[ETL_EOFs, ETL_pc, ETL_expvar] = mycaleof(ETL_quart_hour_av, 5)
[PF_EOFs, PF_pc, PF_expvar] = mycaleof(PF_quart_hour_av, 5)
%%

%%
combo_quart_hour_av = cat(1, ETL_quart_hour_av, PF_quart_hour_av);
[combo_EOFs, combo_pc, combo_expvar] = mycaleof(combo_quart_hour_av, 5)
%%
tossers = find(acceptable_day == 0);
acceptable_daynames = Park_Falls_Features.days;
acceptable_daynames(tossers) = [];
Park_Falls_quart_hour_av_xco2(tossers, :) = [];
%%
for day = 1:299
    nnanind = find(~isnan(Park_Falls_quart_hour_av_xco2(day,:)));
    Park_Falls_quart_hour_av_xco2(day,:) = interp1(steps(nnanind), Park_Falls_quart_hour_av_xco2(day,nnanind), steps, 'spline', 'extrap');

end

%% make sure you get rid of the days in your subsampling that are bad
ETL_subsample_today.xco2(tossers,:)= [];
ETL_subsample_today.azim(tossers,:) = [];
ETL_subsample_today.solzen(tossers,:) = [];
ETL_subsample_today.temp(tossers,:) = [];
ETL_subsample_today.humidity(tossers,:) = [];
%%
PF_subsampled.xco2(tossers,:) = [];
PF_subsampled.azim(tossers,:) = [];
PF_subsampled.solzen(tossers,:) = [];
PF_subsampled.temp(tossers,:) = [];
PF_subsampled.humidity(tossers,:) = [];
%%
Subsampled_Lau.solar_int(Lauder_tossers,:) = [];
Subsampled_Lau.pressure(Lauder_tossers,:) = [];
Subsampled_Lau.wind_dir(Lauder_tossers,:) = [];
Subsampled_Lau.wind_speed(Lauder_tossers,:) = [];
Subsampled_Lau.day(Lauder_tossers,:) = [];
%%
Subsample_Combo_PF.xco2 = cat(1, Subsampled_ETL.xco2, Subsampled_Lamont.xco2, Subsampled_Lau.xco2, Subsampled_Soda.xco2);
Subsample_Combo_PF.pressure = cat(1, Subsampled_ETL.pressure, Subsampled_Lamont.pressure, Subsampled_Lau.pressure, Subsampled_Soda.pressure);
Subsample_Combo_PF.day = cat(1, Subsampled_ETL.day, Subsampled_Lamont.day, Subsampled_Lau.day, Subsampled_Soda.day);
Subsample_Combo_PF.humidity = cat(1, Subsampled_ETL.humidity, Subsampled_Lamont.humidity, Subsampled_Lau.humidity, Subsampled_Soda.humidity);
Subsample_Combo_PF.temp = cat(1, Subsampled_ETL.temp, Subsampled_Lamont.temp, Subsampled_Lau.temp, Subsampled_Soda.temp);
Subsample_Combo_PF.solzen = cat(1, Subsampled_ETL.solzen, Subsampled_Lamont.solzen, Subsampled_Lau.solzen, Subsampled_Soda.solzen);
Subsample_Combo_PF.azim = cat(1, Subsampled_ETL.azim, Subsampled_Lamont.azim, Subsampled_Lau.azim, Subsampled_Soda.azim);

%%
Subsample_Combo_PF.solar_int = cat(1, Subsampled_Lamont.solar_int, Subsampled_Lau.solar_int, Subsampled_ETL.solar_int, Subsampled_Soda.solar_int);
Subsample_Combo_PF.pressure = cat(1, Subsampled_Lamont.pressure, Subsampled_Lau.pressure, Subsampled_ETL.pressure, Subsampled_Soda.pressure);
Subsample_Combo_PF.wind_dir = cat(1, Subsampled_Lamont.wind_dir, Subsampled_Lau.wind_dir, Subsampled_ETL.wind_dir, Subsampled_Soda.wind_dir);
Subsample_Combo_PF.wind_speed = cat(1, Subsampled_Lamont.wind_speed, Subsampled_Lau.wind_dir, Subsampled_ETL.wind_dir, Subsampled_Soda.wind_dir);
Subsample_Combo_PF.day = cat(1, Subsampled_Lamont.day, Subsampled_Lau.day, Subsampled_ETL.day, Subsampled_Soda.day);
%%
figure(5)
clf
num = 70;
scatter(steps, ETL_half_hour_av_xco2(num,:), 5, 'b')
hold on
eof_rec = EOFs(1,:).*pc(1,num) + EOFs(2,:).*pc(2,num) + EOFs(3,:).*pc(3,num) + EOFs(4,:).*pc(4,num);
eof_pred = EOFs(1,:).*p1_oobPred(num) + EOFs(2,:).*p2_oobPred(num) + EOFs(3,:).*p3_oobPred(num) + EOFs(4,:).*p4_oobPred(num);
scatter(steps, eof_rec, 5, 'red' )
scatter(steps, eof_pred,5, 'green')
legend('data', 'eof', 'eof ML prediction')
xlabel('hour in UTC')
ylabel('xco2 anomaly from solar min')
title('first four EOFs, 2018-04-10')