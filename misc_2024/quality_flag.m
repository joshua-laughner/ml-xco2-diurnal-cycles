%% making correlation plots with whats a good day. Comparing the good/bad flags for both overall and four hours as well as the (total error)/(total scatter)

A = readmatrix('C:\Users\cmarchet\Box\JPL\ETL_flag.xlsx'); %this is me visually flagging whats good or not but literally based on my criteria
% I can write a script for that 

for number = 1:size(Test_Quart_Hour,1)
time_range = find(Daily_Structs.(fields{skip}).hours(:,number)>=min(Quart_Hour_Hours.(fields{skip})(number,:)) & Daily_Structs.(fields{skip}).hours(:,number)<=max(Quart_Hour_Hours.(fields{skip})(number,:)));
%mean_real = nanmean(Daily_Structs.(fields{skip}).xco2(time_range,number));

goodind = find(~isnan(Daily_Structs.(fields{skip}).xco2(:,number)));
[h,S] = polyfit(Daily_Structs.(fields{skip}).hours(goodind,number),Daily_Structs.(fields{skip}).xco2(goodind,number),5);
[f1,delta] = polyval(h,Daily_Structs.(fields{skip}).hours(goodind,number),S);
[~,delta2] = polyval(h,Quart_Hour_Hours.(fields{skip})(number,:),S);
delta_array(number) = nanmean(delta2);
error_array = abs((Test_Quart_Hour(number,:))-(Predicted_Cycles(number,:)));
month_error(number) = nanmean(error_array);

Quality_Struct.error_over_spread(number) = sum(error_array)./sum(delta);

difference_array = delta2 - error_array;
whole_index = find(difference_array<0);
if ~isempty(whole_index)
Quality_Struct.full_bool(number) = 0;
else
    Quality_Struct.full_bool(number) = 1;
end

half_index = find(difference_array(6:end-6)<0);
if ~isempty(half_index)
    Quality_Struct.half_bool(number) = 0;
else
    Quality_Struct.half_bool(number) = 1;
end
end
%% i want to make histograms and correlation plots of different properties to whether or not the day is good. 
%% day 'goodness' is kind of a boolean, so I don't really know how to go about this

month_array = month(Daily_Structs.ETL.days);
for i = 1:12
    month_index = find(month_array == i);
    month_full = Quality_Struct.full_bool(month_index);
    month_draw = Quality_Struct.half_bool(month_index);
    month_var = delta_array(month_index);
    error_2 = month_error(month_index);

    good_full = find(month_full == 1);
    good_draw = find(month_draw == 1);
   

    var_hist(i) = nanmean(month_var);
    err_hist(i) = nanmean(error_2);
    full_hist(i) = length(good_full)/length(month_full);
    draw_hist(i) = length(good_draw)/length(month_draw);

end
%% figures!! 
figure(1)
h = bar(full_hist);
h(1).FaceColor = [166 189 219]/255;
xticks([1 2 3 4 5 6 7 8 9 10 11 12])
xticklabels({'jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec'})
xtickangle(45)
xlabel('month')
ylabel('percent good')
title('ETL: good full days by month ')

figure(2)
clf
h = bar(draw_hist);
h(1).FaceColor = [158 177 96]/255;
xticks([1 2 3 4 5 6 7 8 9 10 11 12])
xticklabels({'jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec'})
xtickangle(45)
xlabel('month')
ylabel('percent good')
title('ETL: good drawdown by month')


figure(3)
clf
h = histogram(month_array);
h(1).FaceColor = [254 227 145]/255;
xticks([1 2 3 4 5 6 7 8 9 10 11 12])
xticklabels({'jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec'})
xtickangle(45)
xlabel('month')
ylabel('number of observations')
title('ETL days per month')
%%
figure(4)
clf
h = bar(var_hist);
h(1).FaceColor = [236 211 220]/255;
xticks([1 2 3 4 5 6 7 8 9 10 11 12])
xticklabels({'jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec'})
xtickangle(45)
xlabel('month')
ylabel('average standard error')
title('ETL TCCON best fit standard error by month')


figure(5)
clf
h = bar(err_hist);
h(1).FaceColor = [227 190 202]/255;
xticks([1 2 3 4 5 6 7 8 9 10 11 12])
xticklabels({'jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec'})
xtickangle(45)
xlabel('month')
ylabel('average difference between best fit and prediction')
title('ETL mean error between best fit and prediction')
%%
figure(6)
edges = [0.1:0.05:0.9];
histogram(delta_array,edges) %the distribution of how much spread there is in a TCCON day

for i = 1:length(edges)-1
delta_index = find(delta_array>=edges(i) & delta_array<edges(i+1));
full = Quality_Struct.full_bool(delta_index);
draw = Quality_Struct.half_bool(delta_index);

good_full = find(full == 1);
good_draw = find(draw == 1);
  
hist_good(i) = length(good_full)/length(full);
hist_draw(i) = length(good_draw)/length(draw);
end
%%
figure(7)
h = bar(hist_draw);
h(1).FaceColor = [181 84 117]/255;
xticklabels(edges(1:2:end))
xlabel('standard error in TCCON day')
ylabel('percent of drawdown that are good')
title('ETL-- Variance and percent good drawdown')
%% making some figures to look at my days predictions for days of different scatter
[B,I] = sort(Quality_Struct.error_over_spread,'descend');
n = 0;
%%
n = n+1;
number =I(n);
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
 scatter(Subsampled_Struct.(fields{skip}).hours(number,:), Subsampled_Struct.(fields{skip}).detrended_xco2(number,:) - mean_real,20,'filled');
title(['ETL: ' Daily_Structs.(fields{skip}).days(number)], 'fontsize', 12)
%print('-dtiff',['C:\Users\cmarchet\Box\JPL\slides and figures\Lamont_',num2str(number)])
%% want to compare good/ bad to the max range of the quarter hour averaged points
range_arr = [];
clear hist_good
clear hist_draw
for i = 1:size(Test_Quart_Hour,1)
hval = max(Test_Quart_Hour(i,:));
lval = min(Test_Quart_Hour(i,:));
range_arr(i) = hval-lval;

diff_consec = Test_Quart_Hour(i,2:end) - Test_Quart_Hour(i,1:end-1);
max_slope(i) = max(abs(diff_consec));

end

steps = [0 0.03 0.06 0.09 0.1 .12 0.15 0.18 0.7];
for i = 1:length(steps) -1
    delta_index = find(max_slope>=steps(i) & max_slope<steps(i+1));
full = Quality_Struct.full_bool(delta_index);
draw = Quality_Struct.half_bool(delta_index);

good_full = find(full == 1);
good_draw = find(draw == 1);
  
hist_good(i) = length(good_full)/length(full);
hist_draw(i) = length(good_draw)/length(draw);


end

figure(7)
h = bar(hist_good);
h(1).FaceColor = [181 84 117]/255;
%xticklabels({'0-0.2','0.2-0.4','0.4-0.6','0.6-0.8','0.8-1','1-1.5','1.5-3'})
xlabel('max drawdown in TCCON day')
ylabel('percent of drawdown that are good')
title('ETL-- drawdown and percent good drawdown')
%%
steps = [0 0.01 0.02 0.03 0.04 0.06 0.08 .11 0.35];
for i = 1:length(steps) -1
    delta_index = find(Quality_Struct.error_over_spread>=steps(i) & Quality_Struct.error_over_spread<steps(i+1));
full = Quality_Struct.full_bool(delta_index);
draw = Quality_Struct.half_bool(delta_index);

good_full = find(full == 1);
good_draw = find(draw == 1);
  
hist_good(i) = length(good_full)/length(full);
hist_draw(i) = length(good_draw)/length(draw);


end

figure(7)
h = bar(hist_good);
h(1).FaceColor = [181 84 117]/255;
xticklabels({'0-0.01','0.01-0.02','0.02-0.03','0.03-0.04','0.04-0.06','0.06-0.08','0.08-0.11','0.11-0.35'})
xlabel('error over spread')
ylabel('percent of drawdown that are good')
title('ETL-- error and percent good drawdown')
%%
wsp = nanmean(Subsampled_ETL.wind_speed,2);
pres = nanmean(Subsampled_ETL.pressure,2);
temp = nanmean(Subsampled_ETL.temp,2);
histogram(temp)
steps = [0 0.5 1 1.5 2 2.5 3.5 4 5];
for i = 1:length(steps) -1
    delta_index = find(wsp>=steps(i) & wsp<steps(i+1));
full = Quality_Struct.full_bool(delta_index);
draw = Quality_Struct.half_bool(delta_index);

good_full = find(full == 1);
good_draw = find(draw == 1);
  
hist_good(i) = length(good_full)/length(full);
hist_draw(i) = length(good_draw)/length(draw);


end

figure(7)
h = bar(hist_good);
h(1).FaceColor = [181 84 117]/255;
%xticklabels({'0-0.01','0.01-0.02','0.02-0.03','0.03-0.04','0.04-0.06','0.06-0.08','0.08-0.11','0.11-0.35'})
xlabel('error over spread')
ylabel('percent of drawdown that are good')
title('ETL-- error and percent good drawdown')