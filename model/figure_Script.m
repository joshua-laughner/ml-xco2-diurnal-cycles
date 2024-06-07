%% figures
load 3pts_PTPR2.mat
figure(1)
clf
%PTP_RMSE(isnan(PTP_R2)) = 0;
h = imagesc(PTP_R2(1:8,:))
%grid on
%title('Point to Point R2')
colorbar()
%caxis([0.575 0.86])
%start_times = -4:0.25:-2;
%spacing = 1.75:0.25:3.5;

%start_times = -5:0.25:-3;
%spacing = 0.75:0.25:2.75;
yticks([1,2,3,4,5,6,7,8,9])
set(gca,'YDir','normal');
yticks([1 3 5 7])
yticklabels({'1.75','2.25','2.75','3.25','3.5'})
%ylabel('spacing between points')
xticks([1,3,5,7,9])
xticklabels({'-4','-3.5','-3','-2.5','-2'})
%xlabel('start time')
%cmocean('-algae')
%colormap('summer')
 colormap(brewermap([],"YlOrRd"))
caxis([0.47 0.72])
%set(h, 'AlphaData', 1-isnan(PTP_R2(:,1:7)))
set(gca,'FontSize',17)
print('-dtiff','C:\Users\cmarchet\Documents\ML_Code\figures\Paper_Figs\starttime_spacing\3pts_ptp_bigfont')
%%
%% figures
load 3pts_DrawR2.mat
figure(1)
clf
%PTP_RMSE(isnan(PTP_R2)) = 0;
h = imagesc(Draw_R2(1:8,:))
%grid on
%title('Point to Point R2')
colorbar()
%caxis([0.575 0.86])
%start_times = -4:0.25:-2;
%spacing = 1.75:0.25:3.5;

start_times = -5:0.25:-3;
spacing = 0.75:0.25:2.75;
yticks([1,2,3,4,5,6,7,8,9])
set(gca,'YDir','normal');
%yticklabels({'0.75','1','1.25','1.5','1.75','2','2.25','2.5','2.75','3','3.25','3.5'})
%ylabel('spacing between points')
%xticks([1,2,3,4,5,6,7,8,9])
%xticklabels({'-5','-4.75','-4.5','-4.25','-4','-3.75','-3.5','-3.25','-3','-2.75','-2.5','-2.25','-2'})
%xlabel('start time')
%cmocean('-algae')
%colormap('summer')
yticks([1 3 5 7])
yticklabels({'1.75','2.25','2.75','3.25','3.5'})
%ylabel('spacing between points')
xticks([1,3,5,7,9])
xticklabels({'-4','-3.5','-3','-2.5','-2'})
  colormap(brewermap([],"YlOrBr"))
caxis([0.38 0.86])
%set(h, 'AlphaData', 1-isnan(PTP_R2(:,1:7)))
set(gca,'FontSize',17)
print('-dtiff','C:\Users\cmarchet\Documents\ML_Code\figures\Paper_Figs\starttime_spacing\3pts_draw_bigfont')
%%
load 3pts_DrawR2.mat
figure(2)
clf
%PTP_RMSE(isnan(PTP_R2)) = 0;
h = imagesc(Draw_R2(1:8,:))
%grid on
%title('Drawdown R2')
colorbar()
%caxis([0.575 0.86])
start_times = -4:0.25:-2;
spacing = 1.75:0.25:3.5;
yticks([1,2,3,4,5,6,7,8,9])
set(gca,'YDir','normal');
yticklabels({'1.75','2','2.25','2.5','2.75','3','3.25','3.5'})
%ylabel('spacing between points')
xticks([1,2,3,4,5,6,7,8,9])
xticklabels({'-4','-3.75','-3.5','-3.25','-3','-2.75','-2.5','-2.25','-2'})
%xlabel('start time')
%cmocean('-algae')
%colormap('summer')
 colormap(brewermap([],"YlOrBr"))
caxis([0.51 0.84])
%set(h, 'AlphaData', 1-isnan(PTP_R2(:,1:7)))
set(gca,'FontSize',11)
print('-dtiff','C:\Users\cmarchet\Documents\ML_Code\figures\Paper_Figs\starttime_spacing\3pts_draw')
%%
load PTP_R2.mat
figure(3)
clf
%PTP_RMSE(isnan(PTP_R2)) = 0;
h = imagesc(PTP_R2(1:8,:))
%grid on
%title('Point to Point R2')
colorbar()
%caxis([0.575 0.86])
start_times = -2.5:0.25:-0.5;
spacing = 2.75:0.25:4.5;
yticks([1,2,3,4,5,6,7,8,9])
set(gca,'YDir','normal');
yticks([1,3,5,7])
yticklabels({'2.75','3.25','3.75','4.25','4.5'})
%ylabel('spacing between points')
xticks([1,2,3,4,5,6,7,8,9])
xticklabels({'-2.5','-2.25','-2','-1.75','-1.5','-1.25','-1','-0.75','-0.5'})
%xlabel('start time')
%cmocean('-algae')
%colormap('summer')
 colormap(brewermap([],"YlOrRd"))
%caxis([0.40 0.57])
%caxis([0.47 0.72])
%set(h, 'AlphaData', 1-isnan(PTP_R2(:,1:7)))
set(gca,'FontSize',17)
print('-dtiff','C:\Users\cmarchet\Documents\ML_Code\figures\Paper_Figs\starttime_spacing\2pts_ptp_bigfont')
%%
load 2pts_DrawR2.mat
figure(4)
clf
%PTP_RMSE(isnan(PTP_R2)) = 0;
h = imagesc(Draw_R2(1:8,:))
%grid on
%title('Point to Point R2')
colorbar()
%caxis([0.575 0.86])
start_times = -2.5:0.25:-0.5;
spacing = 2.75:0.25:4.5;
yticks([1,3,5,7,9])
set(gca,'YDir','normal');
yticklabels({'2.75','3.25','3.75','4.25',})
%ylabel('spacing between points')
xticks([1,3,5,7,9])
xticklabels({'-2.5','-2','-1.5','-1','-0.5'})
%xlabel('start time')
%cmocean('-algae')
%colormap('summer')
 colormap(brewermap([],"YlOrBr"))
%caxis([0.40 0.57])
caxis([0.38 0.86])
%set(h, 'AlphaData', 1-isnan(PTP_R2(:,1:7)))
set(gca,'FontSize',17)
print('-dtiff','C:\Users\cmarchet\Documents\ML_Code\figures\Paper_Figs\starttime_spacing\2pts_draw_bigfont')
%%
%I want to make a good figure showing PCs and how they combine to
%reconstruct my days
%i =randi([1 1292])
i = 457
for j = 1:6
h6 = figure(j);
clf
scatter(Quart_Hour_Hours_Combo(i,:),Quart_Hour_Av_Combo(i,:),50, [0.5 0.5 0.5],'LineWidth',0.9)
hold on 
PCs_day = PCs_Combo(i,:)
day_rec = zeros(1,27);
for z = 1:j
day_rec = day_rec + PCs_day(z)*EOFs_Combo(z,:);% + PCs_day(2)*EOFs_Combo(2,:) + PCs_day(3)*EOFs_Combo(3,:)+ PCs_day(4)*EOFs_Combo(4,:) + PCs_day(5)*EOFs_Combo(5,:)...
%  + PCs_day(6)*EOFs_Combo(6,:);% + PCs_day(7) * EOFs_Combo(7,:);
end
scatter(Quart_Hour_Hours_Combo(i,:),day_rec,75,'k','*','LineWidth',0.9)
legend('TCCON data',['First ',num2str(j),' EOFs--',num2str(round(sum(Expvar_Combo(1:j)))),'% Exp. Var.'],'FontSize',11)
set(h6, 'Units', 'normalized');
set(h6, 'Position', [0.1, .55, .4, .50]);
ylim([-1 0.3])
print('-dtiff',['C:\Users\cmarchet\Documents\ML_Code\figures\Paper_Figs\PC_fig\type2_EOF',num2str(j)])
end

%%
for i = 1:6
    h6 = figure(i);
    clf
    plot(1:27,-1*EOFs_Combo(i,:),'LineWidth',1,'Color','black')
    ylim([-0.4 0.4])
    set(gca,'XTick',[])
    set(gca,'YTick',[])
    set(h6, 'Units', 'normalized');
set(h6, 'Position', [0.1, .55, .15, .2]);
 %   print('-dtiff',['C:\Users\cmarchet\Documents\ML_Code\figures\Paper_Figs\PC_fig\plotEOF_',num2str(i)])

end
%% figure about the OCO-2/3 crossing distributions
 Longitudes = [-90.273, -104.98, 168.684,-97.486,-16.4991,33.381,150.879]; %the coordinates of the TCCON sites in order of the names listed
Latitudes = [45.945,54.35,-45.038,36.604,28.309,35.141,-34.406];

Colors = {[0 0.4470 0.7410],[0.8500 0.3250 0.0980],[0.9290 0.6940 0.1250],[0.4940 0.1840 0.5560],[0.4660 0.6740 0.1880],[0.6350 0.0780 0.1840]};
Linestyles = {'-','-.','--',':','-','-.'};
%h(6) = figure(2);
clf
hold on
all_oco2 = [];
oco3_time = [];
for i = 1:6
[~,a,~,~,~] = fit_prob_dist(Latitudes(i),Longitudes(i),'fig',0,'site_num',i);
x_values = 0:0.01:3;
%all_oco2 = cat(2,all_oco2,b);
%oco3_time= cat(2,oco3_time,e);
y = pdf(a,x_values);
plot(x_values,y,'LineWidth',1,'Color',Colors{i})
end
%pd_OCO2 = fitdist(all_oco2.','burr');
%pd_diff = fitdist(oco3_time.','kernel');
legend("PF","ETL","Lau","Lam","Iza","Nic"')
%set(h6, 'Units', 'normalized');
%set(h6, 'Position', [0.1, .55, .4, .50]);
set(gca,'FontSize',17)
print('-dtiff','C:\Users\cmarchet\Documents\ML_Code\figures\Paper_Figs\crossing_distributions\oco2-3_diff_big')
%%
pd_OCO2 = fitdist(all_oco2.','burr');
pd_diff = fitdist((oco3_time).','kernel');
h = figure(4)
%set(gca,'xdir','reverse')
clf
yyaxis left
set(gca,'YColor','k')

x_values = -8:.01:6;
y = pdf(pd_OCO2,x_values);
plot(x_values,y,'LineWidth',1.25,'Color',[239 135 78]/255)
yyaxis right
set(gca,'xdir','reverse','ydir','reverse')
y = pdf(pd_diff,x_values);
plot(x_values,y,'LineWidth',1.25,'Color',[151 211 104]/255)
set(gca,'YColor','k')
ylim([0 0.4])
xlim([-3.25 3.25])
legend('OCO2 Time PDF','OCO3 Time PDF')
%%
img=imread('test.tif');
img_flip = flip(img);
imshow(img_flip)
%%
figure(2);
clf
hold on
for i = 1:6
[~,a,~,~] = fit_prob_dist(Latitudes(i),Longitudes(i),'fig',0,'site_num',i);
x_values = -10:0.01:10;
y = pdf(a,x_values);
plot(x_values,y,'LineWidth',1,'Color',Colors{i})
end
legend("PF","ETL","Lau","Lam","Iza","Nic"')
%set(g5, 'Units', 'normalized');
%set(g5, 'Position', [0.1, .55, .4, .50]);
set(gca,'FontSize',17)
print('-dtiff','C:\Users\cmarchet\Documents\ML_Code\figures\Paper_Figs\crossing_distributions\oco2-3_diff')
%%
figure(2)
clf
y = [All_Run.ETL.inbag_draw All_Run.ETL.oob_draw All_Run.ETL.val_draw; All_Run.PF.inbag_draw All_Run.PF.oob_draw...
    All_Run.PF.val_draw; All_Run.Lau.inbag_draw All_Run.Lau.oob_draw All_Run.Lau.val_draw; All_Run.Lam.inbag_draw All_Run.Lam.oob_draw All_Run.Lam.val_draw];
%b = bar({'ETL','PF','Lauder','Lamont'},y);
b = bar(y);
b(1).FaceColor = 'none';
b(1).EdgeColor = [87 31 35]/255;
b(1).LineWidth = 0.9;
b(2).FaceColor = 'none';
b(2).EdgeColor = [138 29 99]/255;
b(3).FaceColor = 'none';
b(2).LineWidth = 0.9;
b(3).EdgeColor = [166 141 207]/255;
b(3).LineWidth = 0.9;
hatchfill2(b(1),'cross','HatchAngle',45,'HatchDensity',100,'HatchLineWidth',0.7,'hatchcolor',[87 31 35]/255);
hatchfill2(b(2),'cross','HatchAngle',45,'HatchDensity',100,'HatchLineWidth',0.7,'hatchcolor',[138 29 99]/255);
hatchfill2(b(3),'cross','HatchAngle',45,'HatchDensity',100,'HatchLineWidth',0.7,'hatchcolor',[166 141 207]/255);

%print('-dtiff','C:\Users\cmarchet\Documents\ML_Code\figures\Paper_Figs\27_pt_othersites\All_Sites_drawdown')
%%
figure(2)
clf
y = [All_Run.ETL.inbag_ptp All_Run.ETL.oob_ptp All_Run.ETL.val_ptp; All_Run.PF.inbag_ptp All_Run.PF.oob_ptp...
    All_Run.PF.val_ptp; All_Run.Lau.inbag_ptp All_Run.Lau.oob_ptp All_Run.Lau.val_ptp; All_Run.Lam.inbag_ptp All_Run.Lam.oob_ptp All_Run.Lam.val_ptp];
b = bar(y);
%b = bar(y);
b(1).FaceColor = [87 31 35]/255;
b(1).LineWidth= 0.8;
b(2).FaceColor = [138 29 99]/255;
b(2).LineWidth= 0.8;
b(3).FaceColor = [166 141 207]/255;
b(3).LineWidth= 0.8;
legend('InBag','OOB','Validation','location','southwest')
print('-dtiff','C:\Users\cmarchet\Documents\ML_Code\figures\Paper_Figs\27_pt_othersites\All_Sites_ptp')
%% here is our randomness figures 
addpath C:\Users\cmarchet\Documents\ML_Code\Processed_Data\random_sims
load idealptp_3ptsPTP_R2

figure(1)
clf
%PTP_RMSE(isnan(PTP_R2)) = 0;
h = imagesc(PTP_R2(:,:))
%grid on
%title('Point to Point R2')
colorbar()
%caxis([0.575 0.86])
randomness = [0,0.1,0.2,0.5,1,1.5,2,3];
randomness_sp = [0,0.1,0.2,0.5,1,1.5,2,3];
%yticks([1,2,3,4,5,6,7,8])
set(gca,'YDir','normal');
%yticklabels({'0','0.1','0.2','0.5','1','1.5','2','3'})
%ylabel('spacing between points')
%xticks([1,2,3,4,5,6,7,8,9])
%xticklabels({'0','0.1','0.2','0.5','1','1.5','2','3'})
%xlabel('start time')
%cmocean('-algae')
xticks([1,3,5,7,8,9])
xticklabels({'0','0.2','1','2'})
yticks([1,3,5,7,8,9])
yticklabels({'0','0.2','1','2'})
%colormap('summer')
 colormap(brewermap([],"RdPu"))
caxis([0.5 0.75])
%set(h, 'AlphaData', 1-isnan(PTP_R2(:,1:7)))
set(gca,'FontSize',17)
print('-dtiff','C:\Users\cmarchet\Documents\ML_Code\figures\Paper_Figs\randomness_tests\3pts_idealptp')
%%
load idealptp_2ptsPTP_R2
figure(2)
clf
%PTP_RMSE(isnan(PTP_R2)) = 0;
h = imagesc(PTP_R2(:,:))
%grid on
%title('Point to Point R2')
colorbar()
%caxis([0.575 0.86])
randomness = [0,0.1,0.2,0.5,1,1.5,2,3];
randomness_sp = [0,0.1,0.2,0.5,1,1.5,2,3];
yticks([1,2,3,4,5,6,7,8])
set(gca,'YDir','normal');
%yticklabels({'0','0.1','0.2','0.5','1','1.5','2','3'})
%ylabel('spacing between points')
%xticks([1,2,3,4,5,6,7,8,9])
%xticklabels({'0','0.1','0.2','0.5','1','1.5','2','3'})
xticks([1,3,5,7,8,9])
xticklabels({'0','0.2','1','2'})
yticks([1,3,5,7,8,9])
yticklabels({'0','0.2','1','2'})
%xlabel('start time')
%cmocean('-algae')
%colormap('summer')
 colormap(brewermap([],"RdPu"))
caxis([0.5 0.9])
%set(h, 'AlphaData', 1-isnan(PTP_R2(:,1:7)))
set(gca,'FontSize',17)
print('-dtiff','C:\Users\cmarchet\Documents\ML_Code\figures\Paper_Figs\randomness_tests\2pts_idealptp')
%%

load idealdraw_2ptsDraw_R2
figure(3)
clf
%PTP_RMSE(isnan(PTP_R2)) = 0;
h = imagesc(Draw_R2(:,:))
%grid on
%title('Point to Point R2')
colorbar()
%caxis([0.575 0.86])
randomness = [0,0.1,0.2,0.5,1,1.5,2,3];
randomness_sp = [0,0.1,0.2,0.5,1,1.5,2,3];
%yticks([1,2,3,4,5,6,7,8])
set(gca,'YDir','normal');
%yticklabels({'0','0.1','0.2','0.5','1','1.5','2','3'})
%ylabel('spacing between points')
%xticks([1,2,3,4,5,6,7,8,9])
%xticklabels({'0','0.1','0.2','0.5','1','1.5','2','3'})
xticks([1,3,5,7,8,9])
xticklabels({'0','0.2','1','2'})
yticks([1,3,5,7,8,9])
yticklabels({'0','0.2','1','2'})
%xlabel('start time')
%cmocean('-algae')
%colormap('summer')
 colormap(brewermap([],"PuRd"))
caxis([0.5 0.9])
%set(h, 'AlphaData', 1-isnan(PTP_R2(:,1:7)))
set(gca,'FontSize',17)
print('-dtiff','C:\Users\cmarchet\Documents\ML_Code\figures\Paper_Figs\randomness_tests\2pts_idealdraw')
%%
load idealdraw_3ptsDraw_R2
figure(4)
clf
%PTP_RMSE(isnan(PTP_R2)) = 0;
h = imagesc(Draw_R2(:,:))
%grid on
%title('Point to Point R2')
colorbar()
%caxis([0.575 0.86])
randomness = [0,0.1,0.2,0.5,1,1.5,2,3];
randomness_sp = [0,0.1,0.2,0.5,1,1.5,2,3];
%yticks([1,2,3,4,5,6,7,8])
set(gca,'YDir','normal');
%yticklabels({'0','0.1','0.2','0.5','1','1.5','2','3'})
%ylabel('spacing between points')
xticks([1,3,5,7,8,9])
xticklabels({'0','0.2','1','2'})
yticks([1,3,5,7,8,9])
yticklabels({'0','0.2','1','2'})
%xlabel('start time')
%cmocean('-algae')
%colormap('summer')
 colormap(brewermap([],"PuRd"))
caxis([0.5 0.9])
%set(h, 'AlphaData', 1-isnan(PTP_R2(:,1:7)))
set(gca,'FontSize',17)
print('-dtiff','C:\Users\cmarchet\Documents\ML_Code\figures\Paper_Figs\randomness_tests\3pts_idealdraw')