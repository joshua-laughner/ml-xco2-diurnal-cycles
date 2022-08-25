function [EOFs,pc,expvar] = mycaleof(A,N_eofs)
% => Compute the Nth first EOFs of matrix A(TIME,MAP).
% EOFs is a matrix of the form EOFs(N,MAP), PC is the principal
% components matrix ie it has the form PC(N,TIME) and EXPVAR is
% the fraction of total variance "explained" by each EOF ie it has
% the form EXPVAR(N).
% 2 - A faster "classic" one, same as method 1 but we use the
%     eigs Matlab function.
%
% See also EIG, EIGS, SVD, SVDS
%
% Ref: L. Hartmann: "Objective Analysis" 2002
% Ref: H. Bjornson and S.A. Venegas: "A manual for EOF and SVD - 
%      Analyses of climatic Data" 1997
%================================================================
%  Guillaume MAZE - LPO/LMD - March 2004
%  Revised July 2006
%  gmaze@univ-brest.fr
% Edited by Chad A. Greene of the University of Texas at Austin, Dec 31, 2016.


%% Preprocess: 

% Remove the time mean of each column
A = detrend(A,'constant');

%% Get Covariance Matrix 

% Get dimensions:
[N_timesteps,N_locations] = size(A);

% Get covariance matrix: 
if N_timesteps >= N_locations
   R = A' * A;
else 
   R = A * A';
end

%% Calculate eigenvectors and eigenvalues 
% Eigen analysis of the square covariance matrix

% Temporarily turn off warning because it'll automatically switch to eig for n==N and that's fine:  
warning('off','MATLAB:eigs:TooManyRequestedEigsForRealSym')
[V,D] = eigs(R,N_eofs); % matrix of eigenvectors V and diagonal matrix of eigenvalues D
warning('on','MATLAB:eigs:TooManyRequestedEigsForRealSym')

D(D<0) = 0; % <-This gets rid of complex solutions by assuming any negative eigenvectors are due to rounding error and are nothing more than numerical noise.  

%% 

if N_timesteps < N_locations
   V = A' * V;
   %   sq = (sqrt(diag(L))+eps)';
   sq = (sqrt(diag(D)))';
   sq = sq(ones(1,N_locations),:);
   V = V ./ sq;

   % Get PC by projecting eigenvectors on original data:
   pc = V'*A';
else
   pc = (A*V)';
end

EOFs = V'; 

%% Percent of variance explained by each principal component: 

expvar = 100*(diag(D)./trace(R))'; 

end
