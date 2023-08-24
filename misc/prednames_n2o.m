function  pred_matrix = prednames_n2o(MLR_struct,names,varargin)

%%%% Function, when given predictor names create a matrix of those predictors
%%%% Automatically centers to pacific
  A.shape = 'lat';
  A.dim = 3;
  A = parse_pv_pairs(A, varargin);


  idx = fieldnames(MLR_struct);
  for ind = 1:length(names)
      tmp_idx = find(strcmp(names(ind),idx)); %% i made a change here
      var = MLR_struct.(idx{tmp_idx});
%What is the matrix shape
      matrix(:,ind) = var(:);; 
  end
  pred_matrix = matrix;
