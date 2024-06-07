%runs through the process from start to finish ands adds error for some
%points
clear all

savepath = 'C:\Users\cmarchet\Documents\ML_Code\Processed_Data\'; %change this to your savepath
addpath(savepath)
addpath 'C:\Users\cmarchet\Documents\ML_Code\Data\'
load Grow_Season 


%comment out empty call and uncomment second on the first run , and comment out the second call and uncomment the first for
%subsequent runs unless one of those files needs to be changed
data_setup_for_model() 
% data_setup_for_model(‘make_daily_arrays’,1,’delta_temp’,1,’make_prob_dists’,1)

skippednames = {'ETL','PF','Lauder','Lamont'};

% change these things!!!

method = 0; %this is an option for adding in 
% simulated error. method = 0 is a pessimistic assumption that assumes
% systematic errors between observing times don't cancel, and method = 1 is
% an optimistic assumption that assumes they do. 
 
sitenum_toskip = 1;
skipbool = 1; % are we leaving a site out for testing? turn off when few sites
%we almost always keep skipbool =1 ie we leave one site out for validation

%hyperparameters for model
ntrees_XGB = [800]; %tuning by r2 onyl 2 oxy
learn_XGB = 0.07;%:.01:0.1; %controls how much weights are adjusted each step
gamma_XGB = [0];%defaultm
ndepth_XGB = [8]; %how complex tree can get, how many levels. adding constraing prevents overfitting
nchild_XGB = [8]; %don't understand this one
nsubsample_XGB = 1; %subsampling. which percent used. we already do traiing testing but this adds just a bit more
lambda_XGB = [4]; %regularization term, makes model more conservative
alpha_XGB = [5]; %regularlization term, makes model more conservative


skip = skippednames{sitenum_toskip}; 

Daily_Structs = init_sites('all'); %Make sure you call the site names correctly!
%ETL, PF, Lamont, Lauder, Iza, Nic

dailyfields = fieldnames(Daily_Structs);
for f = 1:length(dailyfields)
badmonths_struct.(dailyfields{f}) = ones(1,length(Daily_Structs.(dailyfields{f}).days));
end

Grow_Season = badmonths_struct;
%Grow_Season = load(Grow_Season.mat);

[Quart_Hour_Struct,Quart_Hour_Hours,Daily_Structs] = prep_for_EOF_detrend_all(Daily_Structs,Grow_Season);

Subsampled_Struct = subsample_observations_flex(Daily_Structs,'type','create','start_times',-3,'num_obs',3,'spacings',3);

%Subsampled_Struct.(skip) = add_error(Subsampled_Struct.(skip),Daily_Structs.(skip),'type','oco2-3','location',skip,'error',0,'method',method);

%getting rid of days with nans again. but for ALl structs
[Quart_Hour_Struct,Quart_Hour_Hours,Subsampled_Struct,Daily_Structs] = cleanup_nans(Subsampled_Struct,Quart_Hour_Struct,Quart_Hour_Hours,Daily_Structs);

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


Subsampled_Struct.ETL.delta_temp_abs = Subsampled_Struct.ETL.delta_temp_abs.';
Subsampled_Struct.ETL.delta_temp_reg = Subsampled_Struct.ETL.delta_temp_reg.';




[PC_preds,idrem,MODEL,importance,rem,idx] = xgb_model_detrend(PCs_Combo(:,:),Subsampled_Combo,Subsampled_Struct.(skip),ntrees_XGB,learn_XGB,gamma_XGB,ndepth_XGB,nchild_XGB,nsubsample_XGB,lambda_XGB,alpha_XGB);
Test_Quart_Hour = Quart_Hour_Struct.(skip);
 Test_Quart_Hour_Times = Quart_Hour_Hours.(skip);

 Quart_Hour_Av_Combo(rem,:) = [];
 m = size(Quart_Hour_Av_Combo,1) ;
 P = 0.70 ; 
 InBag_Comp = Quart_Hour_Av_Combo(idx(1:round(P*m)),:);
 OOB_Comp = Quart_Hour_Av_Combo(idx(round(P*m)+1:end),:);

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

Test_Quart_Hour(idrem,:) = [];
Test_Quart_Hour_Times(idrem,:) = [];

testfields = fieldnames(Subsampled_Struct.(skip));
for i = 1:length(testfields)
Subsampled_Struct.(skip).(testfields{i})(idrem,:) = [];
end


%save([savepath,'error_',num2str(method),'_Big_Fig.mat'],'Big_Fig') 
%%
%step 2:  we look for days we want the model to test again
number = randi([1 size(Test_Quart_Hour_Times,1)]);
number 

figure(3)
clf
scatter(Test_Quart_Hour_Times(number,:),Test_Quart_Hour(number,:),50, [0.7 0.7 0.7],'filled','LineWidth',0.9)
hold on
scatter(Test_Quart_Hour_Times(number,:),Predicted_Cycles(number,:),45,'k','LineWidth',0.9)
xlabel('UTC hour')
ylabel('XCO_2 (ppm)')
scatter(Subsampled_Struct.ETL.hours(number,:),Subsampled_Struct.ETL.xco2(number,:),45,'k','*','LineWidth',0.9)
title([skip, Daily_Structs.(skip).days(number)])


%% now add error to my things and have model rerun
days_to_run_again = [315,396,199,255,140];
Features = Subsampled_Struct.ETL;
pd = makedist('Normal','mu',0,'sigma',1);
for i = 1:3 %num points per day
  
 
    for j = 1:length(days_to_run_again)
          randval = random(pd);
    Features.xco2(days_to_run_again(j),i) = Features.xco2(days_to_run_again(j),i) + randval;

    end
end
for j = 1:length(days_to_run_again)
    Features.delta_xco2(days_to_run_again(j),1)=Features.xco2(days_to_run_again(j),2) - Features.xco2(days_to_run_again(j),1);
    Features.delta_xco2(days_to_run_again(j),2) = Features.xco2(days_to_run_again(j),3) - Features.xco2(days_to_run_again(j),1);
    Features.delta_xco2(days_to_run_again(j),3) = Features.xco2(days_to_run_again(j),3) - Features.xco2(days_to_run_again(j),2);

end

preds = [Features.hours(:,:),Features.delta_hours(:,:),Features.delta_solmin(:,:),Features.solzen(:,:),Features.delta_solzen(:,:)./Features.delta_hours(:,:),mean(Features.solzen,2),Features.azim(:,:),Features.delta_azim(:,:)./Features.delta_hours(:,:)...
    ,mean(Features.azim,2),Features.delta_xco2(:,:),(Features.delta_xco2(:,:)./Features.delta_hours(:,:)),Features.temp(:,:),Features.delta_temp(:,:)./Features.delta_hours(:,:), mean(Features.temp,2)...
    ,Features.pressure(:,:),Features.delta_pressure(:,:)./Features.delta_hours(:,:),mean(Features.pressure,2), Features.wind_speed(:,:),Features.delta_wind_speed(:,:)./Features.delta_hours(:,:),mean(Features.wind_speed,2)...
    ,Features.prior_xco2(:,:),mean(Features.prior_xco2,2), Features.airmass(:,:),Features.delta_airmass(:,:)./Features.delta_hours(:,:),mean(Features.airmass,2)...
    ,Features.delta_temp_abs(:,:),Features.delta_temp_reg(:,:),Features.VPD(:,:),mean(Features.VPD,2)];

preds = preds(days_to_run_again,:);
indiv_test = py.numpy.asarray(preds);
yhat = double(MODEL.predict(indiv_test));

 new_Predicted_Cycles = [];
for number = 1:length(days_to_run_again)
  new_Predicted_Cycles(number,:) = zeros(1,27);
 
    for i = 1:num_eofs-1
        %adding each EOF one by one with their weighting to get the output
        %day 
        new_Predicted_Cycles(number,:) = new_Predicted_Cycles(number,:)+ EOFs_Combo(i,:).*(yhat(number,i));%+ EOFs_Combo(2,:).*PCs_Combo(number,2) + EOFs_Combo(3,:).*PCs_Combo(number,3) + EOFs_Combo(4,:).*PCs_Combo(number,4);

    end
end


%%

%% look at indiv days
bb = 5;
number = days_to_run_again(bb);
figure(4)
clf
scatter(Test_Quart_Hour_Times(number,:),Test_Quart_Hour(number,:),50, [0.7 0.7 0.7],'LineWidth',1.2)
hold on
scatter(Test_Quart_Hour_Times(number,:),Predicted_Cycles(number,:),45,'k','*','LineWidth',0.8)
scatter(Test_Quart_Hour_Times(number,:),new_Predicted_Cycles(bb,:),45,[139 0 0]/255,'*','LineWidth',0.8)
xlabel('UTC hour')
ylabel('XCO_2 (ppm)')
scatter(Features.hours(number,:),Features.xco2(number,:)-(Features.xco2(number,2)-Subsampled_Struct.ETL.xco2(number,2))+0.05,45,[139 0 0]/255,'filled','LineWidth',0.9)
scatter(Subsampled_Struct.ETL.hours(number,:),Subsampled_Struct.ETL.xco2(number,:),45,'k','filled','LineWidth',0.9)
legend('TCCON Diurnal Cycle','Model Predicted Diurnal Cycle','Actual Subsampled Points','Subsampled Points with Error')
title([skip, Daily_Structs.(skip).days(number)])
%ylim([-0.7 0.8])
legend('TCCON Data','Reconstructed Day-- No Error','Reconstructed Day -- 1ppm SE','Subsampled Points -- No Error','Subsampled Points -- 1ppm SE')
ylim([-0.4 1.8])
print('-dtiff',['C:\Users\cmarchet\Documents\ML_Code\figures\Paper_Figs\demo_error\newpoints3_err',num2str(number)])