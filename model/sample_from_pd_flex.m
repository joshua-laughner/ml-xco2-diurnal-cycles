function [times_struct] = sample_from_pd_flex(solmin,location,varargin)
A.type = 'oco2-3'; %can also do 'self', or 'create', default is oco2-3
A.start_times = [];
A.spacings = [];
A.num_obs = 2;
A.stdev_st = 0;
A.stdev_sp = 0;
A = parse_pv_pairs(A,varargin);

if strcmp(A.type,'self')
    load Self_PD_Struct.mat
    first_pd = Self_Cross.first;
    %space = Self_Cross.space; keeping this loaded in for proof but 
    %i did it manually

   times_struct.time_1 = random(first_pd) + solmin;

    diff_rand = rand * 893;
    %if diff_rand < 1044  %this isn't the most  science-y way of doing something
     %   times_struct.time2 = times_struct.time_1+ 1.6;
    if diff_rand < 551
        times_struct.time_2 = times_struct.time_1  + 3.2;
    else 
        times_struct.time2 = times_struct.time_1 + 4.9;
    end
  

elseif strcmp(A.type,'create')
    start_rang = max(A.start_times) - min(A.start_times);
    times_struct.time_1 = start_rang*rand+min(A.start_times) + solmin;
    for i = 2:A.num_obs
        space = (max(A.spacings) - min(A.spacings))*rand + min(A.spacings);
        name = ['time_',num2str(i)];
        name_prev = ['time_',num2str(i-1)];
        times_struct.(name) = space+times_struct.(name_prev);
    end

elseif strcmp(A.type,'prob_dist') %making it so start time and spacing  are from the same stdev
    pd_start = makedist('Normal','mu',A.start_times,'sigma',A.stdev_st);
    pd_spacing = makedist('Normal','mu',A.spacings,'sigma',A.stdev_sp);

    times_struct.time_1 = random(pd_start) + solmin;
    space = random(pd_spacing);
    for i = 2:A.num_obs
 
        name = ['time_',num2str(i)];
        name_prev = ['time_',num2str(i-1)];
        times_struct.(name) = space+times_struct.(name_prev);
    end



else % else is the default of oco2-3 crossings
    load PD_Struct.mat
    OCO_pd = PD_Struct.(location).OCO2;
    diff_pd = PD_Struct.(location).diff;

    time = random(OCO_pd);
    lower_prob = length(diff_pd{1,1}.InputData.data)/(length(diff_pd{1,1}.InputData.data)+length(diff_pd{1,2}.InputData.data));
    chance = rand;
    if chance <= lower_prob
        difference = random(diff_pd{1});

    else
        difference = random(diff_pd{2});
    end

    OCO2_time = solmin + time; %for the UTC time, we add the time since solar noon to the time at solar noon
    OCO3_time = OCO2_time + difference; %to get the OCO3 time we add the time since OCO2 to the OCO2 time

    times_struct.time_1 = min(OCO2_time,OCO3_time);
    times_struct.time_2 = max(OCO2_time,OCO3_time);


end