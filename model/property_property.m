%this script runs through the first two PCs and tests correlations between
%mean/max/min of the chosen variable

xvar = (Subsampled_Combo.xco2(:,2) + Subsampled_Combo.xco2(:,1))/2;
yvar = (Subsampled_Combo.temp(:,2) + Subsampled_Combo.temp(:,1))/2;
c1 = PCs_Combo(:,1);
c2 = PCs_Combo(:,2);
c3 = Quart_Hour_Av_Combo(:,22) - Quart_Hour_Av_Combo(:,6);

figure(3)
scatter(xvar, yvar,6,c3,'filled')
cb = colorbar(); 
ylabel(cb,'drawdown','Rotation',270)
xlabel('mean xco2')
ylabel('mean temp')



%%
sites = fieldnames(Daily_Structs);
variable = 'pressure'; %change this to the variable I want!!!
mean_var = [];
max_var = [];
min_var = [];
for i = 1:length(sites)
sotm = Daily_Structs.(sites{i});
var_site = sotm.(variable);
for day = 1:size(var_site,2)
    mean_var = cat(1,mean_var,nanmean(var_site(:,day)));
    max_var = cat(1,max_var,nanmax(var_site(:,day)));
    min_var = cat(1,min_var,nanmin(var_site(:,day)));
end
end
%%
figure(1)
clf
x = min_var;
%y = min_var  ;
%y = mean(Subsampled_Combo.VPD,2);
%y = Subsampled_Combo.VPD(:,5);
y = Quart_Hour_Av_Combo(:,22) - Quart_Hour_Av_Combo(:,6);
dscatter(x,y)
xlabel('temp')
ylabel('drawdown')
%xlim([-100 100])
corrcoef(x,y)
%% fun with for loops time
correlation_matrix = nan(27);
for first_time = 2:27
    for second_time = 1:first_time -1 
        first = Quart_Hour_Av_Combo(:,first_time);
        second = Quart_Hour_Av_Combo(:,second_time);

        test_diff = first-second;
        statis = corrcoef(Quart_Hour_Av_Combo(:,22) - Quart_Hour_Av_Combo(:,6),test_diff);
        correlation_matrix(second_time,first_time) = statis(1,2);
    end

end
figure(2)
clf
pcolor(correlation_matrix)
a = colorbar();
ylabel(a,'Correlation Coefficient','Rotation',270,'FontSize',14)
caxis([-1 1])
yticklabels([4*0.25+-3.25,9*0.25-3.25, 14*0.25-3.25 19*0.25-3.25,24*0.25-3.25])
%ylabel('Time of First Obs Relative to SN','FontSize',14)
xticklabels([4*0.25+-3.25,9*0.25-3.25, 14*0.25-3.25 19*0.25-3.25,24*0.25-3.25])
%xlabel('Time of Second Obs Relative to SN','FontSize',14)
%title('Delta XCO2 Versus Actual Drawdown','FontSize',15)
set(gca,'FontSize',17)
 colormap(brewermap([],"RdYlGn"))
print('-dtiff','C:\Users\cmarchet\Documents\ML_Code\figures\validationmeeting\draw_delta')
%% the MLR model 
y = mean(RMSE_array,2);
x1 = std(PC1_array,0,2);
x2 = std(PC2_array,0,2);    % Contains NaN data
X = [ones(size(x1)) x1 x2 x1.*x2];
b = regress(y,X) 
scatter3(x1,x2,y,5,'filled')
hold on
x1fit = min(x1):0.1:max(x1);
x2fit = min(x2):0.1:max(x2);
[X1FIT,X2FIT] = meshgrid(x1fit,x2fit);
YFIT = b(1) + b(2)*X1FIT + b(3)*X2FIT + b(4)*X1FIT.*X2FIT;
mesh(X1FIT,X2FIT,YFIT)

hold off
%%
x1 = ones(size(X,1),1);
X1 = [x1 X];
[~,~,~,~,stats] = regress(y,X1)
%% now i'm looking at how the OCO2/3 times fit into quarter hour averages
OCO2_time = OCO_time_wrt_SN;
OCO3_time = OCO2_time + time_difference/(60*60);
crossing_matrix = nan(39);
OCO2_grid = -3.25:0.25:6.5;
OCO3_grid = -3.25:0.25:6.5;
for x = 1:39
    for y = 1:39
         concatenated = [OCO2_time>=OCO2_grid(x); OCO2_time< OCO2_grid(x+1); OCO3_time>= OCO3_grid(y); OCO3_time < OCO3_grid(y+1)];
        index = find(all(concatenated,1));
         if isempty(index)
            continue
         end
         crossing_matrix(y,x) = length(index);
    end
end

pcolor(crossing_matrix)
colorbar()
yticklabels([4*0.25+-3.25,9*0.25-3.25, 14*0.25-3.25 19*0.25-3.25,24*0.25-3.25,29*0.25-3.25,34*0.25-3.25,39*0.25-3.25])
ylabel('OCO3 hours relative to solar noon')
xticklabels([4*0.25+-3.25,9*0.25-3.25, 14*0.25-3.25 19*0.25-3.25,24*0.25-3.25,29*0.25-3.25,34*0.25-3.25,39*0.25-3.25])
xlabel('OCO2 hours relative to solar noon')
title('Distribution of crossings')
%% looking at the distribution of oco3 self crossings
%% now i'm looking at how the OCO2/3 times fit into quarter hour averages
OCO3a_time = first_time_f;
OCO3b_time = OCO3a_time + time_diff_f;
OCO3a_grid = -7.25:0.5:7.25;
OCO3b_grid = -7.25:0.5:7.25;
crossing_matrix = nan(length(OCO3b_grid),length(OCO3a_grid));
for x = 1:length(OCO3a_grid)-1
    for y = 1:length(OCO3b_grid)-1
         concatenated = [OCO3a_time>=OCO3a_grid(x); OCO3a_time< OCO3a_grid(x+1); OCO3b_time>= OCO3b_grid(y); OCO3b_time < OCO3b_grid(y+1)];
        index = find(all(concatenated,1));
         if isempty(index) || length(index) ==0
            continue
         end
         crossing_matrix(y,x) = length(index);
    end
end
%%
figure(1)
clf
pcolor(crossing_matrix.')
colorbar()
xticks([10,20,30,40,50,60]);
%xticklabels([5*0.25+-7.5,10*0.25-7.5, 15*0.25-7.5 20*0.25-7.5,25*0.25-7.5,30*0.25-7.5,35*0.25-7.5,40*0.25-7.5])
xticklabels([10*0.5-7.5, 20*0.5-7.5,30*0.5-7.5,40*0.5-7.5,50*0.5-7.5,60*0.5-7.5])

ylabel('OCO3a hours relative to solar noon')
%yticklabels([5*0.25+-7.5,10*0.25-7.5, 15*0.25-7.5 20*0.25-7.5,25*0.25-7.5,30*0.25-7.5,35*0.25-7.5,40*0.25-7.5])
yticks([10,20,30,40,50,60]);
yticklabels([10*0.5-7.5, 20*0.5-7.5,30*0.5-7.5,40*0.5-7.5,50*0.5-7.5,60*0.5-7.5])

xlabel('OCO3b hours relative to solar noon')
title('Distribution of crossings')
cmocean('dense')
print('-dtiff','C:\Users\cmarchet\Documents\ML_Code\figures\Paper_Figs\self_cross_loc\times_noncrop')
%%
mask = ~isnan(crossing_matrix.');
hold on
stipple(mask)
%%
x = -3.25:0.25:3.25;
y = -3.25:0.25:3.25;
[X,Y] = meshgrid(x,y);
figure(3)
clf
pcolor(X,Y,correlation_matrix)
colorbar()
caxis([-1 1])
colormap(brewermap([],"RdYlGn"))
%cmocean('delta')
%%
mask = ~isnan(crossing_matrix.');
hold on
stipple(X,Y,mask,'color',0.2*[1 1 1],'density',220,'markersize',4)
%print('-dtiff','C:\Users\cmarchet\Documents\ML_Code\figures\Paper_Figs\correlation\corr3')

mask2 = X> aa.mean-aa.std & X < aa.mean + aa.std &~isnan(correlation_matrix);
stipple(X,Y,mask2,'color',0.95*[1 1 1],'density',160,'markersize',3,'marker','o','linewidth',0.55)
%stipple(X,Y,mask2,'color',0.5*[1 1 1],'density',150,'markersize',4,'marker','_')

mask3 = Y> aa.mean-aa.std & Y< aa.mean + aa.std & ~isnan(correlation_matrix);
stipple(X,Y,mask3,'color',0.95*[1 1 1],'density',160,'markersize',3,'marker','o','linewidth',0.55)
%stipple(X,Y,mask3,'color',0.5*[1 1 1],'density',150,'markersize',4,'marker','|')

%print('-dtiff','C:\Users\cmarchet\Documents\ML_Code\figures\Paper_Figs\correlation\corr3')

