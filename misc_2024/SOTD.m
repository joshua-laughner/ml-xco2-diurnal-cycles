%my plots for the day
%start with ETL just for visualizing

%% here we're making spaghetti maps
addpath 'C:\Users\cmarchet\Documents\ML Code\xco2-diurnal-cycles-ml\defunct'

[Quart_Hour_Av,tossers,acceptable_daynames,Quart_Hour_Hours]= prep_for_weekly_EOF_2(Daily_Struct_PF);
label_months = month(acceptable_daynames);
for i = 7
month_index = find(label_months == i);
%figure('Visible','off')
figure()

hold on
for ii = 1:length(month_index)
plot(Quart_Hour_Hours(month_index(ii),:),Quart_Hour_Av(month_index(ii),:))
end
name = ['PF ', num2str(i)];
xlabel('UTC Hour')
ylabel('detrended XCO2')
title(name)
ylim([-2 2])
%print('-dtiff',['C:\Users\cmarchet\Documents\ML Code\figures\spaghetti_week\Nic_',num2str(i)])

end
%% Now we're making heat maps of XCO2 by month
location_struct = Daily_Struct_PF;
days = length(location_struct.xco2(1,:));
months = month(Daily_Struct_PF.days);
quart_hour_av_xco2 = nan(days,27);
quart_hour_hours = nan(days,27);
for day = 1:days
    
solar_min = location_struct.solar_min(day);
%this section here detrends our data!
near_sn = find(abs(location_struct.hours(:,day) - solar_min)<0.25 );
xco2_at_noon = mean(location_struct.xco2(near_sn,day));
location_struct.detrended_xco2(:,day) = location_struct.xco2(:,day) - xco2_at_noon;
end

for m = 1:12
month_index = find(months == m);
hours_xarray = location_struct.hours(:,month_index);
xco2_yarray = location_struct.detrended_xco2(:,month_index);

figure('Visible','off')
dscatter(hours_xarray(:),xco2_yarray(:))
title(['PF month ', num2str(m)])
ylim([-2 2])
print('-dtiff',['C:\Users\cmarchet\Documents\ML Code\figures\heatmaps\PF_',num2str(m)])
end
%% want to find a well sampled month
hoi = Daily_Struct_PF.hours(:,1312:1344);
xco2oi = Daily_Struct_PF.xco2(:,1312:1344);
solnoon = Daily_Struct_PF.solar_min(1312:1344);
%%
%detrend the data I have
for i = 1:size(hoi,2)
solar_min = solnoon(i);
%this section here detrends our data!
near_sn = find(abs(hoi(:,i) - solar_min)<0.75 );
if ~(isempty(near_sn))
xco2_at_noon = mean(xco2oi(near_sn,i));
xco2oi(:,i) = xco2oi(:,i) - xco2_at_noon;
else
 
    hoi(:,i) = [];
    xco2oi(:,i) = [];
    solnoon(i) = [];
    i = i-1;
    continue
end

end
%%
hoii = hoi(:);
hoii = rmmissing(hoii);
xco2oii = xco2oi(:);
xco2oii = rmmissing(xco2oii);
[B,I] = sort(hoii);
%figure()
%scatter(B,xco2oi(I))

xco2_sort = xco2oii(I);
times = 12:0.25:24.25;
for i = 1:length(times)
time_index = find(abs(B-times(i))<0.5);
july_av(i) = nanmean(xco2_sort(time_index));
end
figure()
clf
scatter(times,july_av,3)
print('-dtiff',['C:\Users\cmarchet\Documents\ML Code\figures\PF_avjuly'])
%%
%now i want to look at averaging together days until the patterns match
%hoi = Daily_Struct_PF.hours(:,1312:1344);
%xco2oi = Daily_Struct_PF.xco2(:,1312:1344);
% gotta get the colors first
dates = Daily_Struct_PF.days(1312:1344);
solarmins = Daily_Struct_PF.solar_min(1312:1344);
temp_at_solmin = nan(1,length(dates));
diff_across_day = nan(1,length(dates));
for j = 1:length(dates) 
tempday = extract_temp_700hpa('park_falls.nc', dates(j));
solar_min = solarmins(j);
near_sn = find(abs(hoi(:,j) - solar_min)<0.75 );

temp_at_solmin(j) = nanmean(tempday(near_sn));
diff_across_day(j) = abs(tempday(1)-tempday(end));
end

%okay so now I have my arrays, and now I need to translate that into some
%color. I need to make an array ranging from 0 - 1 with the value I'll
%multiply to get my greyscale rep. 
%%
bool_solmin = (temp_at_solmin-  min(temp_at_solmin))/(max(temp_at_solmin)- min(temp_at_solmin));
bool_dif = (diff_across_day - min(diff_across_day))/(max(diff_across_day) - min(diff_across_day));
%%
count = 0;
hold on
for i = 1:size(hoi,2)
today = rmmissing(hoi(:,i));
dayxco2 = rmmissing(xco2oi(:,i));
starttime = round(4*today(1))/4;
endtime = round(4*today(end))/4;
totd = starttime:0.25:endtime;
today_avv = nan(1,length(totd));
for z = 1:length(totd)
time_index = find(abs(today-totd(z))<0.5);
if ~isempty(time_index)
today_avv(z) = nanmean(dayxco2(time_index));
end
end
goodind = find(~isnan(today_avv));
if diff_across_day(i) < 1.08
    count = count+1;
plot(totd(goodind),today_avv(goodind))
end
end
print('-dtiff',['C:\Users\cmarchet\Documents\ML Code\figures\PF_july_diff'])





%%
%okay now lets play with averaging things together and see how the curves
%change
hold on
for i = 3:3:size(hoi,2)
today = hoi(:,[i,i-1,i-2]);
dayxco2 = xco2oi(:,[i,i-1,i-2]);
today = rmmissing(today(:));
dayxco2 = rmmissing(dayxco2(:));
[B,I] = sort(today);
dayxco2 = dayxco2(I);
today = today(I);
starttime = round(4*today(1))/4;
endtime = round(4*today(end))/4;
totd = starttime:0.25:endtime;
today_avv = nan(1,length(totd));
for z = 1:length(totd)
time_index = find(abs(today-totd(z))<0.5);
if ~isempty(time_index)
today_avv(z) = nanmean(dayxco2(time_index));
end
end
goodind = find(~isnan(today_avv));
plot(totd(goodind),today_avv(goodind))
end
print('-dtiff',['C:\Users\cmarchet\Documents\ML Code\figures\PF_july3'])
