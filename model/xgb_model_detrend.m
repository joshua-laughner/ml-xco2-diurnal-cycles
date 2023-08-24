function [PC_preds, idrem2,MDL] = xgb_model_detrend(PCs,Features, test_features, start_trees, start_learn, start_gamma,start_depth, start_child,start_subsample,start_lambda, start_alpha,varargin)
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
   
%ind
%this is the full features set
%preds = [Features.xco2(:,:),Features.delta_xco2(:,:),Features.delta_solzen(:,:),Features.solzen(:,:), Features.azim(:,:), Features.temp(:,:), Features.delta_temp(:,:)...
 %   Features.pressure(:,:), Features.wind_speed(:,:), Features.prior_xh2o(:,:),Features.prior_xco2(:,:),Features.xh2o_error(:,:)...
 %   Features.airmass(:,:), Features.altitude(:,:), Features.xh2o(:,:), Features.xco2_error(:,:), Features.delta_solmin(:,:), Features.delta_hour(:,:),...
 %   Features.delta_azim(:,:), Features.delta_pressure(:,:), Features.delta_wind_speed(:,:), Features.delta_airmass(:,:), Features.delta_xh2o(:,:), Features.prior_diff(:,1),Features.VPD(:,:),Features.GEOS_humidity(:,:)]; %, , Features.temp(:,:)Features.trop_alt(:,:), Features.mid_trop_pot_temp(:,:), Features.pres_alt(:,:), ...

%this is a simplified features set
preds = [Features.xco2(:,:),Features.delta_xco2(:,:), Features.delta_solzen(:,:),Features.solzen(:,:),Features.azim(:,:), Features.delta_hour(:,:),...
   Features.delta_solmin(:,:),Features.delta_azim(:,:),Features.temp(:,:),Features.delta_temp(:,:),Features.VPD(:,:)];

test_preds = [test_features.xco2(:,:),test_features.delta_xco2(:,:), test_features.delta_solzen(:,:),test_features.solzen(:,:),test_features.azim(:,:),test_features.delta_hour(:,:),...
  test_features.delta_solmin(:,:),test_features.delta_azim(:,:),test_features.temp(:,:),test_features.delta_temp(:,:),test_features.VPD(:,:)];

%test_preds = [test_features.xco2(:,:),test_features.delta_xco2(:,:),test_features.delta_solzen(:,:),test_features.solzen(:,:), test_features.azim(:,:), test_features.temp(:,:), test_features.delta_temp(:,:)...
 %  test_features.pressure(:,:), test_features.wind_speed(:,:), test_features.prior_xh2o(:,:),test_features.prior_xco2(:,:),test_features.xh2o_error(:,:)...
 %   test_features.airmass(:,:), test_features.altitude(:,:), test_features.xh2o(:,:), test_features.xco2_error(:,:), test_features.delta_solmin(:,:), test_features.delta_hour(:,:),...
 %   test_features.delta_azim(:,:), test_features.delta_pressure(:,:), test_features.delta_wind_speed(:,:), test_features.delta_airmass(:,:), test_features.delta_xh2o(:,:), test_features.prior_diff(:,1),test_features.VPD(:,:),test_features.GEOS_humidity(:,:)]; %, , Features.temp(:,:)Features.trop_alt(:,:), Features.mid_trop_pot_temp(:,:), Features.pres_alt(:,:), ...

 %just delta xco2 --- bad
 %preds = [Features.delta_xco2(:,:), Features.delta_solzen(:,:),Features.solzen(:,:),Features.azim(:,:), Features.delta_hour(:,:),...
 %  Features.delta_solmin(:,:),Features.delta_azim(:,:),Features.temp(:,:),Features.delta_temp(:,:),Features.VPD(:,:)];

%test_preds = [test_features.delta_xco2(:,:), test_features.delta_solzen(:,:),test_features.solzen(:,:),test_features.azim(:,:),test_features.delta_hour(:,:),...
 % test_features.delta_solmin(:,:),test_features.delta_azim(:,:),test_features.temp(:,:),test_features.delta_temp(:,:),test_features.VPD(:,:)];


target = PCs(:,:); 
full_pred = preds(:,:);
rem = [find(isnan(mean(target,2))); find(isnan(mean(full_pred,2)))]; %getting rid of any nans in my sets. there shouldn't be any
rem = unique(rem); 
target(rem,:) = [];
full_pred(rem,:) = [];
    
m = size(target,1) ;
P = 0.70 ; %train test split. train on 70
idx = randperm(m)  ; %randomly ordering so that I can take 70%
target_train = target(idx(1:round(P*m)),:); %subsamping 70 percent of my data
preds_train = full_pred(idx(1:round(P*m)),:);
target_test = target(idx(round(P*m)+1:end),:); %the testing is the remaining 30%
preds_test = full_pred(idx(round(P*m)+1:end),:);
   
    preds_train = py.numpy.asarray(preds_train); %putting things into python arrays
    target_train = py.numpy.asarray(target_train);
    preds_test = py.numpy.asarray(preds_test);
    target_test = py.numpy.asarray(target_test);
   
 a = test_preds; %the excluded site testing data
 idrem2 = find(isnan(mean(a,2))); %checking for nans in my testing site
 a(idrem2,:) = [];

 a = py.numpy.asarray(a);

 MDL = MDL.fit(preds_train,target_train); %training model on trainig data

  yhat = double(MDL.predict(preds_train)); %having the model do inbag prediction
  y1_oob = double(MDL.predict(preds_test)); %having model to oob prediction
     y_oob = double(MDL.predict(a)); %having model predict on a site its never seen before
    
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
   
 
    PC_preds.(name_list{i})(ind).oobPred = y_oob(:,i); % OOB for PCs
    PC_preds.(name_list{i})(ind).inBagPred = yhat(:,i);
    PC_preds.(name_list{i})(ind).inBagStats = r2rmse(yhat(:,i),target_train(:,i));
    PC_preds.(name_list{i})(ind).oobStats = r2rmse(y1_oob(:,i),target_test(:,i));
   end


 end
 
 
 end