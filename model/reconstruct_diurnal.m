function [ptp_r2,ptp_rmse,drawdown_r2,drawdown_rmse] = reconstruct_diurnal(y_oob,actual_points)
load EOFs_Combo.mat

Predicted_Cycles = nan(size(y_oob,1),27);
for number = 1:size(y_oob,1)
  Predicted_Cycles(number,:) = zeros(1,27);
 
    for i = 1:7
        %adding each EOF one by one with their weighting to get the output day 
        Predicted_Cycles(number,:) = Predicted_Cycles(number,:)+ EOFs_Combo(i,:).*(y_oob(number,i));
    end
end

long_predicted = [];
long_real = [];
for i = 1:size(actual_points,1)
    long_predicted = cat(2, long_predicted, Predicted_Cycles(i,:));
    long_real = cat(2, long_real, actual_points(i,:));
   
end
actual_drawdown = actual_points(:,22)- actual_points(:,6);
predicted_drawdown = Predicted_Cycles(:,22) - Predicted_Cycles(:,6);

drawdown_stat = r2rmse(predicted_drawdown,actual_drawdown);

drawdown_r2 = drawdown_stat.R2;
drawdown_rmse = drawdown_stat.RMSE;

full_stat = r2rmse(long_predicted,long_real);

ptp_r2 = full_stat.R2;
ptp_rmse = full_stat.RMSE;


end