%% tuning hyperparameters

ntrees_XGB = 100:100:900; 
learn_XGB = 0.05:.01:0.5; 
gamma_XGB = 0:5;
ndepth_XGB = 1:5; 
nchild_XGB = 1:5;
nsubsample_XGB = 0.9:.01:1;
lambda_XGB = 1:5; 
alpha_XGB = 1:5;

bRMSE_array = nan(10,1);
bPC2_array = nan(10,1);
btrees_array = nan(10,1);
blearn_array = nan(10,1);
bgamma_array = nan(10,1);
bdepth_array = nan(10,1);
bchild_array = nan(10,1);
bsubsample_array = nan(10,1);
blambda_array = nan(10,1);
balpha_array = nan(10,1);

for rounde = 1:10
    rounde
    RMSE_array = nan(10,1);
    PC2_array = nan(10,1);
    trees_array = nan(10,1);
    learn_array = nan(10,1);
    gamma_array = nan(10,1);
    depth_array = nan(10,1);
    child_array = nan(10,1);
    subsample_array = nan(10,1);
    lambda_array = nan(10,1);
    alpha_array = nan(10,1)';
    for run = 1:20
        run
        [PC_preds,idrem] = xgb_model(PCs_Combo(:,:),Subsampled_Combo,Subsampled_Struct.(fields{skip}),ntrees_XGB,learn_XGB,0,ndepth_XGB,nchild_XGB,nsubsample_XGB,lambda_XGB,alpha_XGB);
        
         Test_Quart_Hour = Quart_Hour_Struct.(fields{skip});
        Test_Quart_Hour_Times = Quart_Hour_Hours.(fields{skip});
         pc_names = fieldnames(PC_preds);
        pc_names(1:10) = [];
        for number = 1:length(PC_preds.pc_1(1).oobPred)
            Predicted_Cycles(number,:) = zeros(1,27);
 
             for i = 1:num_eofs-1
                Predicted_Cycles(number,:) = Predicted_Cycles(number,:)+ EOFs_Combo(i,:).*(sign(PC_preds.(pc_names{i}).oobPred(number)).*(10.^(abs(PC_preds.(pc_names{i}).oobPred(number)))-1)) ;%+ EOFs_Combo(2,:).*PCs_Combo(number,2) + EOFs_Combo(3,:).*PCs_Combo(number,3) + EOFs_Combo(4,:).*PCs_Combo(number,4);
             end
             day_mean = nanmean(Predicted_Cycles(number,:));
             Predicted_Cycles(number,:) = Predicted_Cycles(number,:) - day_mean;

             real_mean = nanmean(Test_Quart_Hour(number,:));
             Test_Quart_Hour(number,:) = Test_Quart_Hour(number) - real_mean;
        end
        long_predicted = [];
        long_real = [];
        for i = 1:27
            long_predicted = cat(1, long_predicted, Predicted_Cycles(:,i));
            long_real = cat(1, long_real, Test_Quart_Hour(:,i));
        end
        TOTAL_R2 = r2rmse(long_predicted, long_real);
        RMSE_array(run) = TOTAL_R2.RMSE;
        PC2_array(run) = PC_preds.pc_2.oobStats.R2;
        trees_array(run) = PC_preds.trees;
        learn_array(run) = PC_preds.learn;
        gamma_array(run) = PC_preds.gamma;
        depth_array(run) = PC_preds.max_depth;
        child_array(run) = PC_preds.child_weight;
        subsample_array(run) = PC_preds.subsample;
        lambda_array(run) =PC_preds.lambda;
        alpha_array(run) = PC_preds.alpha;

    end
    % so now we find the lowest few RMSEs, and take the average of the
    % corresponding hyperparameters. we record the averages in an array,
    % and set the new range for the model
    
   [~,sort_index] = sort(RMSE_array);
  %[~,sort_index] = sort(PC2_array,'descend');
    val_rmse = mean(RMSE_array(sort_index(1:3)));
    val_pc2 = mean(PC2_array(sort_index(1:3)));
    val_trees= round(mean(trees_array(sort_index(1:3))),2);
    val_learn =  mean(learn_array(sort_index(1:3)));
    val_gamma =  round(mean(gamma_array(sort_index(1:3))));
    val_depth = round(mean(depth_array(sort_index(1:3))));
    val_child =  round(mean(child_array(sort_index(1:3))));
    val_subsample =  mean(subsample_array(sort_index(1:3)));
    val_lambda = round(mean(lambda_array(sort_index(1:3))));
    val_alpha = round(mean(alpha_array(sort_index(1:3))));

   
    bRMSE_array(rounde) = val_rmse;
    bPC2_array(rounde) = val_pc2;
    btrees_array(rounde) = val_trees;
    blearn_array(rounde) = val_learn;
    bgamma_array(rounde) =val_gamma;
    bdepth_array(rounde) = val_depth;
    bchild_array(rounde) = val_child;
    bsubsample_array(rounde) = val_subsample;
    blambda_array(rounde) = val_lambda;
    balpha_array(rounde) = val_alpha;

    ntrees_XGB = val_trees - 200:100:val_trees+200; 
    if min(ntrees_XGB) <100
        ntrees_XGB = 100:100:val_trees+200;
    end
   
    learn_XGB = val_learn - 0.05:.01:val_learn+0.05; 
    if min(learn_XGB) <0
        learn_XGB = 0.05:.01:val_learn+0.1;
    end

    gamma_XGB = val_gamma - 2:val_gamma+2;
    if min(gamma_XGB)<0
        gamma_XGB = 0:val_gamma+2;
    end

    ndepth_XGB = val_depth -2:val_depth + 2; 
    if min(ndepth_XGB)<0
        ndepth_XGB = 1:val_depth + 2;
    end
   
    nchild_XGB = val_child - 2:val_child+2;
    if min(nchild_XGB)< 0
        nchild_XGB = 0:val_child+2;
    end
   
    nsubsample_XGB = val_subsample-0.05:.01:val_subsample+0.05;
    if max(nsubsample_XGB) >1
        nsubsample_XGB = val_subsample-0.05:0.01:1;
    end

    lambda_XGB = val_lambda - 2:val_lambda+2;
    if min(lambda_XGB)<1
        lambda_XGB = 1:val_lambda+2;

    end
    alpha_XGB = val_alpha-2:val_alpha+2;
    if min(alpha_XGB)<0
        alpha_XGB = 0:val_alpha+2;
    end
end

