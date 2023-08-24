%idk my process or whatever
clear all
addpath /home/cmarchet/Data/
skip = 3;
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
%%
clear all
addpath C:\Users\cmarchet\Box\JPL\Data
addpath C:\Users\cmarchet\Box\JPL\Processed_Data\
skip = 3;
load Daily_Struct_Nic.mat
load Daily_Struct_Iza.mat
load Daily_Struct_PF.mat
load Daily_Struct_Lauder.mat
load Daily_Struct_Lamont.mat
load Daily_Struct_ETL.mat

% then i calculate my targets -- the drawdown values
[Quart_Hour_Av_ETL, Tossers_ETL, Daynames_ETL, Quart_Hour_Hours_ETL,Hourly_Drawdowns_ETL] = calc_hourly_drawdowns(Daily_Struct_ETL);
[Quart_Hour_Av_Lamont, Tossers_Lamont, Daynames_Lamont, Quart_Hour_Hours_Lamont,Hourly_Drawdowns_Lamont] = calc_hourly_drawdowns(Daily_Struct_Lamont);
[Quart_Hour_Av_Lauder, Tossers_Lauder, Daynames_Lauder, Quart_Hour_Hours_Lauder,Hourly_Drawdowns_Lauder] = calc_hourly_drawdowns(Daily_Struct_Lauder);
[Quart_Hour_Av_PF, Tossers_PF, Daynames_PF,Quart_Hour_Hours_PF,Hourly_Drawdowns_PF] = calc_hourly_drawdowns(Daily_Struct_PF);
[Quart_Hour_Av_Iza, Tossers_Iza, Daynames_Iza,Quart_Hour_Hours_Iza,Hourly_Drawdowns_Iza] = calc_hourly_drawdowns(Daily_Struct_Iza);
[Quart_Hour_Av_Nic, Tossers_Nic, Daynames_Nic,Quart_Hour_Hours_Nic,Hourly_Drawdowns_Nic] = calc_hourly_drawdowns(Daily_Struct_Nic);

Drawdown_Struct.ETL = Hourly_Drawdowns_ETL;
Drawdown_Struct.Lamont = Hourly_Drawdowns_Lamont;
Drawdown_Struct.Lauder = Hourly_Drawdowns_Lauder;
Drawdown_Struct.PF = Hourly_Drawdowns_PF;
Drawdown_Struct.Iza = Hourly_Drawdowns_Iza;
Drawdown_Struct.Nic = Hourly_Drawdowns_Nic;

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


%I guess I could make a big struct for the hourly drawdowns as well? Id
%have to leave out the testing site

fields = fieldnames(Quart_Hour_Struct);

[Daily_Struct_ETL] = remove_tossers(Daily_Struct_ETL, Tossers_ETL);
[Daily_Struct_Lamont] = remove_tossers(Daily_Struct_Lamont, Tossers_Lamont );
[Daily_Struct_Lauder] = remove_tossers(Daily_Struct_Lauder, Tossers_Lauder );
[Daily_Struct_PF] = remove_tossers(Daily_Struct_PF, Tossers_PF );
[Daily_Struct_Iza] = remove_tossers(Daily_Struct_Iza, Tossers_Iza);
[Daily_Struct_Nic] = remove_tossers(Daily_Struct_Nic, Tossers_Nic);

%make the probability distributions -- these won't change across runs (most
%likely)

Longitudes = [-90.273, -104.98, 168.684,-97.486,-16.4991,33.381,150.879];
Latitudes = [45.945,54.35,45.038,36.604,28.309,35.141,34.406];
site_names = ["Park Falls", "East Trout Lake", "Lauder", "Lamont", "Izana", "Nicosia","Wollongong"];
site_acr = ["PF","ETL","Lau","Lam","Iza","Nic","Wol"];

for i = 1:length(site_names)
[pd_OCO,pd_diff,time_diff,OCO2_time] = fit_prob_dist(Latitudes(i),Longitudes(i),'fig',0,'site_num',i,'min_diff',0);
PD_Struct.(site_acr{i}).OCO2 = pd_OCO;
PD_Struct.(site_acr{i}).diff = pd_diff;
end

[Subsampled_ETL] = subsample_observations(Daily_Struct_ETL, 3, Daynames_Struct.ETL,PD_Struct.ETL);
[Subsampled_Lamont] = subsample_observations(Daily_Struct_Lamont, 3,Daynames_Struct.Lamont,PD_Struct.Lam);
[Subsampled_Lauder] = subsample_observations(Daily_Struct_Lauder, 3,Daynames_Struct.Lauder,PD_Struct.Lau);
[Subsampled_PF] = subsample_observations(Daily_Struct_PF, 3,Daynames_Struct.PF,PD_Struct.PF);
[Subsampled_Iza] = subsample_observations(Daily_Struct_Iza,3,Daynames_Struct.Iza,PD_Struct.Iza);
[Subsampled_Nic] = subsample_observations(Daily_Struct_Nic,3,Daynames_Struct.Nic,PD_Struct.Nic);

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
save('Subsampled_Struct.mat', 'Subsampled_Struct', '-v7.3')

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
    Combo_Drawdown = cat(1, Combo_Drawdown, Drawdown_Struct.(fields{b}));
end
%%
[Drawdown_preds,idrem2] = drawdown_model(Combo_Drawdown, Subsampled_Combo, Subsampled_Struct.(fields{skip}));

