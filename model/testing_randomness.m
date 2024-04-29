%runs through the process from start to finish --- DETRENDED VERSION!
%TO DO: Make a badmonths_struct in data_setup, one saved as 'all', and one
%saved as 'growing'
clear all

savepath = 'C:\Users\cmarchet\Documents\ML_Code\Processed_Data\'; %change this to your savepath
addpath(savepath)
addpath 'C:\Users\cmarchet\Documents\ML_Code\Data\'

data_setup_for_model() %change this to a function with inputs and outputs
skippednames = {'ETL','PF','Lauder','Lamont'};
bigloop = 1;
skipbool = 1; % are we leaving a site out for testing? turn off when few sites
skip = skippednames{bigloop}; 
%PLACEHOLDER!
badmonths_struct.ETL = [];
badmonths_struct.PF = [];
badmonths_struct.Lamont = [];
badmonths_struct.Lauder = [];
badmonths_struct.Iza = [];
badmonths_struct.Nic = [];

%preliminary -- will make tighter spacing and wider range after we know
%this works
randomness = [0,0.1,0.2,0.5,1,1.5,2,3];
randomness_sp = [0,0.1,0.2,0.5,1,1.5,2,3];
simnames = {'idealptp_3pts','idealptp_2pts','idealdraw_3pts','idealdraw_2pts'};
startimes = [-3,-1.5,-2.25,-2.25];
spacings = [3,4.25,2.25,4.5];
num_obs = [3,2,3,2];

for i = 3:length(simnames)
PTP_R2 = nan(length(randomness),length(randomness_sp));
PTP_RMSE = nan(length(randomness),length(randomness_sp));
Draw_R2 = nan(length(randomness),length(randomness_sp));
Draw_RMSE = nan(length(randomness),length(randomness_sp));

count = 0;
for st = 1:length(randomness)
    for sp = 1:length(randomness_sp)
        count = count+1

Daily_Structs = init_sites('all'); %Make sure you call the site names correctly!
%ETL, PF, Lamont, Lauder, Iza, Nic

[Quart_Hour_Struct,Quart_Hour_Hours,Daily_Structs] = prep_for_EOF_detrend_all(Daily_Structs,badmonths_struct);

Subsampled_Struct = subsample_observations_flex(Daily_Structs,'type','prob_dist','start_times',startimes(i),'num_obs',num_obs(i),'spacings',spacings(i),'stdev_sp',randomness_sp(sp),'stdev_st',randomness(st));

%getting rid of days with nans again. but for ALl structs
[Quart_Hour_Struct,Quart_Hour_Hours,Subsampled_Struct,Daily_Structs] = cleanup_nans(Subsampled_Struct,Quart_Hour_Struct,Quart_Hour_Hours,Daily_Structs);

% here we need to check for nans so that we don't make weird things
breakout = 0;
tempnames = fieldnames(Quart_Hour_Struct);
for k = 1:length(tempnames)
    if isempty (Quart_Hour_Struct.(tempnames{k}))
        breakout = 1;
    end
end

if breakout == 1
disp('not enough days')
PTP_R2(sp,st)= nan;
PTP_RMSE(sp,st) = nan;
Draw_R2(sp,st) = nan;
Draw_RMSE(sp,st) = nan;
continue
end

%adding temp, humidity, pressure into my Structs
Subsampled_Struct = add_GEOS_all(Subsampled_Struct,Daily_Structs);

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
    Quart_Hour_Av_Combo = cat(1, Quart_Hour_Av_Combo, Quart_Hour_Struct.(fields{v}));
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

for runs = 1
if skipbool == 1
[PC_preds,idrem,MODEL,importance] = xgb_model_detrend(PCs_Combo(:,:),Subsampled_Combo,Subsampled_Struct.(skip),ntrees_XGB,learn_XGB,gamma_XGB,ndepth_XGB,nchild_XGB,nsubsample_XGB,lambda_XGB,alpha_XGB);
Test_Quart_Hour = Quart_Hour_Struct.(skip);
Test_Quart_Hour(idrem,:) = [];
 Test_Quart_Hour_Times = Quart_Hour_Hours.(skip);
 Test_Quart_Hour_Times(idrem,:) = [];

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
 
    for q = 1:num_eofs-1
        %adding each EOF one by one with their weighting to get the output
        %day 
        Predicted_Cycles(number,:) = Predicted_Cycles(number,:)+ EOFs_Combo(q,:).*(PC_preds.(pc_names{q}).oobPred(number));%+ EOFs_Combo(2,:).*PCs_Combo(number,2) + EOFs_Combo(3,:).*PCs_Combo(number,3) + EOFs_Combo(4,:).*PCs_Combo(number,4);

    end
end


%stacking all the real to predicted day so that I can get the OOB stats for
%the site
long_predicted = [];
long_real = [];
for q = 1:size(Test_Quart_Hour,1)
    long_predicted = cat(2, long_predicted, Predicted_Cycles(q,:));
    long_real = cat(2, long_real, Test_Quart_Hour(q,:));
   
end

TOTAL_R2 = r2rmse(long_predicted, long_real);
actual_drawdown = Test_Quart_Hour(:,22)- Test_Quart_Hour(:,6);
predicted_drawdown = Predicted_Cycles(:,22) - Predicted_Cycles(:,6);
scatter_r2 = r2rmse(predicted_drawdown,actual_drawdown);

ptp_R2(runs)= TOTAL_R2.R2;
ptp_RMSE(runs) = TOTAL_R2.RMSE;
draw_R2(runs) = scatter_r2.R2;
draw_RMSE(runs) = scatter_r2.RMSE;
 
end
PTP_R2(sp,st)= mean(ptp_R2);
PTP_RMSE(sp,st) = mean(ptp_RMSE);
Draw_R2(sp,st) = mean(draw_R2);
Draw_RMSE(sp,st) = mean(draw_RMSE);
 
    end
end

save(['C:\Users\cmarchet\Documents\ML_Code\Processed_Data\random_sims\',simnames{i},'PTP_R2'],'PTP_R2')
save(['C:\Users\cmarchet\Documents\ML_Code\Processed_Data\random_sims\',simnames{i},'Draw_R2'],'Draw_R2')
end
%%
figure(1)
clf
%PTP_RMSE(isna(PTP_R2)) = 0;
h = imagesc(PTP_R2)
grid on
title('Point to Point R2')
colorbar()
%caxis([0.575 0.86])
randomness = [0.05,0.125,0.25,0.5,1,1.5,2,3,4];
randomness_sp = [0.05,0.125,0.25,0.5,1,1.5,2,3,4];

yticks([1,2,3,4,5,6,7,8,9])
set(gca,'YDir','normal');
yticklabels({'0.05','0.125','0.25','0.5','1','1.5','2','3','4'})
ylabel('spread in spacing')
xticks([1,2,3,4,5,6,7,8,9])
xticklabels({'0.05','0.125','0.25','0.5','1','1.5','2','3','4'})
xlabel('spread in start times')
%set(h, 'AlphaData', 1-isnan(PTP_R2(:,1:7)))
print('-dtiff','C:\Users\cmarchet\Documents\ML_Code\figures\validationmeeting\random2_idealdptp_ptpR2')

%%
figure()
hold on
for i = 1:5
    plot(1:5,Draw_R2(i,:))

end
