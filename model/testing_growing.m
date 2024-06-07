%% testing the growing season 

clear all
Daily_Structs = init_sites('all');
load Grow_Season.mat

ETL_T = Daily_Structs.PF;
ETL_G = Grow_Season.PF;

growing = find(ETL_G == 1);

ind = randi([1 length(growing)]);
figure(1)
clf
scatter(ETL_T.hours(:,ind),ETL_T.xco2(:,ind))
title(Daily_Structs.PF.days(ind))

nongrowdays = Daily_Structs.PF.days(growing);