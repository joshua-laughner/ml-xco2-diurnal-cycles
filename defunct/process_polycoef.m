%idk my process or whatever
%clear all
addpath /home/cmarchet/Data/
skip = 1;
%making daily arrays blah blah blah
Daily_Struct_ETL = make_daily_array('east_trout_lake.nc');
save('/home/cmarchet/Processed_Data/Daily_Struct_ETL.mat','Daily_Struct_ETL','-v7.3')
clear Daily_Struct_ETL
Daily_Struct_Lamont = make_daily_array('lamont.nc');
save('/home/cmarchet/Processed_Data/Daily_Struct_Lamont.mat','Daily_Struct_Lamont','-v7.3')
clear Daily_Struct_Lamont
Daily_Struct_Lauder = make_daily_array('lauder');
save('/home/cmarchet/Processed_Data/Daily_Struct_Lauder.mat','Daily_Struct_Lauder','-v7.3')
clear Daily_Struct_Lauder
Daily_Struct_PF = make_daily_array('park_falls.nc');
save('/home/cmarchet/Processed_Data/Daily_Struct_PF.mat','Daily_Struct_PF','-v7.3')
clear Daily_Struct_PF
Daily_Struct_Iza = make_daily_array('izana.nc');
save('/home/cmarchet/Processed_Data/Daily_Struct_Iza.mat','Daily_Struct_Iza','-v7.3')
clear Daily_Struct_Iza
Daily_Struct_Nic = make_daily_array('nicosia.nc');
save('/home/cmarchet/Processed_Data/Daily_Struct_Nic.mat','Daily_Struct_Nic','-v7.3')
clear Daily_Struct_Nic
%% so much of this can and should be cleaned up 
clear all
addpath C:\Users\cmarchet\Box\JPL\Data
addpath C:\Users\cmarchet\Box\JPL\Processed_Data\
skip = 1;

load Daily_Struct_Nic.mat
load Daily_Struct_Iza.mat
load Daily_Struct_PF.mat
load Daily_Struct_Lauder.mat
load Daily_Struct_Lamont.mat
load Daily_Struct_ETL.mat


% then i calculate my targets -- the drawdown values
[Tossers_ETL, Daynames_ETL] = first_round_prep(Daily_Struct_ETL);
[Tossers_Lamont, Daynames_Lamont] = first_round_prep(Daily_Struct_Lamont);
[ Tossers_Lauder, Daynames_Lauder] = first_round_prep(Daily_Struct_Lauder);
[Tossers_PF, Daynames_PF] = first_round_prep(Daily_Struct_PF);
[Tossers_Iza, Daynames_Iza] = first_round_prep(Daily_Struct_Iza);
[Tossers_Nic, Daynames_Nic] = first_round_prep(Daily_Struct_Nic);


[Daily_Struct_ETL] = remove_tossers(Daily_Struct_ETL, Tossers_ETL);
[Daily_Struct_Lamont] = remove_tossers(Daily_Struct_Lamont, Tossers_Lamont );
[Daily_Struct_Lauder] = remove_tossers(Daily_Struct_Lauder, Tossers_Lauder );
[Daily_Struct_PF] = remove_tossers(Daily_Struct_PF, Tossers_PF );
[Daily_Struct_Iza] = remove_tossers(Daily_Struct_Iza, Tossers_Iza);
[Daily_Struct_Nic] = remove_tossers(Daily_Struct_Nic, Tossers_Nic);

Longitudes = [-90.273, -104.98, 168.684,-97.486,-16.4991,33.381,150.879];
Latitudes = [45.945,54.35,-45.038,36.604,28.309,35.141,-34.406];
site_names = ["Park Falls", "East Trout Lake", "Lauder", "Lamont", "Izana", "Nicosia","Wollongong"];
site_acr = ["PF","ETL","Lau","Lam","Iza","Nic","Wol"];

for i = 1:length(site_names)
[pd_OCO,pd_diff,time_diff,OCO2_time] = fit_prob_dist(Latitudes(i),Longitudes(i),'fig',0,'site_num',i,'min_diff',0);
PD_Struct.(site_acr{i}).OCO2 = pd_OCO;
PD_Struct.(site_acr{i}).diff = pd_diff;
end

[Subsampled_ETL] = subsample_observations(Daily_Struct_ETL, 3, Daynames_ETL,PD_Struct.ETL);
[Subsampled_Lamont] = subsample_observations(Daily_Struct_Lamont,3,Daynames_Lamont,PD_Struct.Lam);
[Subsampled_Lauder] = subsample_observations(Daily_Struct_Lauder, 3,Daynames_Lauder,PD_Struct.Lau);
[Subsampled_PF] = subsample_observations(Daily_Struct_PF, 3,Daynames_PF,PD_Struct.PF);
[Subsampled_Iza] = subsample_observations(Daily_Struct_Iza,3,Daynames_Iza,PD_Struct.Iza);
[Subsampled_Nic] = subsample_observations(Daily_Struct_Nic,3,Daynames_Nic,PD_Struct.Nic);

[Subsampled_ETL,Daily_Struct_ETL,idrem_ETL ] = detrend_using_prior_n(Subsampled_ETL, Daily_Struct_ETL);
[Subsampled_Lamont,Daily_Struct_Lamont,idrem_Lamont ] = detrend_using_prior_n(Subsampled_Lamont,Daily_Struct_Lamont);
[Subsampled_Lauder,Daily_Struct_Lauder,idrem_Lauder ] = detrend_using_prior_n(Subsampled_Lauder, Daily_Struct_Lauder);
[Subsampled_PF,Daily_Struct_PF,idrem_PF ] = detrend_using_prior_n(Subsampled_PF,Daily_Struct_PF);
[Subsampled_Iza,Daily_Struct_Iza,idrem_Iza] = detrend_using_prior_n(Subsampled_Iza,Daily_Struct_Iza);
[Subsampled_Nic,Daily_Struct_Nic,idrem_Nic] = detrend_using_prior_n(Subsampled_Nic,Daily_Struct_Nic);

[Quart_Hour_Av_ETL,Quart_Hour_Hours_ETL,Coefs_ETL] = fit_poly(Daily_Struct_ETL);
[Quart_Hour_Av_Lamont,Quart_Hour_Hours_Lamont,Coefs_Lamont] = fit_poly(Daily_Struct_Lamont);
[Quart_Hour_Av_Lauder,Quart_Hour_Hours_Lauder,Coefs_Lauder] = fit_poly(Daily_Struct_Lauder);
[Quart_Hour_Av_PF,Quart_Hour_Hours_PF,Coefs_PF] = fit_poly(Daily_Struct_PF);
[Quart_Hour_Av_Iza,Quart_Hour_Hours_Iza,Coefs_Iza] = fit_poly(Daily_Struct_Iza);
[Quart_Hour_Av_Nic,Quart_Hour_Hours_Nic,Coefs_Nic] = fit_poly(Daily_Struct_Nic);

Drawdown_Struct.ETL = calc_drawdown_TCCON(Daily_Struct_ETL);
Drawdown_Struct.Lamont = calc_drawdown_TCCON(Daily_Struct_Lamont);
Drawdown_Struct.Lauder = calc_drawdown_TCCON(Daily_Struct_Lauder);
Drawdown_Struct.PF = calc_drawdown_TCCON(Daily_Struct_PF);
Drawdown_Struct.Iza = calc_drawdown_TCCON(Daily_Struct_Iza);
Drawdown_Struct.Nic = calc_drawdown_TCCON(Daily_Struct_Nic);
save('C:\Users\cmarchet\Box\JPL\Processed_Data\Actual_Drawdown_Struct.mat', 'Drawdown_Struct', '-v7.3')

Quart_Hour_Struct.ETL = Quart_Hour_Av_ETL;
Quart_Hour_Struct.Lamont = Quart_Hour_Av_Lamont;
Quart_Hour_Struct.Lauder = Quart_Hour_Av_Lauder;
Quart_Hour_Struct.PF = Quart_Hour_Av_PF;
Quart_Hour_Struct.Iza = Quart_Hour_Av_Iza;
Quart_Hour_Struct.Nic = Quart_Hour_Av_Nic;
save('C:\Users\cmarchet\Box\JPL\Processed_Data\Quart_Hour_Struct.mat', 'Quart_Hour_Struct', '-v7.3')

Quart_Hour_Hours.ETL = Quart_Hour_Hours_ETL;
Quart_Hour_Hours.Lamont = Quart_Hour_Hours_Lamont;
Quart_Hour_Hours.Lauder = Quart_Hour_Hours_Lauder;
Quart_Hour_Hours.PF = Quart_Hour_Hours_PF;
Quart_Hour_Hours.Iza = Quart_Hour_Hours_Iza;
Quart_Hour_Hours.Nic = Quart_Hour_Hours_Nic;
save('C:\Users\cmarchet\Box\JPL\Processed_Data\Quart_Hour_Hours.mat', 'Quart_Hour_Hours', '-v7.3')

Daynames_Struct.ETL = Daynames_ETL;
Daynames_Struct.Lamont = Daynames_Lamont;
Daynames_Struct.Lauder = Daynames_Lauder;
Daynames_Struct.PF = Daynames_PF;
Daynames_Struct.Iza = Daynames_Iza;
Daynames_Struct.Nic = Daynames_Nic;
save('C:\Users\cmarchet\Box\JPL\Processed_Data\Daynames_Struct.mat', 'Daynames_Struct', '-v7.3')

Coefs_Struct.ETL = Coefs_ETL;
Coefs_Struct.Lamont = Coefs_Lamont;
Coefs_Struct.Lauder = Coefs_Lauder;
Coefs_Struct.PF = Coefs_PF;
Coefs_Struct.Iza = Coefs_Iza;
Coefs_Struct.Nic = Coefs_Nic;

%I guess I could make a big struct for the hourly drawdowns as well? Id
%have to leave out the testing site

fields = fieldnames(Quart_Hour_Struct);

Quart_Hour_Av_Combo = [];
Quart_Hour_Hours_Combo = [];
Coefs_Combo = [];
%making a struct of the quart hour avs for EOF generation (want one big
%array), and keeping out the testing set
for v = 1:length(fields)
    if v == skip
        continue
    end
    Quart_Hour_Hours_Combo = cat(1,Quart_Hour_Hours_Combo,Quart_Hour_Hours.(fields{v}));
    Quart_Hour_Av_Combo = cat(1, Quart_Hour_Av_Combo, Quart_Hour_Struct.(fields{v}));
    Coefs_Combo = cat(1,Coefs_Combo,Coefs_Struct.(fields{v}));
end

save('C:\Users\cmarchet\Box\JPL\Processed_Data\Coefs_Combo.mat', 'Coefs_Combo', '-v7.3')
%make the probability distributions -- these won't change across runs (most
%likely)


Daily_Structs.ETL = Daily_Struct_ETL;
Daily_Structs.Lamont = Daily_Struct_Lamont;
Daily_Structs.Lauder = Daily_Struct_Lauder;
Daily_Structs.PF = Daily_Struct_PF;
Daily_Structs.Nic = Daily_Struct_Nic;
Daily_Structs.Iza = Daily_Struct_Iza;
save('C:\Users\cmarchet\Box\JPL\Processed_Data\Daily_Structs.mat', 'Daily_Structs', '-v7.3')

Subsampled_Struct.ETL = Subsampled_ETL;
Subsampled_Struct.Lamont = Subsampled_Lamont;
Subsampled_Struct.Lauder = Subsampled_Lauder;
Subsampled_Struct.PF = Subsampled_PF;
Subsampled_Struct.Nic = Subsampled_Nic;
Subsampled_Struct.Iza = Subsampled_Iza;
save('C:\Users\cmarchet\Box\JPL\Processed_Data\Subsampled_Struct.mat', 'Subsampled_Struct', '-v7.3')

features = fieldnames(Subsampled_ETL);
 for z = 1:length(features)
    Subsampled_Combo.(features{z}) = [];
 end
 
 Combo_Drawdown = [];
%making a large feature struct from all the training sites. 

for b = 1:length(fields)
    if b == skip
        continue
    end
    
    
    for z = 1:length(features)
       
    Subsampled_Combo.(features{z}) = cat(1, Subsampled_Combo.(features{z}), Subsampled_Struct.(fields{b}).(features{z}));
    end

end

%Coefs_Combo(:,:) =sign(Coefs_Combo(:,:)).*log10(abs(Coefs_Combo(:,:))+1);
%%

ntrees_XGB = [900]; %tuning by r2 onyl 2 oxy
learn_XGB = 0.15;%:.01:0.2; %controls how much weights are adjusted each step
gamma_XGB = [0];%default
ndepth_XGB = [11]; %how complex tree can get, how many levels. adding constraing prevents overfitting
nchild_XGB = [3]; %don't understand this one
nsubsample_XGB = 0.91:.01:0.96; %subsampling. which percent used. we already do traiing testing but this adds just a bit more
lambda_XGB = [2]; %regularization term, makes model more conservative
alpha_XGB = [0]; %regularization term, makes model more conservative


[PC_preds,idrem,MODEL] = xgb_model(Coefs_Combo(:,:),Subsampled_Combo,Subsampled_Struct.(fields{skip}),ntrees_XGB,learn_XGB,gamma_XGB,ndepth_XGB,nchild_XGB,nsubsample_XGB,lambda_XGB,alpha_XGB);
%[PC_preds,idrem] = pc_model(PCs_Combo, Subsampled_Combo, Subsampled_Struct.(fields{skip}));
%I'm so suspicious of how well this model is running.... 

 Test_Quart_Hour = Quart_Hour_Struct.(fields{skip});
% Test_Quart_Hour(idrem, :) = [];
 Test_Quart_Hour_Times = Quart_Hour_Hours.(fields{skip});

% Test_Quart_Hour_Times(idrem,:) = [];
 
 pc_names = fieldnames(PC_preds);
 pc_names(1:10) = [];
for number = 1:length(PC_preds.pc_1(1).oobPred)
  %Predicted_Cycles(number,:) = zeros(1,27);
 
    for i = 1:6
      coefs(i) =PC_preds.(pc_names{i}).oobPred(number);
      %  coefs(i) = sign(PC_preds.(pc_names{i}).oobPred(number)).*(10.^(abs(PC_preds.(pc_names{i}).oobPred(number)))-1);
    end
    Predicted_Cycles(number,:) = polyval(coefs,Test_Quart_Hour_Times(number,:)-Daily_Structs.(fields{skip}).solar_min(number));
end

long_predicted = [];
long_real = [];
for i = 1:394
    long_predicted = cat(2, long_predicted, Predicted_Cycles(i,:));
    long_real = cat(2, long_real, Test_Quart_Hour(i,:));
   
end

solar_min_array = Daily_Structs.(fields{skip}).solar_min;
[drawdown_predicted] = calc_drawdown_EOF(solar_min_array, Test_Quart_Hour_Times, Predicted_Cycles);

save('C:\Users\cmarchet\Box\JPL\Processed_Data\Predicted_Cycles.mat','Predicted_Cycles','-v7.3')
%%

figure(1)
clf
TOTAL_R2 = r2rmse(long_predicted, long_real)
dscatter(long_predicted.',long_real.')
%scatter(long_predicted, long_real, 3, long_rmse)
refline([1 0])
xlabel('Predicted XCO_2', 'fontsize', 17)
ylabel('Actual XCO_2', 'fontsize', 17)
title(['Actual Versus Predicted XCO_2 at ETL'], 'fontsize', 17)
%print('-djpeg','C:\Users\cmarchet\Box\JPL\slides and figures\model_noprior_log')
colorbar
%%

figure(2)
clf
%Drawdown_Struct.(fields{skip})(idrem2) = [];
drawdown_real = Drawdown_Struct.(fields{skip});
%drawdown_real(nan_struct.(fields{skip}))= [];
R2_DRAWDOWN = r2rmse(drawdown_predicted, drawdown_real);
%drawdown_predicted = drawdown_predicted +.13;
drawdown_predicted = drawdown_predicted + R2_DRAWDOWN.bias;
r2rmse(drawdown_predicted,  drawdown_real)
scatter(drawdown_predicted,  drawdown_real,5, 'filled')
refline([1 0])
xlabel('Predicted Drawdown', 'Fontsize', 17)
ylabel('Actual Drawdown', 'Fontsize', 17)
title(['Actual Versus Predicted XCO_2 Drawdown at ', fields{skip}], 'fontsize', 17)
%colorbar

