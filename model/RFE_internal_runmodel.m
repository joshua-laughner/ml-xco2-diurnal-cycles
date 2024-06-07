% internal function for RFE that runs the model X number of times and spits
% out the ranking and the r2/rmse of all point to point and of drawdown 

function [importance_array, stats_struct] = RFE_internal_runmodel(preds,test_preds,PCs_Combo,numtimes,actual_points)

trees = 600:100:800; %tuning by r2 onyl 2 oxy
lrate = 0.10:.01:0.15;%:.01:0.1; %controls how much weights are adjusted each step
gamma = 0;%defaultm
max_depth = 8; %how complex tree can get, how many levels. adding constraing prevents overfitting
child_weight = 8; %don't understand this one
subsample = 0.95:0.01:1; %subsampling. which percent used. we already do traiing testing but this adds just a bit more
lambda = [0,1]; %regularization term, makes model more conservative
alpha = [0,1,2]; 

importance_array = nan(numtimes,size(preds,2));
for i = 1:numtimes
    i
ntrees = trees(randperm(length(trees),1));
learn = lrate(randperm(length(lrate),1));
ngamma = gamma(randperm(length(gamma),1));
ndepth = max_depth(randperm(length(max_depth),1));
nchild = child_weight(randperm(length(child_weight),1));
nsubsample = subsample(randperm(length(subsample),1));
nlambda = lambda(randperm(length(lambda),1));
nalpha = alpha(randperm(length(alpha),1));

MDL = py.xgboost.XGBRegressor(pyargs('n_estimators', int32(ntrees), 'eta', learn, 'gamma', int32(ngamma), 'max_depth', int32(ndepth), 'min_child_weight', int32(nchild), 'subsample', nsubsample, 'lambda', int32(nlambda), 'alpha', int32(nalpha))); 

inbagX = preds(:,:); 
inbagY = PCs_Combo(:,:);
rem = [find(isnan(mean(inbagX,2))); find(isnan(mean(inbagY,2)))]; %getting rid of any nans in my sets. there shouldn't be any
rem = unique(rem); 
inbagX(rem,:) = [];
inbagY(rem,:) = [];

m = size(inbagX,1) ;
P = 0.70 ; %train test split. train on 70
idx = randperm(m)  ; %randomly ordering so that I can take 70%
inbagX_train = inbagX(idx(1:round(P*m)),:); %subsamping 70 percent of my data
inbagY_train = inbagY(idx(1:round(P*m)),:);
inbagX_test = inbagX(idx(round(P*m)+1:end),:); %the testing is the remaining 30%
inbagY_test = inbagY(idx(round(P*m)+1:end),:);
   
inbagX_train = py.numpy.asarray(inbagX_train); %putting things into python arrays
inbagY_train = py.numpy.asarray(inbagY_train);
inbagX_test = py.numpy.asarray(inbagX_test);
inbagY_test = py.numpy.asarray(inbagY_test);
   
 a = test_preds; %the excluded site testing data
 idrem2 = find(isnan(mean(a,2))); %checking for nans in my testing site
 a(idrem2,:) = [];
 a = py.numpy.asarray(a);

 MDL = MDL.fit(inbagX_train,inbagY_train);
 perm_importance = py.sklearn.inspection.permutation_importance(MDL,inbagX_test,inbagY_test);
 imp_vals = perm_importance{'importances_mean'};
 imp_vals = double(imp_vals);
 importance_array(i,:) = imp_vals;

 y_oob = double(MDL.predict(a)); %having model predict on a site its never seen before
  %now i gotta get the stats
actual_points_crop = actual_points;
actual_points_crop(idrem2,:) = [];

 [ptp_r2,ptp_rmse,drawdown_r2,drawdown_rmse] = reconstruct_diurnal(y_oob,actual_points_crop);
 
 stats_struct.ptp.r2(i) = ptp_r2;
 stats_struct.ptp.rmse(i) = ptp_rmse;
 stats_struct.drawdown.r2(i) = drawdown_r2;
 stats_struct.drawdown.rmse(i) = drawdown_rmse;
end  
end
  