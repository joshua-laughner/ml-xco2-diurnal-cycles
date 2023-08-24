function [Drawdown_Preds, idrem2] = drawdown_model(drawdowns,Features, test_features, varargin)
%% a machine learning model that predicts the hourly drawdowns of each day based on the Subsampled TCCON features
%inputs: drawdowns. Size: number of
%days x number of drawdowns (6?)
%Features: Feature Structure for training sites
%test_features: Feature Structure for testing site

%vargin: 'scale', 1 or 2 or 0
%0: no scale, 1: standardize, 2: normalize. default: 0

%outputs: array of drawdowns predictions, and index of the days that get thrown
%out for having NaN values

% example: [PC_preds,idrem2] = make_python_regress(PCs_Combo, Subsampled_Combo, Subsampled_Struct.ETL);



 A.scale = 0;
 A.pred = 0;
 A = parse_pv_pairs(A,varargin);


 if A.scale>0
 disp('Scaling data and features')
 end
 if A.scale ==1
 % scale = 1; Do a standardization
 for i = 1:4
 mn_bv = nanmean(drawdowns(:,i));
 sd_bv = nanstd(drawdowns(:,i));
 
 drawdowns(:,i) = (drawdown(:,i) - mn_bv) ./ sd_bv;
 end


 fields = fieldnames(Features);
 for ind = 1:length(fields)
 Features.(fields{ind}) = (Features.(fields{ind}) - nanmean(Features.(fields{ind})(:)))./...
                            nanstd(Features.(fields{ind})(:));
 test_features.(fields{ind}) = (test_features.(fields{ind}) - nanmean(test_features.(fields{ind})(:)))./...
                            nanstd(test_features.(fields{ind})(:));
 end

  elseif A.scale ==2
  %scale == 2; normalize
  for i = 1:4
  drawdowns(:,i) = (drawdowns(:,i) - min(drawdowns(:,i)))./(max(drawdowns(:,i)) - min(drawdowns(:,i)));
  end
 fields = fieldnames(Features);
 for ind = 1:length(fields)
 Features.(fields{ind}) = (Features.(fields{ind}) - min(Features.(fields{ind})(:)))./...
                           (max(Features.(fields{ind})(:)) - min(Features.(fields{ind})(:)));
 test_features.(fields{ind}) = (test_features.(fields{ind}) - min(test_features.(fields{ind})(:)))./...
                           (max(test_features.(fields{ind})(:)) - min(test_features.(fields{ind})(:)));
 end
 end
 pyenv
 py.importlib.import_module('sklearn');

% py.importlib.import_module('forestci');
 %we could randomize this later
 %MDL = py.sklearn.ensemble.RandomForestRegressor(pyargs('n_estimators', int32(300) , 'random_state',int32(0),'oob_score',py.bool('True'))); 
 
 trees  = [400 500 600 700];
 leaf = [1 2 3 4 5];

 for ind = 1:10
 idx_t = randperm(4,1);
  idx_l = randperm(5,1);
  ntrees = trees(idx_t);
  nleaves = leaf(idx_l);

MDL = py.sklearn.ensemble.RandomForestRegressor(pyargs('n_estimators', int32(ntrees) ,'max_features', 0.9, 'min_samples_leaf', int32(nleaves), 'random_state',int32(0), 'oob_score', py.bool('True'))); 

ind
preds = [Features.xco2(:,:),Features.delta_xco2(:,:),Features.delta_solzen(:,:),Features.solzen(:,:), Features.azim(:,:), Features.temp(:,:), Features.delta_temp(:,:)];%...
  %  Features.pressure(:,:), Features.wind_speed(:,:), Features.prior_xh2o(:,:),Features.prior_xco2(:,:),Features.xh2o_error(:,:)...
  %  Features.airmass(:,:), Features.altitude(:,:), Features.xh2o(:,:), Features.xco2_error(:,:), Features.delta_solmin(:,:), Features.delta_hour(:,:),...
  %  Features.delta_azim(:,:), Features.delta_pressure(:,:), Features.delta_wind_speed(:,:), Features.delta_airmass(:,:), Features.delta_xh2o(:,:), Features.prior_diff(:,1)]; %, , Features.temp(:,:)Features.trop_alt(:,:), Features.mid_trop_pot_temp(:,:), Features.pres_alt(:,:), ...

test_preds = [test_features.xco2(:,:),test_features.delta_xco2(:,:),test_features.delta_solzen(:,:),test_features.solzen(:,:), test_features.azim(:,:), test_features.temp(:,:), test_features.delta_temp(:,:)];%...
   % test_features.pressure(:,:), test_features.wind_speed(:,:), test_features.prior_xh2o(:,:),test_features.prior_xco2(:,:),test_features.xh2o_error(:,:)...
   % test_features.airmass(:,:), test_features.altitude(:,:), test_features.xh2o(:,:), test_features.xco2_error(:,:), test_features.delta_solmin(:,:), test_features.delta_hour(:,:),...
   % test_features.delta_azim(:,:), test_features.delta_pressure(:,:), test_features.delta_wind_speed(:,:), test_features.delta_airmass(:,:), test_features.delta_xh2o(:,:), test_features.prior_diff(:,1)]; %, , Features.temp(:,:)Features.trop_alt(:,:), Features.mid_trop_pot_temp(:,:), Features.pres_alt(:,:), ...

%test_preds = [test_features.xco2(:,:), test_features.delta_xco2(:,:),test_features.monthly_SIF(:),test_features.delta_solzen(:,:), test_features.solzen(:,:), test_features.azim(:,:), test_features.temp(:,:), test_features.delta_temp(:,:)];

 x = preds;
 %y = [p1(:), p2(:), p3(:), p4(:)];
 y = drawdowns;

 a = test_preds;

 idrem = unique([find(isnan(mean(y,2))); find(isnan(mean(x,2)))]);
 x(idrem,:) = [];
 y(idrem,:) = [];

 idrem2 = find(isnan(mean(a,2)));
 
 a(idrem2,:) = [];

% class(x)
% class(y)

 MDL = MDL.fit(x,y);
 
% tree = MDL.estimators_(1)
 %class(tree)
%py.sklearn.tree.plot_tree(tree)

 yhat = MDL.predict(x);
 yhat = double(yhat);
 y_oob = double(MDL.predict(a));
 y1_oob = double(MDL.oob_prediction_);
 %Variance = py.forestci.random_forest_error(MDL, x,a);
  %y_oob = double(MDL.predict(a));

  name_list = strings;
  for p = 1:length(drawdowns(1,:))
  name = ['pc_', num2str(p)];
  name_list(p) = name;
  end
  for i = 1:length(name_list)
   
  
    Drawdown_Preds.(name_list{i})(ind).oobPred = y_oob(:,i); % OOB for PCs
    Drawdown_Preds.(name_list{i})(ind).inBagPred = yhat(:,i);
    Drawdown_Preds.(name_list{i})(ind).train_data = y(:,i); 
    Drawdown_Preds.(name_list{i})(ind).inBagStats = r2rmse(yhat(:,1),y(:,1));
    Drawdown_Preds.(name_list{i})(ind).oobStats = r2rmse(y1_oob(:,1),y(:,1));
    %PC_preds.(name_list{i})(ind).variance = Variance(:,i);
  end


 end
 
 
 end
