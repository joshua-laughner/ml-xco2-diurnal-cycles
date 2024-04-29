%% this script makes a struct of which litefiles and where in the lite files I need to look for crossings

clear all
%addpath /scratch-science2/validation/laughner/oco3-self-matchups/2020/
%addpath /scratch-science2/validation/laughner/oco3-self-matchups/2021/
%names20 = dir('/scratch-science2/validation/laughner/oco3-self-matchups/2020/');
%names21 = dir('/scratch-science2/validation/laughner/oco3-self-matchups/2021/');

addpath C:\Users\cmarchet\Documents\ML_Code\Data\oco3-self-matchups\2020\
addpath C:\Users\cmarchet\Documents\ML_Code\Data\oco3-self-matchups\2021\

names20 = dir('C:\Users\cmarchet\Documents\ML_Code\Data\oco3-self-matchups\2020\');
names21 = dir('C:\Users\cmarchet\Documents\ML_Code\Data\oco3-self-matchups\2021\');

%starting from 4 because dir returns ., .., and a .toml file
for i = 4:length(names20)
filenames(i-3,1) = string(names20(i).name);
end

for i = 4:length(names21)
    filenames = cat(1,filenames,string(names21(i).name));
end

count = 0;
for i = 6:length(filenames) %starting from 6 because I think the first 5 files didn't work, but the 6 isn't significant. 
    i
% reading in the variables for each day
oco3a_sounding_id = ncread(filenames(i),'oco3a_sounding_id'); %this is what i use to find the values in between for the match
oco3b_sounding_id = ncread(filenames(i),'oco3b_sounding_id'); %the OCO3 YYYYMMDDhhmmssmf of each matchup
oco3b_file_index = ncread(filenames(i),'oco3b_file_index'); %we're going to end up concatenating all 3 so this also doesn't super matter

mean_space_distance = ncread(filenames(i),'mean_inter_orbit_distance'); %possibly useful for later if 100km is too large a separation
mean_time_difference = ncread(filenames(i), 'mean_inter_orbit_time_difference'); %a check to make sure my time differences from the sounding ids match

oco3a_lite_file = ncread(filenames(i), 'oco3a_lite_file'); %this will have 1 file
oco3b_lite_file = ncread(filenames(i),'oco3b_lite_file'); %this will have 3 file names

%going through each crossing
for j = 1:size(oco3a_sounding_id,2)
    count = count+1;
    Crossing_Struct(count).oco3a_sounding_id_start = oco3a_sounding_id(1,j);
    Crossing_Struct(count).oco3a_sounding_id_end = oco3a_sounding_id(2,j);
    
    Crossing_Struct(count).oco3b_sounding_id_start = oco3b_sounding_id(1,j);
    Crossing_Struct(count).oco3b_sounding_id_end = oco3b_sounding_id(2,j);
   Crossing_Struct(count).oco3b_file_index_start = oco3b_file_index(1,j); %not super needed
    Crossing_Struct(count).oco3b_file_index_end = oco3b_file_index(2,j); % ^


    Crossing_Struct(count).mean_space_distance = mean_space_distance(j);
    Crossing_Struct(count).mean_time_difference = mean_time_difference(j);

    Crossing_Struct(count).oco3a_lite_file = oco3a_lite_file;
    Crossing_Struct(count).oco3b_lite_file_1 = oco3b_lite_file(1);
    Crossing_Struct(count).oco3b_lite_file_2 = oco3b_lite_file(2);
    Crossing_Struct(count).oco3b_lite_file_3 = oco3b_lite_file(3);
end


end

save('C:\Users\cmarchet\Documents\ML_Code\Processed_Data\Self_Crossing_Struct.mat','Crossing_Struct')