%runs through the process from start to finish --- DETRENDED VERSION!
clear all
addpath C:\Users\cmarchet\Documents\ML_Code\Data\ %change this to whatever your path with the TCCON data is on

%making daily arrays from TCCON
%change the filename inputs in make_daily_array() to whatever your TCCON
%.nc files are named

%making the daily arrays takes a long time -- try to not run it every time
savepath = 'C:\Users\cmarchet\Documents\ML_Code\Processed_Data\'; %change this to your savepath

Daily_Struct_ETL = make_daily_array('etl.nc');
save([savepath,'Daily_Struct_ETL.mat'],'Daily_Struct_ETL','-v7.3')

Daily_Struct_Lamont = make_daily_array('lamont.nc');
save([savepath,'Daily_Struct_Lamont.mat'],'Daily_Struct_Lamont','-v7.3')

Daily_Struct_Lauder = make_daily_array('lauder');
save([savepath,'Daily_Struct_Lauder.mat'],'Daily_Struct_Lauder','-v7.3')

Daily_Struct_PF = make_daily_array('park_falls.nc');
save([savepath,'Daily_Struct_PF.mat'],'Daily_Struct_PF','-v7.3')

Daily_Struct_Iza = make_daily_array('izana.nc');
save([savepath,'Daily_Struct_Iza.mat'],'Daily_Struct_Iza','-v7.3')

Daily_Struct_Nic = make_daily_array('nicosia.nc');
save([savepath,'Daily_Struct_Nic.mat'],'Daily_Struct_Nic','-v7.3')


%%
clear all

savepath = 'C:\Users\cmarchet\Documents\ML_Code\Processed_Data\'; %change this to your savepath
addpath(savepath)
addpath 'C:\Users\cmarchet\Documents\ML_Code\Data\'

skip = 4; %my site order for skipping is: ETL = 1, Lamont = 2, Lauder = 3, PF = 4. 5/6 are Izana and Nicosia but we don't use them

load Daily_Struct_Nic.mat
load Daily_Struct_Iza.mat
load Daily_Struct_PF.mat
load Daily_Struct_Lauder.mat
load Daily_Struct_Lamont.mat
load Daily_Struct_ETL.mat
load Delta_Temp_Struct.mat
%%
[delta_reg_ETL,delta_abs_ETL] = add_delta_temp_eff('etl.nc', Daily_Struct_ETL.days);
[delta_reg_Lam,delta_abs_Lam] = add_delta_temp_eff('lamont.nc', Daily_Struct_Lamont.days);
[delta_reg_PF,delta_abs_PF] = add_delta_temp_eff('park_falls.nc', Daily_Struct_PF.days);
[delta_reg_Nic,delta_abs_Nic] = add_delta_temp_eff('nicosia.nc', Daily_Struct_Nic.days);
[delta_reg_Iza,delta_abs_Iza] = add_delta_temp_eff('izana.nc', Daily_Struct_Iza.days);
ind1 = find(isbetween(datetime(Daily_Struct_Lauder.days),datetime('2004-06-28'),datetime('2010-02-19')));
ind2 = find(isbetween(datetime(Daily_Struct_Lauder.days),datetime('2013-01-02'),datetime('2018-09-30')));
ind3 = find(isbetween(datetime(Daily_Struct_Lauder.days),datetime('2018-10-02'),datetime('2023-03-31')));
[reg_Lau1,abs_Lau1] = add_delta_temp_eff('lauder01.nc',Daily_Struct_Lauder.days(ind1));
[reg_Lau2,abs_Lau2] = add_delta_temp_eff('lauder02.nc',Daily_Struct_Lauder.days(ind2));
[reg_Lau3,abs_Lau3] = add_delta_temp_eff('lauder_03.nc',Daily_Struct_Lauder.days(ind3));
delta_abs_Lau = cat(2,abs_Lau1,abs_Lau2,abs_Lau3);
delta_reg_Lau = cat(2, reg_Lau1,reg_Lau2,reg_Lau3);


Delta_Temp_Struct.ETL.reg = delta_reg_ETL;
Delta_Temp_Struct.ETL.abs = delta_abs_ETL;
Delta_Temp_Struct.Lam.reg = delta_reg_Lam;
Delta_Temp_Struct.Lam.abs = delta_abs_Lam;
Delta_Temp_Struct.Lau.reg = delta_reg_Lau;
Delta_Temp_Struct.Lau.abs = delta_abs_Lau;
Delta_Temp_Struct.PF.reg = delta_reg_PF;
Delta_Temp_Struct.PF.abs = delta_abs_PF;
Delta_Temp_Struct.Nic.reg = delta_reg_Nic;
Delta_Temp_Struct.Nic.abs = delta_abs_Nic;
Delta_Temp_Struct.Iza.reg = delta_reg_Iza;
Delta_Temp_Struct.Iza.abs = delta_abs_Iza;

savepath = 'C:\Users\cmarchet\Documents\ML_Code\Processed_Data\'; 
save([savepath,'Delta_Temp_Struct.mat'],'Delta_Temp_Struct','-v7.3')
%%
%this section fits a polynomial to all days that pass a new quality filter,
%and then reports the quarter hour interval points off that polynomial
[Quart_Hour_Av_ETL, Tossers_ETL, Daynames_ETL, Quart_Hour_Hours_ETL,Daily_Struct_ETL] = prep_for_EOF_detrend(Daily_Struct_ETL,[]);
[Quart_Hour_Av_Lamont, Tossers_Lamont, Daynames_Lamont, Quart_Hour_Hours_Lamont,Daily_Struct_Lamont] = prep_for_EOF_detrend(Daily_Struct_Lamont,[]);
[Quart_Hour_Av_Lauder, Tossers_Lauder, Daynames_Lauder, Quart_Hour_Hours_Lauder,Daily_Struct_Lauder] = prep_for_EOF_detrend(Daily_Struct_Lauder,[]);
[Quart_Hour_Av_PF, Tossers_PF, Daynames_PF,Quart_Hour_Hours_PF,Daily_Struct_PF] = prep_for_EOF_detrend(Daily_Struct_PF,[]);
[Quart_Hour_Av_Iza, Tossers_Iza, Daynames_Iza,Quart_Hour_Hours_Iza,Daily_Struct_Iza] = prep_for_EOF_detrend(Daily_Struct_Iza,[]);
[Quart_Hour_Av_Nic, Tossers_Nic, Daynames_Nic,Quart_Hour_Hours_Nic,Daily_Struct_Nic] = prep_for_EOF_detrend(Daily_Struct_Nic,[]);

%getting rid of the days from the daily arrays that didn't make it through
%the EOF prep
Daily_Struct_ETL.delta_reg = Delta_Temp_Struct.ETL.reg;
Daily_Struct_ETL.delta_abs = Delta_Temp_Struct.ETL.abs;
Daily_Struct_Lamont.delta_reg =  Delta_Temp_Struct.Lam.reg;
Daily_Struct_Lamont.delta_abs = Delta_Temp_Struct.Lam.abs;
Daily_Struct_Lauder.delta_reg =  Delta_Temp_Struct.Lau.reg;
Daily_Struct_Lauder.delta_abs =  Delta_Temp_Struct.Lau.abs;
Daily_Struct_PF.delta_reg =  Delta_Temp_Struct.PF.reg;
Daily_Struct_PF.delta_abs =  Delta_Temp_Struct.PF.abs;
Daily_Struct_Iza.delta_reg =  Delta_Temp_Struct.Iza.reg;
Daily_Struct_Iza.delta_abs =  Delta_Temp_Struct.Iza.abs;
Daily_Struct_Nic.delta_reg =  Delta_Temp_Struct.Nic.reg;
Daily_Struct_Nic.delta_abs =  Delta_Temp_Struct.Nic.abs;

[Daily_Struct_ETL] = remove_tossers(Daily_Struct_ETL, Tossers_ETL);
[Daily_Struct_Lamont] = remove_tossers(Daily_Struct_Lamont, Tossers_Lamont );
[Daily_Struct_Lauder] = remove_tossers(Daily_Struct_Lauder, Tossers_Lauder );
[Daily_Struct_PF] = remove_tossers(Daily_Struct_PF, Tossers_PF );
[Daily_Struct_Iza] = remove_tossers(Daily_Struct_Iza, Tossers_Iza);
[Daily_Struct_Nic] = remove_tossers(Daily_Struct_Nic, Tossers_Nic);

Longitudes = [-90.273, -104.98, 168.684,-97.486,-16.4991,33.381,150.879]; %the coordinates of the TCCON sites in order of the names listed
Latitudes = [45.945,54.35,-45.038,36.604,28.309,35.141,-34.406];
site_names = ["Park Falls", "East Trout Lake", "Lauder", "Lamont", "Izana", "Nicosia","Wollongong"];
site_acr = ["PF","ETL","Lau","Lam","Iza","Nic","Wol"];

%this section is taking the OCO-2/3 crossings, filtering by TCCON site, and
%fitting a probability distribution to the time OCO-2 crosses and the time
%OCO-3 crosses 
for i = 1:length(site_names) %this fits probability distributions by site
[pd_OCO,pd_diff,time_diff,OCO2_time] = fit_prob_dist(Latitudes(i),Longitudes(i),'fig',0,'site_num',i,'min_diff',0);
PD_Struct.(site_acr{i}).OCO2 = pd_OCO;
PD_Struct.(site_acr{i}).diff = pd_diff;
end

%now we use those probability distributions to simulate OCO-2/3 crossings
%over TCCON sites

[Subsampled_ETL] = subsample_observations(Daily_Struct_ETL, 3, Daynames_ETL,PD_Struct.ETL);
[Subsampled_Lamont] = subsample_observations(Daily_Struct_Lamont,3,Daynames_Lamont,PD_Struct.Lam);
[Subsampled_Lauder] = subsample_observations(Daily_Struct_Lauder, 3,Daynames_Lauder,PD_Struct.Lau);
[Subsampled_PF] = subsample_observations(Daily_Struct_PF, 3,Daynames_PF,PD_Struct.PF);
[Subsampled_Iza] = subsample_observations(Daily_Struct_Iza,3,Daynames_Iza,PD_Struct.Iza);
[Subsampled_Nic] = subsample_observations(Daily_Struct_Nic,3,Daynames_Nic,PD_Struct.Nic);


%this is called detrend using prior but we're not detrending. It's
%essentially just getting rid of days with nans again. but for ALl structs
[Quart_Hour_Av_ETL, Quart_Hour_Hours_ETL,Subsampled_ETL,Daily_Struct_ETL,idrem_ETL ] = detrend_using_prior(Subsampled_ETL, Quart_Hour_Av_ETL,Quart_Hour_Hours_ETL,Daily_Struct_ETL);
[Quart_Hour_Av_Lamont, Quart_Hour_Hours_Lamont,Subsampled_Lamont,Daily_Struct_Lamont,idrem_Lamont ] = detrend_using_prior(Subsampled_Lamont, Quart_Hour_Av_Lamont,Quart_Hour_Hours_Lamont,Daily_Struct_Lamont);
[Quart_Hour_Av_Lauder, Quart_Hour_Hours_Lauder,Subsampled_Lauder,Daily_Struct_Lauder,idrem_Lauder ] = detrend_using_prior(Subsampled_Lauder, Quart_Hour_Av_Lauder,Quart_Hour_Hours_Lauder,Daily_Struct_Lauder);
[Quart_Hour_Av_PF, Quart_Hour_Hours_PF,Subsampled_PF,Daily_Struct_PF,idrem_PF ] = detrend_using_prior(Subsampled_PF, Quart_Hour_Av_PF,Quart_Hour_Hours_PF,Daily_Struct_PF);
[Quart_Hour_Av_Iza,Quart_Hour_Hours_Iza, Subsampled_Iza,Daily_Struct_Iza,idrem_Iza] = detrend_using_prior(Subsampled_Iza, Quart_Hour_Av_Iza,Quart_Hour_Hours_Iza,Daily_Struct_Iza);
[Quart_Hour_Av_Nic,Quart_Hour_Hours_Nic, Subsampled_Nic,Daily_Struct_Nic,idrem_Nic] = detrend_using_prior(Subsampled_Nic, Quart_Hour_Av_Nic,Quart_Hour_Hours_Nic,Daily_Struct_Nic);

%adding temp, humidity, pressure into my Structs
[Subsampled_ETL,etl_tossers2] = add_GEOS(Daily_Struct_ETL.days, Subsampled_ETL,'ETL',Daily_Struct_ETL.solar_min);
[Subsampled_Lamont,lam_tossers2] = add_GEOS(Daily_Struct_Lamont.days, Subsampled_Lamont,'Lam',Daily_Struct_Lamont.solar_min);
[Subsampled_Lauder,lau_tossers2] = add_GEOS(Daily_Struct_Lauder.days, Subsampled_Lauder,'Lau',Daily_Struct_Lauder.solar_min);
[Subsampled_PF,pf_tossers2] = add_GEOS(Daily_Struct_PF.days, Subsampled_PF,'PF',Daily_Struct_PF.solar_min);
[Subsampled_Iza,iza_tossers2] = add_GEOS(Daily_Struct_Iza.days, Subsampled_Iza,'Iza',Daily_Struct_Iza.solar_min);
[Subsampled_Nic,nic_tossers2] = add_GEOS(Daily_Struct_Nic.days, Subsampled_Nic,'Nic',Daily_Struct_Nic.solar_min);
%using those variables to calculate VPD
Subsampled_ETL = calc_VPD(Subsampled_ETL);
Subsampled_Lamont = calc_VPD(Subsampled_Lamont);
Subsampled_Lauder = calc_VPD(Subsampled_Lauder);
Subsampled_PF = calc_VPD(Subsampled_PF);
Subsampled_Iza = calc_VPD(Subsampled_Iza);
Subsampled_Nic = calc_VPD(Subsampled_Nic);

% adding in difference in potential temperature at 700hpa (abs and normal)


%making structures that are nice bc I can grab from them easily
Quart_Hour_Struct.ETL = Quart_Hour_Av_ETL;
Quart_Hour_Struct.Lamont = Quart_Hour_Av_Lamont;
Quart_Hour_Struct.Lauder = Quart_Hour_Av_Lauder;
Quart_Hour_Struct.PF = Quart_Hour_Av_PF;
Quart_Hour_Struct.Iza = Quart_Hour_Av_Iza;
Quart_Hour_Struct.Nic = Quart_Hour_Av_Nic;

Quart_Hour_Hours.ETL = Quart_Hour_Hours_ETL;
Quart_Hour_Hours.Lamont = Quart_Hour_Hours_Lamont;
Quart_Hour_Hours.Lauder = Quart_Hour_Hours_Lauder;
Quart_Hour_Hours.PF = Quart_Hour_Hours_PF;
Quart_Hour_Hours.Iza = Quart_Hour_Hours_Iza;
Quart_Hour_Hours.Nic = Quart_Hour_Hours_Nic;

Daynames_Struct.ETL = Daily_Struct_ETL.days;
Daynames_Struct.Lamont = Daily_Struct_Lamont.days;
Daynames_Struct.Lauder = Daily_Struct_Lauder.days;
Daynames_Struct.PF = Daily_Struct_PF.days;
Daynames_Struct.Iza = Daily_Struct_Iza.days;
Daynames_Struct.Nic = Daily_Struct_Nic.days;

fields = fieldnames(Quart_Hour_Struct); %the site names

Quart_Hour_Av_Combo = [];
Quart_Hour_Hours_Combo = [];
%making a struct of the quart hour avs for EOF generation (want one big
%array), and keeping out the testing set
for v = 1:length(fields)
    if v == skip
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

Daily_Structs.ETL = Daily_Struct_ETL;
Daily_Structs.Lamont = Daily_Struct_Lamont;
Daily_Structs.Lauder = Daily_Struct_Lauder;
Daily_Structs.PF = Daily_Struct_PF;
Daily_Structs.Nic = Daily_Struct_Nic;
Daily_Structs.Iza = Daily_Struct_Iza;

Subsampled_Struct.ETL = Subsampled_ETL;
Subsampled_Struct.Lamont = Subsampled_Lamont;
Subsampled_Struct.Lauder = Subsampled_Lauder;
Subsampled_Struct.PF = Subsampled_PF;
Subsampled_Struct.Nic = Subsampled_Nic;
Subsampled_Struct.Iza = Subsampled_Iza;

features = fieldnames(Subsampled_ETL);
 for z = 1:length(features)
    Subsampled_Combo.(features{z}) = [];
 end


for b = 1:length(fields) %looping over all sites
    if b == skip
        continue
    end
    
    
    for z = 1:length(features) %looping over all features
       %each feature is now a combo from all sites 

         Subsampled_Combo.(features{z}) = cat(1, Subsampled_Combo.(features{z}), Subsampled_Struct.(fields{b}).(features{z}));
   
  
    end
 
end

%PCs_Combo(:,:) =sign(PCs_Combo(:,:)).*log10(abs(PCs_Combo(:,:))+1); %taking the log bc small values

% should save some structures here so changes to the model can be made
% without re processing everything 

save('C:\Users\cmarchet\Documents\ML_Code\Processed_Data\Subsampled_Struct.mat','Subsampled_Struct')
save('C:\Users\cmarchet\Documents\ML_Code\Processed_Data\Subsampled_Combo.mat','Subsampled_Combo')
save('C:\Users\cmarchet\Documents\ML_Code\Processed_Data\PCs_Combo.mat','PCs_Combo')
save('C:\Users\cmarchet\Documents\ML_Code\Processed_Data\EOFs_Combo.mat','EOFs_Combo')
%%
%hyperparameters for model
ntrees_XGB = [600:100:800]; %tuning by r2 onyl 2 oxy
learn_XGB = 0.10:.01:0.15;%:.01:0.1; %controls how much weights are adjusted each step
gamma_XGB = [0];%defaultm
ndepth_XGB = [8]; %how complex tree can get, how many levels. adding constraing prevents overfitting
nchild_XGB = [8]; %don't understand this one
nsubsample_XGB = 1; %subsampling. which percent used. we already do traiing testing but this adds just a bit more
lambda_XGB = [0,1]; %regularization term, makes model more conservative
alpha_XGB = [0,1,2]; %regularlization term, makes model more conservative

%running da model
for run = 1%:50
    run
[PC_preds,idrem,MODEL,importance] = xgb_model_detrend(PCs_Combo(:,:),Subsampled_Combo,Subsampled_Struct.(fields{skip}),ntrees_XGB,learn_XGB,gamma_XGB,ndepth_XGB,nchild_XGB,nsubsample_XGB,lambda_XGB,alpha_XGB);

PC1_array(:,run) = PC_preds.pc_1.oobPred;
PC2_array(:,run) = PC_preds.pc_2.oobPred;
PC3_array(:,run) = PC_preds.pc_3.oobPred;
PC4_array(:,run) = PC_preds.pc_4.oobPred;
PC5_array(:,run) = PC_preds.pc_5.oobPred;
PC6_array(:,run) = PC_preds.pc_6.oobPred;
PC7_array(:,run) = PC_preds.pc_7.oobPred;

%the actual data
 Test_Quart_Hour = Quart_Hour_Struct.(fields{skip});
 Test_Quart_Hour_Times = Quart_Hour_Hours.(fields{skip});

 %here I'm reconstructing my predicted days from the EOFs and the PCs
 pc_names = fieldnames(PC_preds);
 pc_names(1:10) = [];
for number = 1:length(PC_preds.pc_1(1).oobPred)
  Predicted_Cycles(number,:) = zeros(1,27);
 
    for i = 1:num_eofs-1
        %adding each EOF one by one with their weighting to get the output
        %day 
       % Predicted_Cycles(number,:) = Predicted_Cycles(number,:)+ EOFs_Combo(i,:).*(sign(PC_preds.(pc_names{i}).oobPred(number)).*(10.^(abs(PC_preds.(pc_names{i}).oobPred(number)))-1)) ;%+ EOFs_Combo(2,:).*PCs_Combo(number,2) + EOFs_Combo(3,:).*PCs_Combo(number,3) + EOFs_Combo(4,:).*PCs_Combo(number,4);
        Predicted_Cycles(number,:) = Predicted_Cycles(number,:)+ EOFs_Combo(i,:).*(PC_preds.(pc_names{i}).oobPred(number));%+ EOFs_Combo(2,:).*PCs_Combo(number,2) + EOFs_Combo(3,:).*PCs_Combo(number,3) + EOFs_Combo(4,:).*PCs_Combo(number,4);

    end
end

for i = 1:size(Predicted_Cycles,1)
statis = r2rmse(Predicted_Cycles(i,:), Test_Quart_Hour(i,:));
R2_array(i,run) = statis.R2;
RMSE_array(i,run) = statis.RMSE;
drawdown_diff_array(i,run) = abs((Predicted_Cycles(i,22)-Predicted_Cycles(i,6))-(Test_Quart_Hour(i,22)-Test_Quart_Hour(i,6)));
end


%stacking all the real to predicted day so that I can get the OOB stats for
%the site
%long_predicted = [];
%long_real = [];
%for i = 1:size(Quart_Hour_Struct.(fields{skip}),1)
 %   long_predicted = cat(2, long_predicted, Predicted_Cycles(i,:));
  %  long_real = cat(2, long_real, Test_Quart_Hour(i,:));
   
%end
end
%%
figure(1)
clf
TOTAL_R2 = r2rmse(long_predicted, long_real)
dscatter(long_predicted.',long_real.')
cmocean('thermal')
refline([1 0]) %the 1:1 line
xlabel('Predicted XCO_2', 'fontsize', 17)
ylabel('Actual XCO_2', 'fontsize', 17)
title(['Actual Versus Predicted XCO_2 at ', fields{skip}], 'fontsize', 17)
colorbar
print('-dtiff',['C:\Users\cmarchet\Documents\ML_Code\Figures\model_scatter_',fields{skip}])

figure(2)
clf
actual_drawdown = Quart_Hour_Struct.(fields{skip})(:,22)- Quart_Hour_Struct.(fields{skip})(:,6);
predicted_drawdown = Predicted_Cycles(:,22) - Predicted_Cycles(:,6);
scatter_r2 = r2rmse(predicted_drawdown,actual_drawdown)
dscatter(predicted_drawdown,actual_drawdown)
refline([1 0]) %the 1:1 line
xlabel('Predicted Drawdown', 'fontsize', 17)
ylabel('Actual Drawdown', 'fontsize', 17)
title(['Actual Versus Predicted Drawdown at ', fields{skip}], 'fontsize', 17)
colorbar
print('-dtiff',['C:\Users\cmarchet\Documents\ML_Code\Figures\drawdown_scatter_',fields{skip}])


%%
clf
pc_diff = std(PC1_array,0,2);
mean_r2 = mean(drawdown_diff_array,2);
dscatter(pc_diff,mean_r2)
corrcoef(mean_r2,pc_diff)
xlabel('Standard Deviation of PC 1 across 50 runs')
ylabel('mean drawdown error across 50 runs')
print('-dtiff','C:\Users\cmarchet\Documents\ML_Code\Figures\PC1_draw')

%%
perm_importance = py.sklearn.inspection.permutation_importance(MODEL,py.numpy.asarray(preds),py.numpy.asarray(PCs_Combo));