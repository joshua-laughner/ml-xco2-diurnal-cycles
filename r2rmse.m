function out = statsSY(X,Y,varargin)
A.mode = 'sample';
A=parse_pv_pairs(A,varargin);

X=X(:); Y = Y(:);
idxnnan = find(~isnan(X)&~isnan(Y));
X = X(idxnnan);
Y = Y(idxnnan);

if strcmp(A.mode, 'population')
    N = length(X);
else
    N = length(X)-1;
end


out.Xmean = mean(X); 
out.SSE = sum((X-Y).^2);
out.SSR = sum((Y-out.Xmean).^2);
out.SST = out.SSE + out.SSR; 
out.MSE = out.SSE./N;
out.x_std = std(X(:));
out.y_std = std(Y(:));
out.RMSE = out.MSE.^0.5;
out.R2 = 1.0 - out.SSE./out.SST;
out.bias = sum(Y-X)./length(Y); 

