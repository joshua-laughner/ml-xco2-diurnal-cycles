%% This is the script that runs the entire process in order, showing all the functions and how to use them and how they feed into eachother

%put in the number of the site we want to skip 
%its alphabetical but just in case
% 1: East Trout Lake   2: Lamont   3: Lauder   4: Park Falls   5: Sodankyla

skip = 4;
filter = 0;
big_subsampled = 0;
%% dont have to re run these every time 
%this takes forever, but for each day its making an array separated by day
%for each parameter. 

Daily_Struct_ETL = make_daily_array('east_trout_lake.nc');
Daily_Struct_Lamont = make_daily_array('lamont.nc');
Daily_Struct_Lauder = make_daily_array('lauder');
Daily_Struct_PF = make_daily_array('pa20040526_20220228.public.qc.nc');
Daily_Struct_Soda = make_daily_array('sodankyla.nc');

%% start from here
%putting variables into quarter hour averages, recording which days get
%thrown out due to too many NaNs in a row
[Quart_Hour_Av_ETL, Tossers_ETL, Daynames_ETL, Quart_Hour_Hours_ETL] = prep_for_EOF(Daily_Struct_ETL);
[Quart_Hour_Av_Lamont, Tossers_Lamont, Daynames_Lamont, Quart_Hour_Hours_Lamont] = prep_for_EOF(Daily_Struct_Lamont);
[Quart_Hour_Av_Lauder, Tossers_Lauder, Daynames_Lauder, Quart_Hour_Hours_Lauder] = prep_for_EOF(Daily_Struct_Lauder);
[Quart_Hour_Av_PF, Tossers_PF, Daynames_PF,Quart_Hour_Hours_PF] = prep_for_EOF(Daily_Struct_PF);
[Quart_Hour_Av_Soda, Tossers_Soda, Daynames_Soda, Quart_Hour_Hours_Soda] = prep_for_EOF(Daily_Struct_Soda);

Quart_Hour_Struct.ETL = Quart_Hour_Av_ETL;
Quart_Hour_Struct.Lamont = Quart_Hour_Av_Lamont;
Quart_Hour_Struct.Lauder = Quart_Hour_Av_Lauder;
Quart_Hour_Struct.PF = Quart_Hour_Av_PF;
Quart_Hour_Struct.Soda = Quart_Hour_Av_Soda;
save('Quart_Hour_Struct.mat', 'Quart_Hour_Struct', '-v7.3')

Quart_Hour_Hours.ETL = Quart_Hour_Hours_ETL;
Quart_Hour_Hours.Lamont = Quart_Hour_Hours_Lamont;
Quart_Hour_Hours.Lauder = Quart_Hour_Hours_Lauder;
Quart_Hour_Hours.PF = Quart_Hour_Hours_PF;
Quart_Hour_Hours.Soda = Quart_Hour_Hours_Soda;
save('Quart_Hour_Hours.mat', 'Quart_Hour_Hours', '-v7.3')

Daynames_Struct.ETL = Daynames_ETL;
Daynames_Struct.Lamont = Daynames_Lamont;
Daynames_Struct.Lauder = Daynames_Lauder;
Daynames_Struct.PF = Daynames_PF;
Daynames_Struct.Soda = Daynames_Soda;
save('Daynames_Struct.mat', 'Daynames_Struct', '-v7.3')

fields = fieldnames(Quart_Hour_Struct);

Quart_Hour_Av_Combo = [];
%making a struct of the quart hour avs for EOF generation (want one big
%array), and keeping out the testing set
for v = 1:length(fields)
    if v == skip
        continue
    end
    
    Quart_Hour_Av_Combo = cat(1, Quart_Hour_Av_Combo, Quart_Hour_Struct.(fields{v}));
end

%creating the number of EOFs that it takes for 95% explained variance
sum_expvar = 0;
num_eofs = 4;
while sum_expvar < 95
    [EOFs_Combo, PCs_Combo, Expvar_Combo] = mycaleof(Quart_Hour_Av_Combo, num_eofs);
    PCs_Combo = PCs_Combo.';
    sum_expvar = sum(Expvar_Combo);
    num_eofs = num_eofs+1;
end

save('PCs_Combo.mat', 'PCs_Combo', '-v7.3')

%taking out the days that got thrown out in quarter hour average generation
[Daily_Struct_ETL] = remove_tossers(Daily_Struct_ETL, Tossers_ETL);
[Daily_Struct_Lamont] = remove_tossers(Daily_Struct_Lamont, Tossers_Lamont );
[Daily_Struct_Lauder] = remove_tossers(Daily_Struct_Lauder, Tossers_Lauder );
[Daily_Struct_PF] = remove_tossers(Daily_Struct_PF, Tossers_PF );
[Daily_Struct_Soda] = remove_tossers(Daily_Struct_Soda, Tossers_Soda );

%calculating real drawdown from TCCON
Drawdown_Struct.ETL = calc_drawdown_real(Daily_Struct_ETL);
Drawdown_Struct.Lamont = calc_drawdown_real(Daily_Struct_Lamont);
Drawdown_Struct.Lauder = calc_drawdown_real(Daily_Struct_Lauder);
Drawdown_Struct.PF = calc_drawdown_real(Daily_Struct_PF);
Drawdown_Struct.Soda = calc_drawdown_real(Daily_Struct_Soda);

save('Actual_Drawdown_Struct.mat', 'Drawdown_Struct', '-v7.3')

%the big subsampling takes every possible subsampling time set. I found
%this unnecessary and it took way longer without changing results. 

if big_subsampled == 1
    % IMPORTANT! IF BIG SUBSAMPLING< MAKE SURE YOU CHANGE THE SKIP SITES
    % LINE
    PCs_all = [];
    [Subsampled_ETL, Hours_Sampled_ETL, Big_Quart_Hour_ETL, PCs_all, PC_ind] = subsample_observations_all(Daily_Struct_ETL, 3, Daynames_Struct.ETL, Quart_Hour_Av_ETL,  1, PCs_all, PCs_Combo, 0);
    [Subsampled_Lamont, Hours_Sampled_Lamont,Big_Quart_Hour_Lamont, PCs_all, PC_ind] = subsample_observations_all(Daily_Struct_Lamont, 3,Daynames_Struct.Lamont, Quart_Hour_Av_Lamont,1, PCs_all, PCs_Combo, PC_ind);
    [Subsampled_Lauder, Hours_Sampled_Lauder,  Big_Quart_Hour_Lauder, PCs_all, PC_ind] = subsample_observations_all(Daily_Struct_Lauder, 3,Daynames_Struct.Lauder, Quart_Hour_Av_Lauder,1, PCs_all, PCs_Combo, PC_ind);
    [Subsampled_PF, Hours_Sampled_PF, Big_Quart_Hour_PF] = subsample_observations_all(Daily_Struct_PF, 3,Daynames_Struct.PF, Quart_Hour_Av_PF, 0);
    [Subsampled_Soda, Hours_Sampled_Soda,Big_Quart_Hour_Soda, PCs_all, PC_ind] = subsample_observations_all(Daily_Struct_Soda, 3,Daynames_Struct.Soda,Quart_Hour_Av_Soda,1, PCs_all, PCs_Combo, PC_ind);

    Big_Quart_Hour_Struct.ETL = Big_Quart_Hour_ETL;
    Big_Quart_Hour_Struct.Lamont = Big_Quart_Hour_Lamont;
    Big_Quart_Hour_Struct.Lauder = Big_Quart_Hour_Lauder;
    Big_Quart_Hour_Struct.PF = Big_Quart_Hour_PF;
    Big_Quart_Hour_Struct.Soda = Big_Quart_Hour_Soda;
else
   [Subsampled_ETL, Hours_Sampled_ETL] = subsample_observations(Daily_Struct_ETL, 3, Daynames_Struct.ETL);
    [Subsampled_Lamont, Hours_Sampled_Lamont] = subsample_observations(Daily_Struct_Lamont, 3,Daynames_Struct.Lamont);
    [Subsampled_Lauder, Hours_Sampled_Lauder] = subsample_observations(Daily_Struct_Lauder, 3,Daynames_Struct.Lauder);
    [Subsampled_PF, Hours_Sampled_PF] = subsample_observations(Daily_Struct_PF, 3,Daynames_Struct.PF);
    [Subsampled_Soda, Hours_Sampled_Soda] = subsample_observations(Daily_Struct_Soda, 3,Daynames_Struct.Soda);
 
end

%adding SIF into each day
%i didn't end up using daily SIF as a feature but i keep it in in case i
%want to
Subsampled_ETL = Daily_SIF_Feature(Subsampled_ETL, Daily_SIF.ETL, Subsampled_ETL.daynames);
Subsampled_Lamont = Daily_SIF_Feature(Subsampled_Lamont, Daily_SIF.Lamont, Subsampled_Lamont.daynames);
Subsampled_Lauder = Daily_SIF_Feature(Subsampled_Lauder, Daily_SIF.Lauder, Subsampled_Lauder.daynames);
Subsampled_PF = Daily_SIF_Feature(Subsampled_PF, Daily_SIF.PF, Subsampled_PF.daynames);
Subsampled_Soda = Daily_SIF_Feature(Subsampled_Soda, Daily_SIF.Soda, Subsampled_Soda.daynames);

Subsampled_ETL = Monthly_SIF_Feature(Subsampled_ETL, Monthly_SIF.ETL, Subsampled_ETL.daynames);
Subsampled_Lamont = Monthly_SIF_Feature(Subsampled_Lamont, Monthly_SIF.Lamont, Subsampled_Lamont.daynames);
Subsampled_Lauder = Monthly_SIF_Feature(Subsampled_Lauder, Monthly_SIF.Lauder, Subsampled_Lauder.daynames);
Subsampled_PF = Monthly_SIF_Feature(Subsampled_PF, Monthly_SIF.PF,Subsampled_PF.daynames);
Subsampled_Soda = Monthly_SIF_Feature(Subsampled_Soda, Monthly_SIF.Soda, Subsampled_Soda.daynames);

Daily_Structs.ETL = Daily_Struct_ETL;
Daily_Structs.Lamont = Daily_Struct_Lamont;
Daily_Structs.Lauder = Daily_Struct_Lauder;
Daily_Structs.PF = Daily_Struct_PF;
Daily_Structs.Soda = Daily_Struct_Soda;
save('Daily_Structs.mat', 'Daily_Structs', '-v7.3')

Subsampled_Struct.ETL = Subsampled_ETL;
Subsampled_Struct.Lamont = Subsampled_Lamont;
Subsampled_Struct.Lauder = Subsampled_Lauder;
Subsampled_Struct.PF = Subsampled_PF;
Subsampled_Struct.Soda = Subsampled_Soda;
save('Subsampled_Struct.mat', 'Subsampled_Struct', '-v7.3')

Subsampled_Combo.xco2 = [];
Subsampled_Combo.azim = [];
Subsampled_Combo.solzen = [];
Subsampled_Combo.temp = [];
Subsampled_Combo.delta_temp = [];
Subsampled_Combo.delta_xco2 = [];
Subsampled_Combo.daily_SIF = [];
Subsampled_Combo.SIF_solzen = [];
Subsampled_Combo.monthly_SIF = [];
Subsampled_Combo.daynames = [];
Subsampled_Combo.delta_solzen = [];

Combo_Drawdown = [];
%making a large feature struct from all the training sites. 
for b = 1:length(fields)
    if b == skip
        continue
    end
    
    Subsampled_Combo.xco2 = cat(1, Subsampled_Combo.xco2, Subsampled_Struct.(fields{b}).xco2);
    Subsampled_Combo.azim = cat(1,Subsampled_Combo.azim, Subsampled_Struct.(fields{b}).azim);
    Subsampled_Combo.solzen = cat(1, Subsampled_Combo.solzen, Subsampled_Struct.(fields{b}).solzen);
    Subsampled_Combo.temp = cat(1, Subsampled_Combo.temp, Subsampled_Struct.(fields{b}).temp);
    Subsampled_Combo.delta_temp = cat(1, Subsampled_Combo.delta_temp, Subsampled_Struct.(fields{b}).delta_temp);
    Subsampled_Combo.delta_xco2 = cat(1, Subsampled_Combo.delta_xco2, Subsampled_Struct.(fields{b}).delta_xco2);
    Subsampled_Combo.daily_SIF = cat(1, Subsampled_Combo.daily_SIF, Subsampled_Struct.(fields{b}).daily_SIF);
    Subsampled_Combo.SIF_solzen = cat(1, Subsampled_Combo.SIF_solzen, Subsampled_Struct.(fields{b}).SIF_solzen);
    Subsampled_Combo.monthly_SIF = cat(1, Subsampled_Combo.monthly_SIF, Subsampled_Struct.(fields{b}).monthly_SIF);
    Subsampled_Combo.daynames = cat(1, Subsampled_Combo.daynames, Subsampled_Struct.(fields{b}).daynames.');
    Subsampled_Combo.delta_solzen = cat(1, Subsampled_Combo.delta_solzen, Subsampled_Struct.(fields{b}).delta_solzen);
    Combo_Drawdown = cat(1, Combo_Drawdown, Drawdown_Struct.(fields{b}).');
end
%big subsampled isn't well carried out throughout this script  because i
%didn't end up using it
if big_subsampled ==1
    Subsampled_Combo.daynames(end+1:end+4) = NaN;
    PCs_all(end+1:end+4,:) = NaN;
    Big_Quart_Hour_PF(end+1,:) = NaN;
end
%run the model starting here
[PC_preds,idrem2] = make_python_regress(PCs_Combo, Subsampled_Combo, Subsampled_Struct.(fields{skip}));


fields = fieldnames(Quart_Hour_Struct);

R2_Struct = struct;
pc_names = fieldnames(PC_preds);

%recording the R2 for the different runs
for pc = 1:length(pc_names)
    for year = 1:45
        R2_Struct.(pc_names{pc}).R2(year) = PC_preds.(pc_names{pc})(year).oobStats.R2;

        R2_Struct.(pc_names{pc}).RMSE(year) = PC_preds.(pc_names{pc})(year).oobStats.RMSE;
    
    end
end

%finding the best run for each PC based on out of bag R2 for that PC
Best_PCs = nan(length(pc_names),length(PC_preds.pc_1(1).oobPred));
Best_Variance = [];
for pc = 1:length(pc_names)
    [~, I] = max(R2_Struct.(pc_names{pc}).R2);
    Best_PCs(pc,:) = PC_preds.(pc_names{pc})(I).oobPred;

end

if big_subsampled == 1
    Test_Quart_Hour = Big_Quart_Hour_Struct.(fields{skip});
    Test_Quart_Hour(idrem2,:) = [];

else
    Test_Quart_Hour = Quart_Hour_Struct.(fields{skip});
    Test_Quart_Hour(idrem2, :) = [];
    Test_Quart_Hour_Times = Quart_Hour_Hours.(fields{skip});
   Test_Quart_Hour_Times(idrem2,:) = [];


end

solar_min_array = Daily_Structs.(fields{skip}).solar_min;
solar_min_array(idrem2) = [];


Predicted_Cycles = nan(length(Best_PCs(1,:)),31);
%making the predicted quarter hour averaged points
for i = 1:length(Best_PCs(1,:))
    Predicted_Cycles(i,:) = EOFs_Combo(1,:).*Best_PCs(1,i) + EOFs_Combo(2,:).*Best_PCs(2,i) + EOFs_Combo(3,:).*Best_PCs(3,i) + EOFs_Combo(4,:).*Best_PCs(4,i)...
        + EOFs_Combo(5,:).*Best_PCs(5,i) + EOFs_Combo(6,:).*Best_PCs(6,i) + EOFs_Combo(7,:).*Best_PCs(7,i) + EOFs_Combo(8,:).*Best_PCs(8,i) + EOFs_Combo(9,:).*Best_PCs(9,i)...
        + EOFs_Combo(10,:).*Best_PCs(10,i) + EOFs_Combo(11,:).*Best_PCs(11,i) + EOFs_Combo(12,:).*Best_PCs(12,i);
end
%calculating drawdown from the created diurnal cycles
[drawdown_predicted] = calc_drawdown_from_curves(solar_min_array, Test_Quart_Hour_Times, Predicted_Cycles);

long_predicted = [];
long_real = [];
long_rmse = [];
for i = 1:31
    long_predicted = cat(1, long_predicted, Predicted_Cycles(:,i));
    long_real = cat(1, long_real, Test_Quart_Hour(:,i));
   
end

%%

figure(1)
clf
TOTAL_R2 = r2rmse(long_predicted, long_real);
dscatter(long_predicted,long_real)
%scatter(long_predicted, long_real, 3, long_rmse)
refline([1 0])
xlabel('Predicted Delta XCO_2', 'fontsize', 17)
ylabel('Actual Delta XCO_2', 'fontsize', 17)
title(['Actual Versus Delta XCO_2 at PF'], 'fontsize', 17)
colorbar

figure(2)
clf
%Drawdown_Struct.(fields{skip})(idrem2) = [];
R2_DRAWDOWN = r2rmse(drawdown_predicted, Drawdown_Struct.(fields{skip}));
drawdown_predicted = drawdown_predicted -.26;
%drawdown_predicted = drawdown_predicted + R2_DRAWDOWN.bias;
r2rmse(drawdown_predicted,  Drawdown_Struct.(fields{skip}))
scatter(drawdown_predicted,  Drawdown_Struct.(fields{skip}),5, 'filled')
refline([1 0])
xlabel('Predicted Drawdown', 'Fontsize', 17)
ylabel('Actual Drawdown', 'Fontsize', 17)
title(['Actual Versus Predicted XCO_2 Drawdown at ', fields{skip}], 'fontsize', 17)
%colorbar
