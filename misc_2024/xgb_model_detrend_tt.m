function [PC_preds,MDL,importance] = xgb_model_detrend_tt(PCs,Features,test_indices,start_trees, start_learn, start_gamma,start_depth, start_child,start_subsample,start_lambda, start_alpha,varargin)
%% a machine learning model that predicts the PCs of each day based on the Subsampled TCCON features
%inputs: PCs: principal components for training sites. Size: number of
%days x number of EOFs
%Features: Feature Structure for training sites
%test_features: Feature Structure for testing site

%outputs: array of PC predictions, and index of the days that get thrown
%out for having NaN values

% example: [PC_preds,idrem2] = make_python_regress(PCs_Combo, Subsampled_Combo, Subsampled_Struct.ETL);

 trees  = start_trees;
 lrate = start_learn;
 gamma = start_gamma;
 max_depth = start_depth;
 child_weight = start_child;
 subsample = start_subsample;
 lambda = start_lambda;
 alpha = start_alpha;

 pyenv
 py.importlib.import_module('xgboost');
 py.importlib.import_module('sklearn');


 for ind = 1% can only do 1 i guess
ntrees = trees(randperm(length(trees),1));
    learn = lrate(randperm(length(lrate),1));
    ngamma = gamma(randperm(length(gamma),1));
    ndepth = max_depth(randperm(length(max_depth),1));
    nchild = child_weight(randperm(length(child_weight),1));
    nsubsample = subsample(randperm(length(subsample),1));
    nlambda = lambda(randperm(length(lambda),1));
    nalpha = alpha(randperm(length(alpha),1));
    

MDL = py.xgboost.XGBRegressor(pyargs('n_estimators', int32(ntrees), 'eta', learn, 'gamma', int32(ngamma), 'max_depth', int32(ndepth), 'min_child_weight', int32(nchild), 'subsample', nsubsample, 'lambda', int32(nlambda), 'alpha', int32(nalpha))); 
   
preds = [Features.delta_hour(:),Features.delta_solmin(:),Features.solzen(:,:),Features.delta_solzen(:,:),mean(Features.solzen,2),Features.azim(:,:),Features.delta_azim(:,:)...
    ,mean(Features.azim,2),Features.xco2(:,:), Features.delta_xco2(:),Features.delta_xco2(:),Features.temp(:,:),Features.delta_temp(:), mean(Features.temp,2)...
    ,Features.pressure(:,:),Features.delta_pressure(:),mean(Features.pressure,2), Features.wind_speed(:,:),Features.delta_wind_speed(:),mean(Features.wind_speed,2)...
    ,Features.prior_xco2(:,:),mean(Features.prior_xco2,2), Features.airmass(:,:),Features.delta_airmass(:),mean(Features.airmass,2),Features.xh2o(:,:)...
    ,Features.delta_xh2o(:), mean(Features.xh2o,2),Features.delta_temp_abs(:),Features.delta_temp_reg(:),Features.VPD(:,:),mean(Features.VPD,2)];

target = PCs(setdiff(1:end,test_indices),:); 
full_pred = preds(setdiff(1:end,test_indices),:);
rem = [find(isnan(mean(target,2))); find(isnan(mean(full_pred,2)))]; %getting rid of any nans in my sets. there shouldn't be any
rem = unique(rem); 
target(rem,:) = [];
full_pred(rem,:) = [];

preds_test = preds(test_indices,:);
target_test = target(test_indices,:);
rem = [find(isnan(mean(preds_test,2))); find(isnan(mean(target_test,2)))]; %getting rid of any nans in my sets. there shouldn't be any
rem = unique(rem); 
target_test(rem,:) = [];
preds_test(rem,:) = [];
    
   preds_train = py.numpy.asarray(full_pred); %putting things into python arrays
    target_train = py.numpy.asarray(target);
    preds_test = py.numpy.asarray(preds_test);
    target_test = py.numpy.asarray(target_test);
   

 MDL = MDL.fit(preds_train,target_train); %training model on trainig data
importance = double(MDL.feature_importances_);

  yhat = double(MDL.predict(preds_train)); %having the model do inbag prediction
  y1_oob = double(MDL.predict(preds_test)); %having model to oob prediction
     
   %%all this is now just saving info about the models parameters and training/testing data and the PCs 
     PC_preds(ind).test_data = double(target_test); 
    PC_preds(ind).train_data = double(target_train);
     PC_preds(ind).trees = ntrees;
    PC_preds(ind).learn = learn;
    PC_preds(ind).gamma = ngamma;
    PC_preds(ind).max_depth = ndepth;
    PC_preds(ind).child_weight = nchild;
    PC_preds(ind).subsample = nsubsample;
    PC_preds(ind).lambda = nlambda;
    PC_preds(ind).alpha = nalpha;

  name_list = strings;
  for p = 1:length(PCs(1,:))
  name = ['pc_', num2str(p)];
  name_list(p) = name;
  end
   target_train = double(target_train);
  target_test = double(target_test);
  for i = 1:length(name_list)
   
 
    PC_preds.(name_list{i})(ind).oobPred = y1_oob(:,i); % OOB for PCs
    PC_preds.(name_list{i})(ind).inBagPred = yhat(:,i);
    PC_preds.(name_list{i})(ind).inBagStats = r2rmse(yhat(:,i),target_train(:,i));
    PC_preds.(name_list{i})(ind).oobStats = r2rmse(y1_oob(:,i),target_test(:,i));
   end


 end
 
 
 end
