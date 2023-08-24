function [r2_pred] = r2_model(r2,Features, start_trees, start_learn, start_gamma,start_depth, start_child,start_subsample,start_lambda, start_alpha,varargin)
%% a machine learning model that predicts the PCs of each day based on the Subsampled TCCON features
%inputs: PCs: principal components for training sites. Size: number of
%days x number of EOFs
%Features: Feature Structure for training sites
%test_features: Feature Structure for testing site

%vargin: 'scale', 1 or 2 or 0
%0: no scale, 1: standardize, 2: normalize. default: 0

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
    

%MDL = py.sklearn.ensemble.RandomForestRegressor(pyargs('n_estimators', int32(ntrees) ,'max_features', 0.9, 'min_samples_leaf', int32(nleaves), 'random_state',int32(0), 'oob_score', py.bool('True'))); 
MDL = py.xgboost.XGBClassifier(pyargs('n_estimators', int32(ntrees), 'eta', learn, 'gamma', int32(ngamma), 'max_depth', int32(ndepth), 'min_child_weight', int32(nchild), 'subsample', nsubsample, 'lambda', int32(nlambda), 'alpha', int32(nalpha))); 
   
ind
%this is the full features set
preds = [Features.xco2(:,:),Features.delta_xco2(:,:),Features.delta_solzen(:,:),Features.solzen(:,:), Features.azim(:,:), Features.temp(:,:), Features.delta_temp(:,:)...
    Features.pressure(:,:), Features.wind_speed(:,:), Features.prior_xh2o(:,:),Features.prior_xco2(:,:),Features.xh2o_error(:,:)...
   Features.airmass(:,:), Features.altitude(:,:), Features.xh2o(:,:), Features.xco2_error(:,:), Features.delta_solmin(:,:), Features.delta_hour(:,:),...
    Features.delta_azim(:,:), Features.delta_pressure(:,:), Features.delta_wind_speed(:,:), Features.delta_airmass(:,:), Features.delta_xh2o(:,:), Features.prior_diff(:,1), Features.detrended_xco2(:,:)]; %, , Features.temp(:,:)Features.trop_alt(:,:), Features.mid_trop_pot_temp(:,:), Features.pres_alt(:,:), ...


target = r2(:); 
full_pred = preds(:,:);
rem = [find(isnan(mean(target,2))); find(isnan(mean(full_pred,2)))];
rem = unique(rem); 
target(rem,:) = [];
full_pred(rem,:) = [];
    
m = size(target,1) ;
P = 0.70 ;
idx = randperm(m)  ;
target_train = target(idx(1:round(P*m)),:); 
preds_train = full_pred(idx(1:round(P*m)),:);
target_test = target(idx(round(P*m)+1:end),:);
preds_test = full_pred(idx(round(P*m)+1:end),:);
   
    preds_train = py.numpy.asarray(preds_train);
    target_train = py.numpy.asarray(target_train);
    preds_test = py.numpy.asarray(preds_test);
    target_test = py.numpy.asarray(target_test);
   


 MDL = MDL.fit(preds_train,target_train);


  yhat = double(MDL.predict(preds_train));
  y1_oob = double(MDL.predict(preds_test));
    target_train = double(target_train);
     target_test = double(target_test);
  
    
     r2_pred(ind).test_data = double(target_test); 
    r2_pred(ind).train_data = double(target_train);
     r2_pred(ind).trees = ntrees;
    r2_pred(ind).learn = learn;
    r2_pred(ind).gamma = ngamma;
    r2_pred(ind).max_depth = ndepth;
    r2_pred(ind).child_weight = nchild;
    r2_pred(ind).subsample = nsubsample;
    r2_pred(ind).lambda = nlambda;
    r2_pred(ind).alpha = nalpha;
     r2_pred(ind).oobPred = y1_oob(:); % OOB for PCs
    r2_pred(ind).inBagPred = yhat(:);
  %  PC_preds.(name_list{i})(ind).train_data = y(:,i); 
    r2_pred(ind).inBagStats = r2rmse(yhat(:),target_train(:));
    r2_pred(ind).oobStats = r2rmse(y1_oob(:),target_test(:));
 

 


 end
 
 
 end
