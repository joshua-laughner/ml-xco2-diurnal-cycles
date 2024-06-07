
savepath = 'C:\Users\cmarchet\Documents\ML_Code\Processed_Data\'; %change this to your savepath
addpath(savepath)
addpath 'C:\Users\cmarchet\Documents\ML_Code\Data\'

data_setup_for_model() %change this to a function with inputs and outputs
skippednames = {'ETL','PF','Lauder','Lamont'};
%for bigloop = 1%:2
 bigloop = 1;
skipbool = 1; % are we leaving a site out for testing? turn off when few sites


skip = skippednames{bigloop}; 
%PLACEHOLDER! For growing season sim
badmonths_struct.ETL = [];
badmonths_struct.PF = [];
badmonths_struct.Lamont = [];
badmonths_struct.Lauder = [];
badmonths_struct.Iza = [];
badmonths_struct.Nic = [];


error = [0.01,0.05,0.1,0.2,0.4,0.5,0.8,1];
simnames = {'oco23','idealptp_3pts','idealptp_2pts','idealdraw_3pts','idealdraw_2pts'};
startimes = [0,-3,-1.5,-2.25,-2.25];
spacings = [0,3,4.25,2.25,4.5];
num_obs = [2,3,2,3,2];
type = {'oco2-3','create','create','create','create'};

for sim = 2%:5
    sim
PTP_R2 = nan(1,length(error));
Draw_R2 = nan(1,length(error));


for st = 1:length(error)
st

Daily_Structs = init_sites('all'); %Make sure you call the site names correctly!
%ETL, PF, Lamont, Lauder, Iza, Nic

[Quart_Hour_Struct,Quart_Hour_Hours,Daily_Structs] = prep_for_EOF_detrend_all(Daily_Structs,badmonths_struct);

Subsampled_Struct = subsample_observations_flex(Daily_Structs,'type',type{sim},'start_times',startimes(sim),'num_obs',num_obs(sim),'spacings',spacings(sim));

Subsampled_Struct.(skip) = add_error(Subsampled_Struct.(skip),Daily_Structs.(skip),'type','create','location',skip,'error',error(st));

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

%hyperparameters for model
ntrees_XGB = [800]; %tuning by r2 onyl 2 oxy
learn_XGB = 0.07;%:.01:0.1; %controls how much weights are adjusted each step
gamma_XGB = [0];%defaultm
ndepth_XGB = [8]; %how complex tree can get, how many levels. adding constraing prevents overfitting
nchild_XGB = [8]; %don't understand this one
nsubsample_XGB = 1; %subsampling. which percent used. we already do traiing testing but this adds just a bit more
lambda_XGB = [4]; %regularization term, makes model more conservative
alpha_XGB = [5]; %regularlization term, makes model more conservative

%running da model
for runs = 1:3
runs
[PC_preds,idrem,MODEL,importance,rem,idx] = xgb_model_detrend(PCs_Combo(:,:),Subsampled_Combo,Subsampled_Struct.(skip),ntrees_XGB,learn_XGB,gamma_XGB,ndepth_XGB,nchild_XGB,nsubsample_XGB,lambda_XGB,alpha_XGB);
Test_Quart_Hour = Quart_Hour_Struct.(skip);
 Test_Quart_Hour_Times = Quart_Hour_Hours.(skip);



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
%stacking all the real to predicted day so that I can get the OOB stats for
%the site
long_predicted = [];
long_real = [];
for i = 1:size(Test_Quart_Hour,1)
    long_predicted = cat(2, long_predicted, Predicted_Cycles(i,:));
    long_real = cat(2, long_real, Test_Quart_Hour(i,:));
   
end

TOTAL_R2 = r2rmse(long_predicted, long_real);
actual_drawdown = Test_Quart_Hour(:,22)- Test_Quart_Hour(:,6);
predicted_drawdown = Predicted_Cycles(:,22) - Predicted_Cycles(:,6);
scatter_r2 = r2rmse(predicted_drawdown,actual_drawdown);

ptp_R2(runs)= TOTAL_R2.R2;
draw_R2(runs) = scatter_r2.R2;


PTP_R2(st)= mean(ptp_R2);
Draw_R2(st) = mean(draw_R2);


end
end



Error_Sims.(simnames{sim}).ptp = PTP_R2;
Error_Sims.(simnames{sim}).draw = Draw_R2;
end

save('C:\Users\cmarchet\Documents\ML_Code\Processed_Data\New_Error_Sims.mat','Error_Sims')
%%
error = [0.01,0.05,0.1,0.2,0.4,0.5,0.8,1];
h6 = figure(3);
clf
plot(error,Error_Sims.oco23.ptp,'LineWidth',1.8,'LineStyle','-','Color',[120 40 63]/255);
hold on 
plot(error,Error_Sims.idealptp_3pts.ptp,'LineWidth',2,'LineStyle','-.','Color',[154 49 67]/255);
plot(error,Error_Sims.idealptp_2pts.ptp,'LineWidth',2,'LineStyle','--','Color',[186 75 58]/255);
plot(error,Error_Sims.idealdraw_3pts.ptp,'LineWidth',2.2,'LineStyle',':','Color',[215 87 40]/255);
plot(error,Error_Sims.idealdraw_2pts.ptp,'LineWidth',1.8,'LineStyle','-','Color',[229 106 25]/255);
xticks(error);
xtickangle(45)
set(gca,'XScale','log')
xlim([0 1])
legend('oco2-3','3 pts, ptp','2 pts, ptp', '3 pts, draw','2 pts, draw','location','southwest','fontsize',13)
ylim([0.2 0.805])
%set(h6, 'Units', 'normalized');
%set(h6, 'Position', [0.5, .1, .5, .55]);
set(gca,'FontSize',15)
print('-dtiff','C:\Users\cmarchet\Documents\ML_Code\figures\Paper_Figs\error_sim_prelim\new_log_ptp')

%%
h6 = figure(3);
clf
plot(error,Site_Errors.idealdraw_3pts.ETL_ptp,'LineWidth',1.8,'LineStyle','-','Color','k');
hold on 
plot(error,Site_Errors.idealdraw_3pts.ETL_draw,'LineWidth',1.8,'LineStyle','-','Color',[0.7 0.7 0.7]);
plot(error,Site_Errors.idealdraw_3pts.PF_ptp,'LineWidth',1.8,'LineStyle','-.','Color','k');
plot(error,Site_Errors.idealdraw_3pts.PF_draw,'LineWidth',1.8,'LineStyle','-.','Color',[0.7 0.7 0.7]);
plot(error,Site_Errors.idealdraw_3pts.Lau_ptp,'LineWidth',1.8,'LineStyle','--','Color','k');
plot(error,Site_Errors.idealdraw_3pts.Lau_draw,'LineWidth',1.8,'LineStyle','--','Color',[0.7 0.7 0.7]);
plot(error,Site_Errors.idealdraw_3pts.Lam_ptp,'LineWidth',1.8,'LineStyle',':','Color','k');
plot(error,Site_Errors.idealdraw_3pts.Lam_draw,'LineWidth',1.8,'LineStyle',':','Color',[0.7 0.7 0.7]);
xticks(error);
xtickangle(45)
set(gca,'XScale','log')
xlim([0 0.4])
legend('ETL ptp','ETL draw','PF ptp','PF draw','Lau ptp','Lau draw','Lam ptp','Lam draw','location','southwest','fontsize',10)

%set(h6, 'Units', 'normalized');
%set(h6, 'Position', [0.5, .1, .5, .55]);
print('-dtiff','C:\Users\cmarchet\Documents\ML_Code\figures\Paper_Figs\error_sim_prelim\all_sites')