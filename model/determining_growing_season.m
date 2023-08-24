addpath C:\Users\cmarchet\Box\JPL\Processed_Data\

load Daily_Struct_Nic.mat

min_temps = min(Daily_Struct_Nic.temp,[],1,'omitnan');
months = month(Daily_Struct_Nic.days);

for i = 1:12
monthind = find(months == i);
temp_clim(i) = nanmean(min_temps(monthind));
end
figure(1)
 plot(1:12,temp_clim)
 title('Nic')