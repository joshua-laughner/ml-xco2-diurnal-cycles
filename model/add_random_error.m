function error_array = add_random_error(num_points,varargin)
A.type = 'oco2-3'; %can also do 'self'
A.site = 'ETL';
A.stdev = 0;
A.point = 2; %3 for oco3
A = parse_pv_pairs(A,varargin);

%create the standard deviations here 

if strcmp(A.type,'oco2-3')
    load Uncertainty_Struct.mat

elseif strcmp(A.type,'self')
    load Uncertainty_Struct.mat

else %creating our own 
    pd = makedist('Normal','mu',0,'sigma',A.stdev);
    for i = 1:num_points
        error_array(i) = random(pd);
    end

end