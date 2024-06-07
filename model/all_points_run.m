%% Test! what happens if we give the model all 27 points? 
clear all

savepath = 'C:\Users\cmarchet\Documents\ML_Code\Processed_Data\'; %change this to your savepath
addpath(savepath)
addpath 'C:\Users\cmarchet\Documents\ML_Code\Data\'

data_setup_for_model() %change this to a function with inputs and outputs
skippednames = {'ETL','PF','Lauder','Lamont'};
for site = 1:4
 bigloop = site
skipbool = 1; % are we leaving a site out for testing? turn off when few sites


skip = skippednames{bigloop}; 
%PLACEHOLDER!
badmonths_struct.ETL = [];
badmonths_struct.PF = [];
badmonths_struct.Lamont = [];
badmonths_struct.Lauder = [];
badmonths_struct.Iza = [];
badmonths_struct.Nic = [];

Daily_Structs = init_sites('all'); %Make sure you call the site names correctly!
%ETL, PF, Lamont, Lauder, Iza, Nic

[Quart_Hour_Struct,Quart_Hour_Hours,Daily_Structs] = prep_for_EOF_detrend_all_variables(Daily_Structs,badmonths_struct,'solzen','azim','temp','prior_xco2','airmass','pressure','wind_speed');

Subsampled_Struct = add_GEOS_all(Quart_Hour_Struct,Daily_Structs);

%using those variables to calculate VPD
Subsampled_Struct = calc_VPD(Subsampled_Struct);

fields = fieldnames(Quart_Hour_Struct); %the site names

Quart_Hour_Av_Combo = [];
Quart_Hour_Hours_Combo = [];
%making a struct of the quart hour avs for EOF generation (want one big
%array), and keeping out the testing set
for v = 1:length(fields)
    if skipbool == 1 && strcmp(fields{v},skip)
        continue
    end
    Quart_Hour_Hours_Combo = cat(1,Quart_Hour_Hours_Combo,Quart_Hour_Hours.(fields{v}));
    Quart_Hour_Av_Combo = cat(1, Quart_Hour_Av_Combo, Quart_Hour_Struct.(fields{v}).xco2);
end

sum_expvar = 0;
num_eofs = 5;
%calculating 6 EOFS based on the combination of TCCON days 
while sum_expvar < 95
    [EOFs_Combo, PCs_Combo, Expvar_Combo] = mycaleof(Quart_Hour_Av_Combo, num_eofs);
    PCs_Combo = PCs_Combo.';
    sum_expvar = sum(Expvar_Combo);
    num_eofs = num_eofs+1;
end

for b = 1:length(fields)
Subsampled_Struct.(fields{b}).delta_temp_abs = Daily_Structs.(fields{b}).delta_abs; % CHANGE THESE!! and calculate deltas. and add in delta SN
Subsampled_Struct.(fields{b}).delta_temp_reg = Daily_Structs.(fields{b}).delta_reg;%
end
features = fieldnames(Subsampled_Struct.(fields{1}));
 for z = 1:length(features)
    Subsampled_Combo.(features{z}) = [];
 end


for b = 1:length(fields) %looping over all sites
    if skipbool == 1 && strcmp(fields{b},skip)
        disp(['skipping',fields{b}] )
        continue
    end
    for z = 1:length(features) %looping over all features
       %each feature is now a combo from all sites 
       
        if z == 31 || z == 32
             Subsampled_Combo.(features{z}) = cat(1, Subsampled_Combo.(features{z}), Subsampled_Struct.(fields{b}).(features{z}).');
            continue
        end
         Subsampled_Combo.(features{z}) = cat(1, Subsampled_Combo.(features{z}), Subsampled_Struct.(fields{b}).(features{z}));

    end
 
end

for b = 1:8
  
    all_differences_array = [];
     all_differences_array2 = [];
        for dpoint = 1:26
            for spoint = 2:27
                 
             all_differences_array = cat(2,all_differences_array, Subsampled_Combo.(features{b})(:,spoint) -  Subsampled_Combo.(features{b})(:,dpoint));
             all_differences_array2 = cat(2,all_differences_array2,Subsampled_Struct.(skip).(features{b})(:,spoint) - Subsampled_Struct.(skip).(features{b})(:,dpoint));
       
            end
        end
        Subsampled_Combo.(['delta_',features{b}]) = all_differences_array;
        Subsampled_Struct.(skip).(['delta_',features{b}]) = all_differences_array2;

end
Subsampled_Combo.hours = Quart_Hour_Hours_Combo;
Subsampled_Combo.delta_hours = Subsampled_Combo.hours(:,2) - Subsampled_Combo.hours(:,1);
Subsampled_Struct.(skip).hours = Quart_Hour_Hours.(skip);
Subsampled_Struct.(skip).delta_hours = Subsampled_Struct.(skip).hours(:,2) - Subsampled_Struct.(skip).hours(:,1);


%hyperparameters for model
ntrees_XGB = [800]; %tuning by r2 onyl 2 oxy
learn_XGB = 0.07;%:.01:0.1; %controls how much weights are adjusted each step
gamma_XGB = [0];%defaultm
ndepth_XGB = [8]; %how complex tree can get, how many levels. adding constraing prevents overfitting
nchild_XGB = [8]; %don't understand this one
nsubsample_XGB = 1; %subsampling. which percent used. we already do traiing testing but this adds just a bit more
lambda_XGB = [2]; %regularization term, makes model more conservative
alpha_XGB = [2]; %regularlization term, makes model more conservative

%running da model
if skipbool == 1
[PC_preds,idrem,MODEL,importance,rem,idx] = xgb_model_detrend(PCs_Combo(:,:),Subsampled_Combo,Subsampled_Struct.(skip),ntrees_XGB,learn_XGB,gamma_XGB,ndepth_XGB,nchild_XGB,nsubsample_XGB,lambda_XGB,alpha_XGB);
Test_Quart_Hour = Quart_Hour_Struct.(skip);
 Test_Quart_Hour_Times = Quart_Hour_Hours.(skip);

 Quart_Hour_Av_Combo(rem,:) = [];
 m = size(Quart_Hour_Av_Combo,1) ;
 P = 0.70 ; 
 InBag_Comp = Quart_Hour_Av_Combo(idx(1:round(P*m)),:);
 OOB_Comp = Quart_Hour_Av_Combo(idx(round(P*m)+1:end),:);

else
    disp('notest')
[PC_preds,MODEL,reportind] = xgb_model_notest(PCs_Combo(:,:),Subsampled_Combo,ntrees_XGB,learn_XGB,gamma_XGB,ndepth_XGB,nchild_XGB,nsubsample_XGB,lambda_XGB,alpha_XGB);
Test_Quart_Hour = Quart_Hour_Av_Combo(reportind,:);
Test_Quart_Hour_Times = Quart_Hour_Hours_Combo(reportind,:);
end
%[PC_preds,MDL,importance] = xgb_model_detrend_tt(PCs_Combo(:,:),Subsampled_Combo,[1:471],ntrees_XGB,learn_XGB,gamma_XGB,ndepth_XGB,nchild_XGB,nsubsample_XGB,lambda_XGB,alpha_XGB);

%the actual data
 %here I'm reconstructing my predicted days from the EOFs and the PCs
 pc_names = fieldnames(PC_preds);
 pc_names(1:10) = [];
 Predicted_Cycles = [];
for number = 1:length(PC_preds.pc_1(1).oobPred)
  Predicted_Cycles(number,:) = zeros(1,27);
 
    for i = 1:num_eofs-1
        %adding each EOF one by one with their weighting to get the output
        %day 
        Predicted_Cycles(number,:) = Predicted_Cycles(number,:)+ EOFs_Combo(i,:).*(PC_preds.(pc_names{i}).oobPred(number));%+ EOFs_Combo(2,:).*PCs_Combo(number,2) + EOFs_Combo(3,:).*PCs_Combo(number,3) + EOFs_Combo(4,:).*PCs_Combo(number,4);

    end
end

OOB_Cycles = [];
for number = 1:length(PC_preds.pc_1(1).oob_train)
  OOB_Cycles(number,:) = zeros(1,27);
 
    for i = 1:num_eofs-1
        %adding each EOF one by one with their weighting to get the output
        %day 
        OOB_Cycles(number,:) = OOB_Cycles(number,:)+ EOFs_Combo(i,:).*(PC_preds.(pc_names{i}).oob_train(number));%+ EOFs_Combo(2,:).*PCs_Combo(number,2) + EOFs_Combo(3,:).*PCs_Combo(number,3) + EOFs_Combo(4,:).*PCs_Combo(number,4);

    end
end

InBag_Cycles=[];
for number = 1:length(PC_preds.pc_1(1).inBagPred)
  InBag_Cycles(number,:) = zeros(1,27);
 
    for i = 1:num_eofs-1
        %adding each EOF one by one with their weighting to get the output
        %day 
        InBag_Cycles(number,:) = InBag_Cycles(number,:)+ EOFs_Combo(i,:).*(PC_preds.(pc_names{i}).inBagPred(number));%+ EOFs_Combo(2,:).*PCs_Combo(number,2) + EOFs_Combo(3,:).*PCs_Combo(number,3) + EOFs_Combo(4,:).*PCs_Combo(number,4);

    end
end

%stacking all the real to predicted day so that I can get the OOB stats for
%the site
long_predicted = [];
long_real = [];
for i = 1:size(Test_Quart_Hour.xco2,1)
    long_predicted = cat(2, long_predicted, Predicted_Cycles(i,:));
    long_real = cat(2, long_real, Test_Quart_Hour.xco2(i,:));
   
end

inbag_predicted = [];
inbag_real = [];
for i = 1:size(InBag_Comp,1)
    inbag_predicted = cat(2, inbag_predicted, InBag_Cycles(i,:));
    inbag_real = cat(2, inbag_real, InBag_Comp(i,:));
   
end

oob_predicted = [];
oob_real = [];
for i = 1:size(OOB_Comp,1)
    oob_predicted = cat(2, oob_predicted, OOB_Cycles(i,:));
    oob_real = cat(2, oob_real, OOB_Comp(i,:));
   
end

All_Model.(skip).inbag_predicted = inbag_predicted;
All_Model.(skip).inbag_real = inbag_real;
All_Model.(skip).oob_predicted = oob_predicted;
All_Model.(skip).oob_real = oob_real;
All_Model.(skip).val_predicted = long_predicted;
All_Model.(skip).val_real = long_real;

actual_drawdown = InBag_Comp(:,22)- InBag_Comp(:,6);
predicted_drawdown = InBag_Cycles(:,22) - InBag_Cycles(:,6);
All_Model.(skip).inbag_draw_actual = actual_drawdown;
All_Model.(skip).inbag_draw_predicted = predicted_drawdown;

actual_drawdown = OOB_Comp(:,22)- OOB_Comp(:,6);
predicted_drawdown = OOB_Cycles(:,22) - OOB_Cycles(:,6);
All_Model.(skip).oob_draw_actual = actual_drawdown;
All_Model.(skip).oob_draw_predicted = predicted_drawdown;


actual_drawdown = Test_Quart_Hour.xco2(:,22)- Test_Quart_Hour.xco2(:,6);
predicted_drawdown = Predicted_Cycles(:,22) - Predicted_Cycles(:,6);
All_Model.(skip).val_draw_predicted = predicted_drawdown;
All_Model.(skip).val_draw_real = actual_drawdown;
end


save([savepath,'27_point_Model.mat'],'All_Model')

%%
inbagstats = r2rmse(inbag_predicted,inbag_real);
oobstats = r2rmse(oob_predicted,oob_real);
valstats = r2rmse(long_predicted,long_real);

actual_drawdown = InBag_Comp(:,22)- InBag_Comp(:,6);
predicted_drawdown = InBag_Cycles(:,22) - InBag_Cycles(:,6);
inbagdraw = r2rmse(predicted_drawdown,actual_drawdown);

actual_drawdown = OOB_Comp(:,22)- OOB_Comp(:,6);
predicted_drawdown = OOB_Cycles(:,22) - OOB_Cycles(:,6);
oobdraw = r2rmse(predicted_drawdown,actual_drawdown);

actual_drawdown = Test_Quart_Hour.xco2(:,22)- Test_Quart_Hour.xco2(:,6);
predicted_drawdown = Predicted_Cycles(:,22) - Predicted_Cycles(:,6);
valdraw = r2rmse(predicted_drawdown,actual_drawdown);


All_Run.Lam.inbag_ptp = inbagstats.R2;
All_Run.Lam.oob_ptp = oobstats.R2;
All_Run.Lam.val_ptp = valstats.R2;
All_Run.Lam.inbag_draw = inbagdraw.R2;
All_Run.Lam.oob_draw = oobdraw.R2;
All_Run.Lam.val_draw = valdraw.R2;
%% would a big subplot make sense here? 
savepath = 'C:\Users\cmarchet\Documents\ML_Code\figures\Paper_Figs\27_Pt_Run';
h1 = figure(1);
clf
%r2rmse(inbag_p_big,inbag_r_big)
%dscatter(inbag_r_big.',inbag_p_big.')
r2rmse(All_Model.ETL.inbag_predicted,All_Model.ETL.inbag_real)
dscatter(All_Model.ETL.inbag_real.',All_Model.ETL.inbag_predicted.')
xlim([-2 2.5])
ylim([-2 2.5])
cmocean('solar')
rl = refline([1 0]);
rl.LineWidth = 1.25;
rl.Color = 'w';%the 1:1 line
rb = refline([1 0]);
rb.LineWidth = 0.7;
rb.Color = 'k';%the 1:1 line
set(h1, 'Units', 'normalized');
set(h1, 'Position', [0.1, .55, .4, .45]);
colorbar
print('-dtiff',[savepath,'\ETL_inbagptp'])
%%
h2 = figure(2);
clf
r2rmse(oob_p_big,oob_r_big)
dscatter(oob_r_big.',oob_p_big.')
cmocean('-matter')
set(h2, 'Units', 'normalized');
set(h2, 'Position', [0.1, .55, .4, .45]);
rl = refline([1 0]);
rl.LineWidth = 1.25;
rl.Color = 'w';%the 1:1 line
rb = refline([1 0]);
rb.LineWidth = 0.7;
rb.Color = 'k';%the 1:1 line
xlim([-2.75 2.5])
ylim([-2.75 2.5])
colorbar
print('-dtiff',[savepath,'\all_oobptp'])
%%
h3 = figure(3);
%r2rmse(val_p_big,val_r_big)
%dscatter(val_r_big.',val_p_big.')
r2rmse(All_Model.ETL.val_predicted,All_Model.ETL.val_real)
dscatter(All_Model.ETL.val_real.',All_Model.ETL.val_predicted.')
cmocean('thermal')
rl = refline([1 0]);
rl.LineWidth = 1.25;
rl.Color = 'w';%the 1:1 line
rb = refline([1 0]);
rb.LineWidth = 0.7;
rb.Color = 'k';%the 1:1 line
xlim([-2.5 2.5])
ylim([-2.5 2.5])
set(h3, 'Units', 'normalized')
set(h3, 'Position', [0.1, .55, .4, .45]);
colorbar
print('-dtiff',[savepath,'\ETL_valptp'])
%%
h4 = figure(4);
clf
%actual_drawdown = InBag_Comp(:,22)- InBag_Comp(:,6);
%predicted_drawdown = InBag_Cycles(:,22) - InBag_Cycles(:,6);
r2rmse(inbag_p_draw,inbag_r_draw)
dscatter(inbag_r_draw,inbag_p_draw,'Filled',false,'Marker','o')
cmocean('solar')
rl = refline([1 0]);
rl.LineWidth = 1.25;
rl.Color = 'w';%the 1:1 line
rb = refline([1 0]);
rb.LineWidth = 0.7;
rb.Color = 'k';%the 1:1 line
xlim([-3 2])
ylim([-3 2])
set(h4, 'Units', 'normalized');
set(h4, 'Position', [0.1, .55, .4, .45]);
colorbar
print('-dtiff',[savepath,'\all_inbagdraw'])

%%
h5 = figure(5);
clf
%actual_drawdown = OOB_Comp(:,22)- OOB_Comp(:,6);
%predicted_drawdown = OOB_Cycles(:,22) - OOB_Cycles(:,6);
r2rmse(oob_p_draw,oob_r_draw)
dscatter(oob_r_draw,oob_p_draw,'Filled',false,'Marker','o')
cmocean('-matter')
refline([1 0]) %the 1:1 line
rl = refline([1 0]);
rl.LineWidth = 1.25;
rl.Color = 'w';%the 1:1 line
rb = refline([1 0]);
rb.LineWidth = 0.7;
rb.Color = 'k';%the 1:1 line
ylim([-2 1.5])
xlim([-2 1.5])
set(h5, 'Units', 'normalized');
set(h5, 'Position', [0.1, .55, .4, .45]);
colorbar
print('-dtiff',[savepath,'\all_oobdraw'])
%%
h6 = figure(6);
%actual_drawdown = Test_Quart_Hour.xco2(:,22)- Test_Quart_Hour.xco2(:,6);
%predicted_drawdown = Predicted_Cycles(:,22) - Predicted_Cycles(:,6);
r2rmse(val_p_draw,val_r_draw)
dscatter(val_r_draw,val_p_draw,'Filled',false,'Marker','o')
cmocean('thermal')
refline([1 0]) %the 1:1 line
rl = refline([1 0]);
rl.LineWidth = 1.25;
rl.Color = 'w';%the 1:1 line
rb = refline([1 0]);
rb.LineWidth = 0.7;
rb.Color = 'k';%the 1:1 line
ylim([-2.5 1.5])
xlim([-2.5 1.5])
set(h6, 'Units', 'normalized');
set(h6, 'Position', [0.1, .55, .4, .45]);
colorbar
print('-dtiff',[savepath,'\all_valdraw'])


%%

set(h3, 'Units', 'normalized');
set(h3, 'Position', [0, .55, .7, .2]);
set(h4, 'Units', 'normalized');
set(h4, 'Position', [0, .55, .7, .2]);
set(h5, 'Units', 'normalized');
set(h5, 'Position', [0, .55, .7, .2]);
set(h6, 'Units', 'normalized');
set(h6, 'Position', [0, .75, .7, .2]);
%%

figure(1)
clf
TOTAL_R2 = r2rmse(long_predicted, long_real)
dscatter(long_predicted.',long_real.')
cmocean('thermal')
refline([1 0]) %the 1:1 line
xlabel('Predicted XCO_2', 'fontsize', 17)
ylabel('Actual XCO_2', 'fontsize', 17)
title(['Actual Versus Predicted XCO_2 at ', skip], 'fontsize', 17)
colorbar
print('-dtiff',['C:\Users\cmarchet\Documents\ML_Code\figures\validationmeeting\allpointsmodel_',skip])

figure(2)
clf
actual_drawdown = Test_Quart_Hour.xco2(:,22)- Test_Quart_Hour.xco2(:,6);
predicted_drawdown = Predicted_Cycles(:,22) - Predicted_Cycles(:,6);
scatter_r2 = r2rmse(predicted_drawdown,actual_drawdown)
dscatter(predicted_drawdown,actual_drawdown)
refline([1 0]) %the 1:1 line
xlabel('Predicted Drawdown', 'fontsize', 17)
ylabel('Actual Drawdown', 'fontsize', 17)
title(['Actual Versus Predicted Drawdown at ', skip], 'fontsize', 17)
colorbar
print('-dtiff',['C:\Users\cmarchet\Documents\ML_Code\figures\validationmeeting\allpointsmodeldraw_',skip])

%end
%% look at indiv days
number = randi([1 size(Test_Quart_Hour_Times,1)]);
number

figure(2)
clf
scatter(Test_Quart_Hour_Times(number,:),Test_Quart_Hour.xco2(number,:))
hold on
scatter(Test_Quart_Hour_Times(number,:),Predicted_Cycles(number,:))
xlabel('UTC hour')
ylabel('XCO_2 (ppm)')
legend('actual','pred')
title([skip, Daily_Structs.(skip).days(number)])
%print('-dtiff',['C:\Users\cmarchet\Documents\ML_Code\figures\validationmeeting\allpointsmodeldraw_',num2str(number)])
%% make the combined figure
fieldn = fieldnames(All_Model);
inbag_predicted = [];

inbag_p_big = [];
inbag_r_big =[];
oob_p_big= [];
oob_r_big = [];
val_p_big = [];
val_r_big = [];

inbag_p_draw = [];
inbag_r_draw=[];
oob_p_draw= [];
oob_r_draw= [];
val_p_draw = [];
val_r_draw= [];

for i = 1:4
    inbag_p_big = cat(2,inbag_p_big,All_Model.(fieldn{i}).inbag_predicted);
    inbag_r_big =cat(2,inbag_r_big,All_Model.(fieldn{i}).inbag_real);
    oob_p_big= cat(2,oob_p_big,All_Model.(fieldn{i}).oob_predicted);
    oob_r_big = cat(2,oob_r_big,All_Model.(fieldn{i}).oob_real);
    val_p_big = cat(2,val_p_big,All_Model.(fieldn{i}).val_predicted);
    val_r_big = cat(2,val_r_big,All_Model.(fieldn{i}).val_real);

    inbag_p_draw = cat(1,inbag_p_draw,All_Model.(fieldn{i}).inbag_draw_predicted);
    inbag_r_draw=cat(1,inbag_r_draw,All_Model.(fieldn{i}).inbag_draw_actual);
    oob_p_draw= cat(1,oob_p_draw,All_Model.(fieldn{i}).oob_draw_predicted);
    oob_r_draw = cat(1,oob_r_draw,All_Model.(fieldn{i}).oob_draw_actual);
    val_p_draw = cat(1,val_p_draw,All_Model.(fieldn{i}).val_draw_predicted);
    val_r_draw = cat(1,val_r_draw,All_Model.(fieldn{i}).val_draw_real);

end