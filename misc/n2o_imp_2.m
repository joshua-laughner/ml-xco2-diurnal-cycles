function  [imp, keys] = n2o_imp_2(data,MLR_struct,varname)

nworkers = 12;
%p = gcp('nocreate'); % If no pool, do not create new one.
%if isempty(p)
   %     p = parpool(nworkers);
%else
%end
% all predictors predictors
names = fieldnames(MLR_struct);

% Parallel computing for OOB predictions, predictor importance calculation
options = statset('UseParallel',true);
% Recursive Feature Elimination
for i = 1 : length(names)
    display(['Recursive elimination ',num2str(i),' out of ',num2str(length(names))]);
    % Initialize keys
    if i == 1; keysleft = names; cmb = prednames_n2o(MLR_struct,names); 
    clear stats; clear keys; clear imp; clear idx; 
    else
    cmb = prednames_n2o(MLR_struct,keysleft); % get corresponding names of keys
    end    
    % Build an unbiased tree, selecting all predictors
    t = templateTree('NumVariablesToSample','all',...
        'MinLeafsize',1,'Surrogate','on','PredictorSelection','interaction-curvature');
    Mdl = fitrensemble(cmb,data,'Method','Bag','NumLearningCycles',100, ...
        'Learners',t);
    % Predictor importance calculated via permutation of predictor selection
    imp.OOB{i} = oobPermutedPredictorImportance(Mdl,'Options', options);
    % Predictor importance calculated using the error gain at each predictor split
    imp.gain{i} = predictorImportance(Mdl,'Options', options);
    % take the average score
    imp.total{i}=(imp.OOB{i}+imp.gain{i})/2;
    % Sort everything
    [imp.sortedOOB.des{i}, idx.OOB.des{i}] = sort(imp.OOB{i},'descend');;
    [imp.sortedgain.des{i}, idx.gain.des{i}] = sort(imp.gain{i},'descend');
    [imp.sortedtotal.des{i}, idx.total.des{i}] = sort(imp.total{i},'descend');
    [imp.sortedOOB.as{i}, idx.OOB.as{i}] = sort(imp.OOB{i},'ascend');;
    [imp.sortedgain.as{i}, idx.gain.as{i}] = sort(imp.gain{i},'ascend');
    [imp.sortedtotal.as{i}, idx.total.as{i}] = sort(imp.total{i},'ascend');
    keys.OOB.des{i}=keysleft(idx.OOB.des{i});
    keys.gain.des{i}=keysleft(idx.gain.des{i});
    keys.total.des{i}=keysleft(idx.total.des{i});
    keys.OOB.as{i}=keysleft(idx.OOB.as{i});
    keys.gain.as{i}=keysleft(idx.gain.as{i});
    keys.total.as{i}=keysleft(idx.total.as{i});
    keysleft = keys.total.as{i};
    % Discard worst predictor
    keys.keydiscard{i}=keysleft{1}; % Track which predictor is discarded
    keysleft(1)=[]; % discard
end
    % now run random forest to get the OOB predictions and stats

