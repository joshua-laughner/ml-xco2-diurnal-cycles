%% miscellaneous figures for my slides
Longitudes = [-90.273, -104.98, 168.684,-97.486,-16.4991,33.381];
Latitudes = [45.945,54.35,-45.038,36.604,28.309,35.141];

%% slide 1
figure(1)
c = [208 146 167]/255;
geoscatter(Latitudes, Longitudes,125,c, 'filled','pentagram')
geolimits([-10 60],[-120 180])
geobasemap streets-light
title('TCCON Sites Used')

%%
number = randi([1 size(Daily_Struct_ETL.hours,2)]);

figure(2)
scatter(Daily_Struct_ETL.hours(:,number),Daily_Struct_ETL.xco2(:,number),5,[208 146 167]/255,'filled')
xlabel('UTC hour')
ylabel('XCO_2 (ppm)')
title(['East Trout Lake ', Daily_Struct_ETL.days(number)])
%% slide 2 
% figure with my subsampling 
number = 326;%randi([1 size(Subsampled_Struct.ETL.hours,1)]);
figure(1)
Subsampled_Struct.ETL.prior_xco2(number,1)
scatter(Subsampled_Struct.ETL.hours(number,:),Subsampled_Struct.ETL.xco2(number,:),135,[166 189 219]/255,'filled','pentagram')
ylabel('XCO_2 (ppb)')
xlabel('UTC hour')
ylim([408 411.5])
xlim([18.5 25.5])
title(['Subsampled Features Example'])
%% slide 3 -- figure about prepping data for EOFs
figure(2) %51, 304
clf
%number = randi([1 400]);
number = 51;
scatter(Daily_Structs.ETL.hours(:,number),Daily_Structs.ETL.xco2(:,number),5,[227 190 202]/255,'filled');
hold on 
%scatter(Quart_Hour_Hours.ETL(number,:),Quart_Hour_Struct.ETL(number,:),19,[181 81 117]/255,'LineWidth',1)
%scatter(Daily_Structs.ETL.hours(number,:),Daily_Structs.ETL.detrended_xco2(number,:))
%title('Raw TCCON Data')
%legend({'Detrended TCCON Data', 'Quarter Hour Intervals'})
legend('Raw TCCON Data')
%xlabel('UTC hour')
ylabel('XCO_2 (ppm)')

%% EOF figures
figure(1)
plot(1:27,EOFs_Combo(6,:),'Color',[124 53 77]/255,'LineWidth',2)
%xlim([0 27])
xticks(0:4:27)
xticklabels(string([-3.25:1:3.25]))
xtickangle(45)
ylim([-0.5 0.5])
set (gca,'YTickLabel', [])
xlabel('Hours Relative to Solar Noon')
%% okay I wanna make a figure justifying the polynomials
[aa_xco2, aa_toss, aa_daynames, aa_hours] = prep_for_EOF(Daily_Struct_ETL);
[Daily_Struct_ETL] = remove_tossers(Daily_Struct_ETL, aa_toss);

%number = randi([1 355]);
figure(1)
clf
%scatter(Daily_Struct_ETL.hours(:,number),Daily_Struct_ETL.xco2(:,number),5,'filled','MarkerFaceColor',[227 190 202]/255)
%hold on 
goodind = find(~isnan(Daily_Struct_ETL.xco2(:,number)));
[h,S] = polyfit(Daily_Struct_ETL.hours(goodind,number),Daily_Struct_ETL.xco2(goodind,number),5);
[f1,delta] = polyval(h,Daily_Struct_ETL.hours(goodind,number),S);
[f2,~] = polyval(h,aa_hours(number,:),S);
%plot(Daily_Struct_ETL.hours(goodind,number),f1,'Color',[55 82 148]/255,'LineWidth',0.5)
scatter(aa_hours(number,:),f2-mean(f2),'MarkerEdgeColor',[26 30 82]/255,'LineWidth',1)
ylim([-2 2])
%scatter(aa_hours(number,:),aa_xco2(number,:),'MarkerEdgeColor',[26 30 82]/255,'LineWidth',1)
legend({'Detrended at Quarter Hour Intervals'})
xlabel('UTC Hour')
ylabel('XCO_2 (ppm)')