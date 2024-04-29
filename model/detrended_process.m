%runs through the process from start to finish --- DETRENDED VERSION!
%clear all

savepath = 'C:\Users\cmarchet\Documents\ML_Code\Processed_Data\'; %change this to your savepath
addpath(savepath)
addpath 'C:\Users\cmarchet\Documents\ML_Code\Data\'
Grow_Season = load(Grow_Season.mat);


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

Subsampled_Struct = subsample_observations_flex(Daily_Structs,'type','oco2-3','start_times',-3,'num_obs',2,'spacings',3);

Subsampled_Struct.(skip) = add_error(Subsampled_Struct.(skip),Daily_Structs.(skip),'type','oco2-3','location',skip,'error',0,'method',method);

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

InBag_Cycles = [];
for number = 1:length(PC_preds.pc_1(1).inBagPred)
  InBag_Cycles(number,:) = zeros(1,27);
 
    for i = 1:num_eofs-1
        %adding each EOF one by one with their weighting to get the output
        %day 
        InBag_Cycles(number,:) = InBag_Cycles(number,:)+ EOFs_Combo(i,:).*(PC_preds.(pc_names{i}).inBagPred(number));%+ EOFs_Combo(2,:).*PCs_Combo(number,2) + EOFs_Combo(3,:).*PCs_Combo(number,3) + EOFs_Combo(4,:).*PCs_Combo(number,4);

    end
end


Test_Quart_Hour(idrem,:) = [];
Test_Quart_Hour_Times(idrem,:) = [];
%stacking all the real to predicted day so that I can get the OOB stats for
%the site
long_predicted = [];
long_real = [];
for i = 1:size(Test_Quart_Hour,1)
    long_predicted = cat(2, long_predicted, Predicted_Cycles(i,:));
    long_real = cat(2, long_real, Test_Quart_Hour(i,:));
   
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


%save([savepath,'error_',num2str(method),'_Big_Fig.mat'],'Big_Fig') 


%%
savepath = 'C:\Users\cmarchet\Documents\ML_Code\figures\Paper_Figs\oco2-3sim\';
h1 = figure(1);
clf
r2rmse(inbag_predicted,inbag_real)
dscatter(inbag_predicted.',inbag_real.')
cmocean('solar')
rl = refline([1 0]);
rl.LineWidth = 1.25;
rl.Color = 'w';%the 1:1 line
rb = refline([1 0]);
rb.LineWidth = 0.7;
rb.Color = 'k';%the 1:1 line
%ylim([-2.5 2.1])
set(h1, 'Units', 'normalized');
set(h1, 'Position', [0.1, .55, .4, .45]);
colorbar
print('-dtiff',[savepath,'\method',num2str(method),skip,'_inbagptp'])
%%
h2 = figure(2);
clf
r2rmse(oob_predicted,oob_real)
dscatter(oob_predicted.',oob_real.')
cmocean('-matter')
set(h2, 'Units', 'normalized');
set(h2, 'Position', [0.1, .55, .4, .45]);
rl = refline([1 0]);
rl.LineWidth = 1.25;
rl.Color = 'w';%the 1:1 line
rb = refline([1 0]);
rb.LineWidth = 0.7;
rb.Color = 'k';%the 1:1 line
%xlim([-1 1])
colorbar
print('-dtiff',[savepath,'\method',num2str(method),skip,'_oobptp'])
%%
h3 = figure(3);
r2rmse(long_predicted,long_real)
dscatter(long_predicted.',long_real.')
cmocean('thermal')
rl = refline([1 0]);
rl.LineWidth = 1.25;
rl.Color = 'w';%the 1:1 line
rb = refline([1 0]);
rb.LineWidth = 0.7;
rb.Color = 'k';%the 1:1 line
%xlim([-1 1])
ylim([-2.2 2.2])
set(h3, 'Units', 'normalized')
set(h3, 'Position', [0.1, .55, .4, .45]);
colorbar
%print('-dtiff',[savepath,'\method',num2str(method),skip,'_valptp'])
%%
h4 = figure(4);
actual_drawdown = InBag_Comp(:,22)- InBag_Comp(:,6);
predicted_drawdown = InBag_Cycles(:,22) - InBag_Cycles(:,6);
r2rmse(predicted_drawdown,actual_drawdown)
dscatter(predicted_drawdown,actual_drawdown,'Filled',false,'Marker','o')
cmocean('solar')
rl = refline([1 0]);
rl.LineWidth = 1.25;
rl.Color = 'w';%the 1:1 line
rb = refline([1 0]);
rb.LineWidth = 0.7;
rb.Color = 'k';%the 1:1 line
%xlim([-2.7 2])
set(h4, 'Units', 'normalized');
set(h4, 'Position', [0.1, .55, .4, .45]);
colorbar
print('-dtiff',[savepath,'\method',num2str(method),skip,'_inbagdraw'])

%%
h5 = figure(5);
actual_drawdown = OOB_Comp(:,22)- OOB_Comp(:,6);
predicted_drawdown = OOB_Cycles(:,22) - OOB_Cycles(:,6);
r2rmse(predicted_drawdown,actual_drawdown)
dscatter(predicted_drawdown,actual_drawdown,'Filled',false,'Marker','o')
cmocean('-matter')
refline([1 0]) %the 1:1 line
rl = refline([1 0]);
rl.LineWidth = 1.25;
rl.Color = 'w';%the 1:1 line
rb = refline([1 0]);
rb.LineWidth = 0.7;
rb.Color = 'k';%the 1:1 line
%ylim([-2 1.5])
%xlim([-1 0.6])
set(h5, 'Units', 'normalized');
set(h5, 'Position', [0.1, .55, .4, .45]);
colorbar
print('-dtiff',[savepath,'\method',num2str(method),skip,'_oobdraw'])
%%
h6 = figure(6);
actual_drawdown = Test_Quart_Hour(:,22)- Test_Quart_Hour(:,6);
predicted_drawdown = Predicted_Cycles(:,22) - Predicted_Cycles(:,6);
r2rmse(predicted_drawdown,actual_drawdown)
dscatter(predicted_drawdown,actual_drawdown,'Filled',false,'Marker','o')
cmocean('thermal')
refline([1 0]) %the 1:1 line
rl = refline([1 0]);
rl.LineWidth = 1.25;
rl.Color = 'w';%the 1:1 line
rb = refline([1 0]);
rb.LineWidth = 0.7;
rb.Color = 'k';%the 1:1 line
%ylim([-2.5 1.5])
%xlim([-1 0.7])
set(h6, 'Units', 'normalized');
set(h6, 'Position', [0.1, .55, .4, .45]);
colorbar
print('-dtiff',[savepath,'\method',num2str(method),skip,'_valdraw'])





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
%print('-dtiff',['C:\Users\cmarchet\Documents\ML_Code\figures\validationmeeting\idealdrawreal_',skip])

figure(2)
clf
actual_drawdown = Test_Quart_Hour(:,22)- Test_Quart_Hour(:,6);
predicted_drawdown = Predicted_Cycles(:,22) - Predicted_Cycles(:,6);
scatter_r2 = r2rmse(predicted_drawdown,actual_drawdown)
dscatter(predicted_drawdown,actual_drawdown)
refline([1 0]) %the 1:1 line
xlabel('Predicted Drawdown', 'fontsize', 17)
ylabel('Actual Drawdown', 'fontsize', 17)
title(['Actual Versus Predicted Drawdown at ', skip], 'fontsize', 17)
colorbar
%print('-dtiff',['C:\Users\cmarchet\Documents\ML_Code\figures\validationmeeting\idealdrawdraw_',skip])

%end
%% look at indiv days
number = randi([1 size(Test_Quart_Hour_Times,1)]);
number
figure(2)
clf
scatter(Test_Quart_Hour_Times(number,:),Test_Quart_Hour(number,:))
hold on
scatter(Test_Quart_Hour_Times(number,:),Predicted_Cycles(number,:))
xlabel('UTC hour')
ylabel('XCO_2 (ppm)')
legend('actual','pred')
title([skip, Daily_Structs.(skip).days(number)])