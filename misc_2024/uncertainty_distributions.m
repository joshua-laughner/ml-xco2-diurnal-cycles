%% uncertainty distributions
addpath C:\Users\cmarchet\Documents\ML_Code\Processed_Data
load Lite_Struct_uncertainty.mat

figure(1)
clf
histogram([Lite_Struct.OCO3_uncertainty])
hold on
histogram([Lite_Struct.OCO2_uncertainty])
legend('OCO3','OCO2')
xlabel('XCO2 uncertainty')
xlim([0 2])
title('XCO2 uncertainty -- all crossings')
%%
figure(2)
clf
OCO2_unc = [Lite_Struct.OCO2_uncertainty];
OCO3_unc = [Lite_Struct.OCO3_uncertainty];
months = month(datetime([Lite_Struct.OCO2_time],'ConvertFrom','epochtime'));
%scatter(months,[Lite_Struct.OCO2_uncertainty])
for i = 1:12
    month_ind = find(months == i);
    moco2_u(i) = mean(OCO2_unc(month_ind));
    moco3_u(i) = mean(OCO3_unc(month_ind));
    moco2_sd(i) = std(OCO2_unc(month_ind));
    moco3_sd(i) = std(OCO3_unc(month_ind));
end

%errorbar(1:12,moco2_u,moco2_sd,"o",'Color','blue')
hold on
errorbar(1:12,moco3_u,moco3_sd,"o",'Color','red')
title('OCO3 uncertainty by month')
xlabel('month')
%%
figure(3)
clf
[sorted,index] = sort([Lite_Struct.OCO2_longitude]);
aa = movmean(OCO2_unc(index),1000);
plot(sorted,aa)
hold on
[sortedd,indexx] = sort([Lite_Struct.OCO3_longitude]);
aaa = movmean(OCO3_unc(indexx),1000);
plot(sortedd,aaa)
%scatter([Lite_Struct.OCO2_latitude],OCO2_unc)
legend('OCO2','OCO3')
ylabel('XCO2 uncertainty')
xlabel('longitude')
%%
Longitudes = [-90.273, -104.98, 168.684,-97.486,-16.4991,33.381,150.879]; %the coordinates of the TCCON sites in order of the names listed
Latitudes = [45.945,54.35,-45.038,36.604,28.309,35.141,-34.406];
site_names = ["Park Falls", "East Trout Lake", "Lauder", "Lamont", "Izana", "Nicosia","Wollongong"];

i = 6;

wgs84 = wgs84Ellipsoid("km");
OCO2_distance = distance(Latitudes(i),Longitudes(i),[Lite_Struct.OCO2_latitude],[Lite_Struct.OCO2_longitude],wgs84);
OCO3_distance = distance(Latitudes(i),Longitudes(i),[Lite_Struct.OCO3_latitude],[Lite_Struct.OCO3_longitude],wgs84);

%we are only interested when the crossing is occuring within 1000 km of the
%site
within_range = find(OCO2_distance<=1000 & OCO3_distance<=1000); %within ~10 degrees of the site
loc_hist = OCO2_unc(within_range);
loc2_hist = OCO3_unc(within_range);

Uncertainty_Struct.Nic.OCO2 = mean(loc_hist);
Uncertainty_Struct.Nic.OCO3 = mean(loc2_hist);
%%
figure(4)
clf
histogram(loc_hist)
hold on
histogram(loc2_hist)
legend('OCO2','OCO3')
title('Nicosia histogram')