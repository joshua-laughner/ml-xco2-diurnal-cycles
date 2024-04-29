%% this script makes a struct of which litefiles and where in the lite files I need to look for crossings

clear all
addpath C:\Users\calla\Box\JPL\oco23_matchups_2021\oco23_matchups_2021\
addpath C:\Users\calla\Box\JPL\oco23_matchups_2022\oco23_matchups_2022\
names21 = dir('C:\Users\calla\Box\JPL\oco23_matchups_2021\oco23_matchups_2021');
names22 = dir('C:\Users\calla\Box\JPL\oco23_matchups_2022\oco23_matchups_2022\');

for i = 4:length(names21)
filenames(i-3,1) = string(names21(i).name);
end

for i = 4:length(names22)
    filenames = cat(1,filenames,string(names22(i).name));
end

count = 0;
for i = 1:length(filenames)
    i
% reading in the variables for each day
oco2_sounding_id = ncread(filenames(i),'oco2_sounding_id'); %this is what i use to find the values in between for the match
oco2_file_index = ncread(filenames(i),'oco2_file_index'); %these are going to just be 0, because OCO2 only has one file, but good to have
oco3_sounding_id = ncread(filenames(i),'oco3_sounding_id'); %the OCO3 YYYYMMDDhhmmssmf of each matchup
oco3_file_index = ncread(filenames(i),'oco3_file_index'); %we're going to end up concatenating all 3 so this also doesn't super matter

mean_oco2_oco3_distance = ncread(filenames(i),'mean_oco2_oco3_distance'); %possibly useful for later if 100km is too large a separation
mean_oco2_oco3_time_difference = ncread(filenames(i), 'mean_oco2_oco3_time_difference'); %a check to make sure my time differences from the sounding ids match

oco2_lite_file = ncread(filenames(i), 'oco2_lite_file'); %this will have 1 file
oco3_lite_file = ncread(filenames(i),'oco3_lite_file'); %this will have 3 file names

%going through each crossing
for j = 1:size(oco2_sounding_id,2)
    count = count+1;
    Crossing_Struct(count).oco2_sounding_id_start = oco2_sounding_id(1,j);
    Crossing_Struct(count).oco2_sounding_id_end = oco2_sounding_id(2,j);
    Crossing_Struct(count).oco2_file_index_start = oco2_file_index(1,j); %again, these aren't super needed
    Crossing_Struct(count).oco2_file_index_end = oco2_file_index(2,j); %^
    
    Crossing_Struct(count).oco3_sounding_id_start = oco3_sounding_id(1,j);
    Crossing_Struct(count).oco3_sounding_id_end = oco3_sounding_id(2,j);
    Crossing_Struct(count).oco3_file_index_start = oco3_file_index(1,j); %not super needed
    Crossing_Struct(count).oco3_file_index_end = oco3_file_index(2,j); % ^

    Crossing_Struct(count).mean_oco2_oco3_distance = mean_oco2_oco3_distance(j);
    Crossing_Struct(count).mean_oco2_oco3_time_difference = mean_oco2_oco3_time_difference(j);

    Crossing_Struct(count).oco2_lite_file = oco2_lite_file;
    Crossing_Struct(count).oco3_lite_file_1 = oco3_lite_file(1);
    Crossing_Struct(count).oco3_lite_file_2 = oco3_lite_file(2);
    Crossing_Struct(count).oco3_lite_file_3 = oco3_lite_file(3);
end


end

save('Crossing_Struct.mat','Crossing_Struct')