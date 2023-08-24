%% doing something I think won't work
wsp = nanmean(Subsampled_ETL.wind_speed,2);
pres = nanmean(Subsampled_ETL.pressure,2);
temp = nanmean(Subsampled_ETL.temp,2);
air = nanmean(Subsampled_ETL.airmass,2);


fields = [ones(400,1),wsp(:),pres(:),temp(:),air(:),Subsampled_ETL.xco2_error(:,:),Subsampled_ETL.xco2(:,1)];

[~,~,~,~,stats] = regress(Quality_Struct.error_over_spread.',fields)