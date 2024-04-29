function [time_difference,OCO_time_wrt_SN] = put_crossings_into_UTC
addpath C:\Users\cmarchet\Documents\ML_Code\Processed_Data
load Crossing_Struct.mat
load Lite_Struct.mat
date_array = nan(length(Crossing_Struct),3);
month_names = ["jan";"feb";"mar";"apr";"may";"jun";"jul";"aug";"sep";"oct";"nov";"dec"];

for i = 1:length(Crossing_Struct)
sounding_id = Crossing_Struct(i).oco3_sounding_id_start; %like, close enough right
stringform = num2str(sounding_id);
date_array(i,1) = str2num(stringform(1:4));
date_array(i,2) = str2num(stringform(5:6));
date_array(i,3) = str2num(stringform(7:8));
month_array_separate(i) = month_names(date_array(i,2)); %so annoying but w/e

date_string{i} = strcat(num2str(date_array(i,3)),'-',month_array_separate(i),'-',num2str(date_array(i,1)));
end

%save('C:\Users\cmarchet\Documents\ML_Code\Processed_Data\date_string.mat','date_string')

av_lat = mean(cat(1,[Lite_Struct.OCO2_latitude],[Lite_Struct.OCO3_latitude]),1);
av_lon = mean(cat(1,[Lite_Struct.OCO2_longitude],[Lite_Struct.OCO3_longitude]),1);
for i = 1:length(av_lon)
[~,noon] = sunRiseSet(av_lat(i),av_lon(i),0,date_string{i},0);
solar_noon_array(i) = noon;

end
% okay now that I have my values of solar noon (with respect to UTC) i can do some subtraction to see when OCO2 observes a location
% first I need to convert the OCO2 time to the hour of that day, rather
% than the total seconds since Jan 1 1970
for i = 1:15722
    array_dt(i) = datetime(date_string{i});

end
X = convertTo(array_dt,'epochtime','Epoch','1970-01-01');

OCO_seconds_of_day = [Lite_Struct.OCO2_time]-double(X);
OCO_time_wrt_SN = (OCO_seconds_of_day - solar_noon_array)/(60*60); %i'm actually starting on such a terrible foot by not saving anything
OCO_time_wrt_SN(OCO_time_wrt_SN< -24) = OCO_time_wrt_SN(OCO_time_wrt_SN< -24) + 24;
OCO_time_wrt_SN(OCO_time_wrt_SN> 24) = OCO_time_wrt_SN(OCO_time_wrt_SN> 24) -24;

time_difference = ([Lite_Struct.OCO3_time] - [Lite_Struct.OCO2_time])/(60*60);

save('C:\Users\cmarchet\Box\JPL\Processed_Data\OCO_time_wrt_SN.mat','OCO_time_wrt_SN')
save('C:\Users\cmarchet\Box\JPL\Processed_Data\time_difference.mat','time_difference')