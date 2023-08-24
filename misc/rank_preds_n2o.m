

if(1)
warning('off','all')


  %%% Load in your predictor structure
  %load /data/project1/dclements/Particles/scripts/Flux_Estimates/Flux_1deg/Data/1deg_clim_May2020.mat
%load Subsample_Combo_PF_ind.mat


   %%% Turn all predictors into a matrix
  %tmp_names = fieldnames(Features);
  %for ind = length(tmp_names)-11:length(tmp_names)
  %Features = rmfield(Features,tmp_names{ind});
  %end

  %%%% Here is where I load in my data - this should be your N2O data.
 
  %load pcs_exc_PF.mat
  
  %[z_exp] = export_horizon(zeuph,'type','Euphotic');
  %[global_grid] = surface_data(z_exp,'res', 1);

  %%%% prediction data processing
 % biov_tot = squeeze(y(:,1));
 % biov_tot = biov_tot(:);
 % biov_tot(isinf(biov_tot)) = nan;

 end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% Random Forest %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(1)
data = PCs_Combo(:,1);
pred_struct = One_Col_Struct;
% Random Forest predictions and matrix set up
  
  % This is the script that actually runs the RFE
  [rmse_imp, rmse_keys] =  n2o_imp_2(data(:),pred_struct);
  ranking = flip(rmse_keys.keydiscard);
  for idd = 1:length(rmse_keys.keydiscard)
  vars{idd} = ranking(1:idd);
  end
  [stats_RF] = rf_ranking_n2o(data(:),pred_struct,vars);
  stats_RF.OutOfBag.vars = vars;
  stats_RF.OutOfBag.rank = ranking;
  save('rmse_stats','stats_RF');
end
 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Plotting %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 if(1) 
  filename = 'recursive_OOB_R2';
  figure()
  plot((stats_RF.oob.R2),'.-k','Markersize',12,'Linewidth',2)
  xticks(1:length(rmse_keys.keydiscard))
  xticklabels(stats_RF.OutOfBag.rank)
  xtickangle(90);
  box on
  fig = gcf;
  fig.PaperPosition = [0.3611 2.5833 12 6];
  xlim([0 56])
  set(gca,'TickLabelInterpreter','none')
  title('RMSE OOB R^2')
  print('-dtiff','rmse_oob_rank')
end
   
