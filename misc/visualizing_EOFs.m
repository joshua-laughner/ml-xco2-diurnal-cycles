% verifying my EOFs

number = randi([0 1171]);
number

figure(1)
clf

scatter(Quart_Hour_Hours_Combo(number,:),Quart_Hour_Av_Combo(number,:),10,'filled')
hold on
scatter(Daily_Struct_Lamont.hours(:,number),Daily_Struct_Lamont.xco2(:,number))

Predicted_Cycles = zeros(1,27);
%Predicted_Cycles = Predicted_Cycles + EOFs_Combo(1,:);
for i = 1:num_eofs-1
Predicted_Cycles = Predicted_Cycles+ EOFs_Combo(i,:).*PCs_Combo(number,i) ;%+ EOFs_Combo(2,:).*PCs_Combo(number,2) + EOFs_Combo(3,:).*PCs_Combo(number,3) + EOFs_Combo(4,:).*PCs_Combo(number,4);

end


plot(Quart_Hour_Hours_Combo(number,:),Predicted_Cycles)

%% gotta look at a particular day 
figure()
clf
hold on
scatter(Daily_Struct_Lamont.hours(:,207),Daily_Struct_Lamont.xco2(:,207))
scatter(Quart_Hour_Hours_Lamont(207,:),Quart_Hour_Av_Lamont(207,:))

%% visualizing my output cycles
%number = randi([1 1111]);
number = 0;
%%
number =randi([1 400]);

number
figure(2)
clf
p(1) = scatter(Quart_Hour_Hours.(fields{skip})(number,:),Test_Quart_Hour(number,:),'MarkerEdgeColor',[208 146 167]/255);
hold on
%Predicted_Cycle = EOFs_Combo(1,:).*PCs_Combo(number,1) + EOFs_Combo(2,:).*PCs_Combo(number,2) + EOFs_Combo(3,:).*PCs_Combo(number,3) + EOFs_Combo(4,:).*PCs_Combo(number,4);
p(2) = scatter(Quart_Hour_Hours.(fields{skip})(number,:),Predicted_Cycles(number,:),'MarkerEdgeColor',[26 30 82]/255);
%p(3) = scatter(Daily_Struct_ETL.hours(:,number),Daily_Struct_ETL.detrended_xco2(:,number),3,'filled');
%corrcoef(Predicted_Cycles(number,:),Test_Quart_Hour(number,:))
%corrcoef(Test_Quart_Hour(number,:),Predicted_Cycles(number,:))
legend([p(2) p(1)],{'predicted','actual'})
L = legend;
L.AutoUpdate = 'off'; 
xlabel('UTC Hour', 'fontsize', 17)
ylabel('XCO2', 'fontsize', 17)
% putting in drawdown values
xLimits = get(gca,'XLim');  % Get the range of the x axis
yLimits = get(gca,'YLim');
text(xLimits(1)+0.25,yLimits(2)-0.07,['actual drawdown: ' num2str(Drawdown_Struct.(fields{skip})(number))])
 text(xLimits(1)+0.25,yLimits(2)-0.13,['predicted drawdown: ', num2str(drawdown_predicted(number))])
 xline(solar_min_array(number)-2,'--k')
 xline(solar_min_array(number)+2,'--k')
title(['ETL: ' Daily_Structs.(fields{skip}).days(number)], 'fontsize', 17)
%print('-dtiff',['C:\Users\cmarchet\Box\JPL\slides and figures\Lamont_',num2str(number)])

%
% this one is going to be the line of best fit with error. 
figure(3)
clf
hold on
time_range = find(Daily_Struct_ETL.hours(:,number)>=min(Quart_Hour_Hours.(fields{skip})(number,:))&Daily_Struct_ETL.hours(:,number)<=max(Quart_Hour_Hours.(fields{skip})(number,:)));
mean_real = nanmean(Daily_Struct_ETL.detrended_xco2(time_range,number));
p(1) = scatter(Quart_Hour_Hours.(fields{skip})(number,:),Test_Quart_Hour(number,:)-mean_real,20,'MarkerFaceColor',[231 188 41]/255,'MarkerEdgeColor','none');

%Predicted_Cycle = EOFs_Combo(1,:).*PCs_Combo(number,1) + EOFs_Combo(2,:).*PCs_Combo(number,2) + EOFs_Combo(3,:).*PCs_Combo(number,3) + EOFs_Combo(4,:).*PCs_Combo(number,4);
p(2) = scatter(Quart_Hour_Hours.(fields{skip})(number,:),Predicted_Cycles(number,:)-mean(Predicted_Cycles(number,:)),'MarkerEdgeColor',[26 30 82]/255,'LineWidth',1);
p(3) = scatter(Daily_Struct_ETL.hours(:,number),Daily_Struct_ETL.detrended_xco2(:,number)-mean_real,5,'filled','MarkerFaceColor',[227 190 202]/255);

goodind = find(~isnan(Daily_Struct_ETL.detrended_xco2(:,number)));
[h,S] = polyfit(Daily_Struct_ETL.hours(goodind,number),Daily_Struct_ETL.detrended_xco2(goodind,number)-mean_real,5);
[f1,delta] = polyval(h,Daily_Struct_ETL.hours(goodind,number),S);
p(4) = plot(Daily_Struct_ETL.hours(goodind,number),f1+delta,'--','Color',[231 188 41]/255,'LineWidth',1);
p(5) = plot(Daily_Struct_ETL.hours(goodind,number),f1-delta,'--','Color',[231 188 41]/255,'LineWidth',1);
%corrcoef(Predicted_Cycles(number,:),Test_Quart_Hour(number,:))
%corrcoef(Test_Quart_Hour(number,:),Predicted_Cycles(number,:))
legend([p(2) p(3) p(1) p(4)],{'predicted','actual','quarter hour av', 'uncertainty'})
L = legend;
L.AutoUpdate = 'off'; 
xlabel('UTC Hour', 'fontsize', 10)
ylabel('\Delta XCO_2 (ppm)', 'fontsize', 10)
% putting in drawdown values
xLimits = get(gca,'XLim');  % Get the range of the x axis
yLimits = get(gca,'YLim');
%text(xLimits(1)+0.25,yLimits(2)-0.07,['actual drawdown: ' num2str(Drawdown_Struct.(fields{skip})(number))])
 %text(xLimits(1)+0.25,yLimits(2)-0.13,['predicted drawdown: ', num2str(drawdown_predicted(number))])
 xline(solar_min_array(number)-2,'--k')
 xline(solar_min_array(number)+2,'--k')
 %scatter(Subsampled_Struct.(fields{skip}).hours(number,:), Subsampled_Struct.(fields{skip}).detrended_xco2(number,:) - mean_real,20,'filled');
title(['ETL: ' Daily_Structs.(fields{skip}).days(number)], 'fontsize', 12)
%print('-dtiff',['C:\Users\cmarchet\Box\JPL\slides and figures\Lamont_',num2str(number)])