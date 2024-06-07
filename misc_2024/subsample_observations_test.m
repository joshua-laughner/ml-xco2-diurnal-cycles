function times_struct = subsample_observations_test(Daily_Structs,varargin)

A.type = 'oco2-3'; %can also do 'self', or 'create'
A.start_times = [];
A.spacings = [];
A.num_obs = 2;
A.min_num_points = 3;
A = parse_pv_pairs(A,varargin);

sites = fieldnames(Daily_Structs);
for loc = 1
    day = 1;
     location_struct = Daily_Structs.(sites{loc});
   
    solmin = location_struct.solar_min(day);
    
times_struct = sample_from_pd_flex(solmin,sites{loc},'type',A.type,'start_times',A.start_times,'spacings',A.spacings,'num_obs',A.num_obs);
end