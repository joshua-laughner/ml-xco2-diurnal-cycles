function [stats] = rf_ranking_n2o(target,MLR_struct,vars,varargin)

%% Function to create a random forrest based on variables passed through. 
% Build ensemble of regression trees. 
% Note that 'OOBPrediction',’On’ tells TreeBagger to keep track 
% of out of bag data (oob) which will enable you to get statistics on 
% the generalization performance of your model.
   A.nruns = 100;
   A.res = 1;
   A = parse_pv_pairs(A, varargin);

   %% Make training matrix
   id_rem = find(isnan(target));
   id_rem = unique([id_rem]);
   dim = length(target);
   boxes = (360/A.res)*(180./A.res);

   nworkers = 12;
  % p = gcp('nocreate'); % If no pool, do not create new one.
   %if isempty(p)
    %  p = parpool(nworkers);
   %end
   f_train = prednames_n2o(MLR_struct,vars{end});
   f_clim = reshape(f_train,[],length(vars{end}));
   f_clim(id_rem,:) = [];
   id_clim_rem = find(isnan(mean(f_clim,2)));
   %% Vector of possiblilities for leaf and trees
   trees  = [500];
   leaf = [5];

   for idd = 1:length(vars)
     disp(['prediction ' num2str(idd), ' out of ' num2str(length(vars))])
     train = prednames_n2o(MLR_struct,vars{idd});
     clim = reshape(train,[],length(vars{idd}));
     clim(id_rem,:) = []; 
     pred_target = target;    
     pred_target(id_rem,:) = [];
     pred_target(id_clim_rem,:) = [];
     clim(id_clim_rem,:) = [];

     parfor ind  = 1:A.nruns
     timp = templateTree('PredictorSelection','interaction-curvature');
     MdlBag = fitrensemble((clim),pred_target,'Method','Bag',...
          'NumLearningCycles',trees, 'Learners',timp,'CrossVal','off');

     oobPred(:,ind) = oobPredict(MdlBag); % OOB
     inBagPred(:,ind) = predict(MdlBag,clim); % In bag

     oobStats(:,ind) = r2rmse(oobPred(:,ind),pred_target);
     inBagStats(:,ind) = r2rmse(inBagPred(:,ind),pred_target);
     end
    stats.inBag.Xmean(idd,1) = nanmean([inBagStats.Xmean]');
    stats.inBag.SSE(idd,1) = nanmean([inBagStats.SSE]');
    stats.inBag.SSR(idd,1) = nanmean([inBagStats.SSR]');
    stats.inBag.SST(idd,1) = nanmean([inBagStats.SST]');
    stats.inBag.MSE(idd,1) = nanmean([inBagStats.MSE]');
    stats.inBag.x_std(idd,1) = nanmean([inBagStats.x_std]');
    stats.inBag.y_std(idd,1) = nanmean([inBagStats.y_std]');
    stats.inBag.RMSE(idd,1) = nanmean([inBagStats.RMSE]');
    stats.inBag.R2(idd,1) = nanmean([inBagStats.R2]');
    stats.inBag.bias(idd,1) = nanmean([inBagStats.bias]');

    stats.oob.Xmean(idd,1) = nanmean([oobStats.Xmean]');
    stats.oob.SSE(idd,1) = nanmean([oobStats.SSE]');
    stats.oob.SSR(idd,1) = nanmean([oobStats.SSR]');
    stats.oob.SST(idd,1) = nanmean([oobStats.SST]');
    stats.oob.MSE(idd,1) = nanmean([oobStats.MSE]');
    stats.oob.x_std(idd,1) = nanmean([oobStats.x_std]');
    stats.oob.y_std(idd,1) = nanmean([oobStats.y_std]');
    stats.oob.RMSE(idd,1) = nanmean([oobStats.RMSE]');
    stats.oob.R2(idd,1) = nanmean([oobStats.R2]');
    stats.oob.bias(idd,1) = nanmean([oobStats.bias]');

    end
