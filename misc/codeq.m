%% lets try and read in some files
clear all

% change the name based on which computer I'm running things on! \cmarchet
% for JPL and \calla for my silly little laptop

addpath C:\Users\calla\Box\JPL\oco23_matchups_2021\oco23_matchups_2021
names = dir('C:\Users\calla\Box\JPL\oco23_matchups_2021\oco23_matchups_2021');
%%
for i = 4:length(names)
filenames(i-3) = string(names(i).name);

end

big_time_array = [];
for i = 1:length(filenames)
    time_differences = ncread(filenames(i),'mean_oco2_oco3_time_difference');
    big_time_array = cat(1,big_time_array,time_differences);
end


%% making a histogram of the time difference distributions
time_array_hours = big_time_array/(60*60);

%too_short_index = find(abs(time_array_hours)<=1);
%time_array_hours(too_short_index) = [];
nbins = round(max(time_array_hours)-min(time_array_hours));

hist(time_array_hours,nbins*2)
xlabel('mean time difference (hours)')
ylabel('number of crossings')
title('2021 crossing time difference distribution')