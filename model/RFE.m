%% my RFE script????? Scary!!! 
%really hoping that it doesn't change that much across testing sites

%first! run detrended_process to get the stuff

pyenv
py.importlib.import_module('xgboost');
py.importlib.import_module('sklearn');

Features = Subsampled_Combo;
test_features = Subsampled_Struct.(skip);
actual_points = Quart_Hour_Struct.(skip);



preds = [Features.delta_hours(:,:),Features.delta_solmin(:,:),Features.solzen(:,:),Features.delta_solzen(:,:)./Features.delta_hours(:,:),mean(Features.solzen,2),Features.azim(:,:),Features.delta_azim(:,:)./Features.delta_hours(:,:)...
    ,mean(Features.azim,2),Features.delta_xco2(:,:),(Features.delta_xco2(:,:)./Features.delta_hours(:,:)),Features.temp(:,:),Features.delta_temp(:,:)./Features.delta_hours(:,:), mean(Features.temp,2)...
    ,Features.pressure(:,:),Features.delta_pressure(:,:)./Features.delta_hours(:,:),mean(Features.pressure,2), Features.wind_speed(:,:),Features.delta_wind_speed(:,:)./Features.delta_hours(:,:),mean(Features.wind_speed,2)...
    ,Features.prior_xco2(:,:),mean(Features.prior_xco2,2), Features.airmass(:,:),Features.delta_airmass(:,:)./Features.delta_hours(:,:),mean(Features.airmass,2)...
    ,Features.delta_temp_abs(:,:),Features.delta_temp_reg(:,:),Features.VPD(:,:),mean(Features.VPD,2)];

test_preds = [test_features.delta_hours(:,:),test_features.delta_solmin(:,:),test_features.solzen(:,:),test_features.delta_solzen(:,:)./test_features.delta_hours(:,:),mean(test_features.solzen,2),test_features.azim(:,:),test_features.delta_azim(:,:)./test_features.delta_hours(:,:)...
    ,mean(test_features.azim,2),test_features.delta_xco2(:,:),(test_features.delta_xco2(:,:)./test_features.delta_hours(:,:)),test_features.temp(:,:),test_features.delta_temp(:,:)./test_features.delta_hours(:,:), mean(test_features.temp,2)...
    ,test_features.pressure(:,:),test_features.delta_pressure(:,:)./test_features.delta_hours(:,:),mean(test_features.pressure,2), test_features.wind_speed(:,:),test_features.delta_wind_speed(:,:)./test_features.delta_hours(:,:),mean(test_features.wind_speed,2)...
    ,test_features.prior_xco2(:,:),mean(test_features.prior_xco2,2),test_features.airmass(:,:),test_features.delta_airmass(:,:)./test_features.delta_hours(:,:),mean(test_features.airmass,2)...
    ,test_features.delta_temp_abs(:,:).',test_features.delta_temp_reg(:,:).',test_features.VPD(:,:),mean(test_features.VPD,2)];

fieldnames_2 = {'delta_hours','delta_solmin','solzen1','solzen2','delta_solzen','mean_solzen','azim1','azim2','delta_azim','mean_azim'...
    ,'diff_xco2','delta_xco2','temp1','temp2','delta_temp','mean_temp','pres1','pres2','delta_pres','mean_pres','wsp1','wsp2','delta_wsp','mean_wsp',...
    'prior1','prior2','mean_prior','airmass1','airmass2','delta_airmass','mean_airmass','dtemp_abs','dtemp_reg','VPD1','VPD2','VPD3','VPD4','VPD5','VPD6','VPD7','mean_VPD'};

fieldnames_3 = {'delta_hours','delta_hours2','delta_hours3','delta_solmin','solzen1','solzen2','solzen3','delta_solzen','delta_solzen2','delta_solzen3','mean_solzen','azim1','azim2','azim3','delta_azim','delta_azim2','delta_azim3','mean_azim'...
   ,'delta_xco2','delta_xco22','delta_xco23','temp1','temp2','temp3','delta_temp','delta_temp2','delta_temp3','mean_temp','pres1','pres2','pres3','delta_pres','delta_pres2','delta_pres3','mean_pres','wsp1','wsp2','wsp3','delta_wsp','delta_wsp2','delta_wsp3','mean_wsp',...
    'prior1','prior2','prior3','mean_prior','airmass1','airmass2','airmass3','delta_airmass','delta_airmass2','delta_airmass3','mean_airmass','dtemp_abs','dtemp_reg','VPD1','VPD2','VPD3','VPD4','VPD5','VPD6','VPD7','mean_VPD'};

var_names = fieldnames_2;

least_to_first_vars = {}; 
R2_point_array = [];
R2_draw_array = [];
RMSE_point_array = [];
RMSE_draw_array = [];

num_runs = size(preds,2);
numtimes = 3; %how many times we run the model -- should prob be 50 but we'll make it small at first

for i = 1:num_runs
    if i == num_runs
    preds = cat(2,ones(length(preds),1),preds);
    test_preds = cat(2,ones(length(test_preds),1),test_preds);
    end
    display(['run number ',num2str(i)] )
    [importance_array, stats_struct] = RFE_internal_runmodel(preds,test_preds,PCs_Combo,numtimes,actual_points);
    av_importances_across_runs = nanmean(importance_array,1);
    
    [sort_import, import_index] = sort(av_importances_across_runs);
    least_important_var = var_names{import_index(1)};
    least_to_first_vars{i} = least_important_var;
    R2_point_array(i) = mean(stats_struct.ptp.r2);
    RMSE_point_array(i) = mean(stats_struct.ptp.rmse);
    R2_draw_array(i) = mean(stats_struct.drawdown.r2);
    RMSE_draw_array(i) = mean(stats_struct.drawdown.rmse);

    preds(:,import_index(1)) = [];
    test_preds(:,import_index(1)) = [];
    var_names(import_index(1)) = [];


end

%%
clf

plot(1:41,flip(R2_point_array),'LineWidth',1)
hold on
plot(1:41,flip(R2_draw_array),'LineWidth',1)


xticks(1:41)
xticklabels(flip(least_to_first_vars))
xlim([0 42])
legend('Diurnal R2','Drawdown R2','location','southeast','FontSize',11)