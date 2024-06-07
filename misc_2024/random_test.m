% is it all just random? 
%these are based of PF
histfit(PCs_Combo(:,6).',[],'kernel')
title('PC6')
%%
hist1 = fitdist(PCs_Combo(:,1),'Kernel');
hist2 = fitdist(PCs_Combo(:,2),'Kernel');
hist3 = fitdist(PCs_Combo(:,3),'Kernel');
hist4 = fitdist(PCs_Combo(:,4),'Kernel');
hist5 = fitdist(PCs_Combo(:,5),'Kernel');
hist6 = fitdist(PCs_Combo(:,6),'Kernel');
%so now i go through each ETL day, grab each thing, create
stats_array = nan(6,461);
for i = 1:461
stats_array(1,i) = random(hist1);
stats_array(2,i) = random(hist2);
stats_array(3,i) = random(hist3);
stats_array(4,i) = random(hist4);
stats_array(5,i) = random(hist5);
stats_array(6,i) = random(hist6);
end
%%
for number = 1:461
  Predicted_Cycles(number,:) = zeros(1,27);
 
    for i = 1:6
        %adding each EOF one by one with their weighting to get the output
        %day 
        Predicted_Cycles(number,:) = Predicted_Cycles(number,:)+ EOFs_Combo(i,:).*(stats_array(i,number));%+ EOFs_Combo(2,:).*PCs_Combo(number,2) + EOFs_Combo(3,:).*PCs_Combo(number,3) + EOFs_Combo(4,:).*PCs_Combo(number,4);

    end
end
Test_Quart_Hour = Quart_Hour_Struct.ETL;
long_predicted = [];
long_real = [];
for i = 1:size(Quart_Hour_Struct.(skip),1)
    long_predicted = cat(2, long_predicted, Predicted_Cycles(i,:));
    long_real = cat(2, long_real, Test_Quart_Hour(i,:));
   
end

figure(5)
clf
TOTAL_R2 = r2rmse(long_predicted, long_real)
dscatter(long_predicted.',long_real.')
cmocean('thermal')
refline([1 0]) %the 1:1 line
xlabel('Predicted XCO_2', 'fontsize', 17)
ylabel('Actual XCO_2', 'fontsize', 17)
title(['Actual Versus Predicted XCO_2 at ', skip], 'fontsize', 17)
colorbar
%%
randiha = randi([1 461])
scatter(1:27,Predicted_Cycles(randiha,:))