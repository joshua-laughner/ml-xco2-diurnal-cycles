%% find the solar noon time for each observation based on lat/lon in UTC, and then find the OCO2 observation time with respect to solar noon

%i need to put my dates into a format that the calculator can use
%load C:\Users\cmarchet\Box\JPL\Processed_Data\Crossing_Struct.mat
addpath C:\Users\cmarchet\Documents\ML_Code\Processed_Data
load Crossing_Struct.mat
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

save('C:\Users\cmarchet\Documents\ML_Code\Processed_Data\date_string.mat','date_string')
%%
av_lat = mean(cat(1,[Big_Lite_Struct.oco2_latitude],[Big_Lite_Struct.oco3_latitude]),1);
av_lon = mean(cat(1,[Big_Lite_Struct.oco2_longitude],[Big_Lite_Struct.oco3_longitude]),1);
for i = 1:length(av_lon)
[~,noon] = sunRiseSet(av_lat(i),av_lon(i),0,date_string{i},0);
solar_noon_array(i) = noon;

end
%% checking the solar noon calculator values for PARK FALLS agains the ones
% I got by finding the minimum of the solar zenith parabola

wgs84 = wgs84Ellipsoid("km");
Lon = -90.273; Lat = 45.945;

OCO2_PF_distance = distance(Lat,Lon,[Big_Lite_Struct.oco2_latitude],[Big_Lite_Struct.oco2_longitude],wgs84);
OCO3_PF_distance = distance(Lat,Lon,[Big_Lite_Struct.oco3_latitude],[Big_Lite_Struct.oco3_longitude],wgs84);

within_range = find(OCO2_PF_distance<=1000 & OCO3_PF_distance<=1000); %within ~10 degrees of the site
PF_solar_noon = solar_noon_array(within_range);
PF_dates = [date_string{within_range}];

%some indexes where they're the same (did this manually by matching dates
%up)
TCCON_ind = [1442,1445,1446,1461,1463];
OCO_ind = [1,4];

TCCON_SN = Daily_Struct_PF.solar_min(TCCON_ind);
OCO_SN = PF_solar_noon(OCO_ind)/(60*60); %these are all within half an hour of eachother so I'm saying we're good

%% okay now that I have my values of solar noon (with respect to UTC) i can do some subtraction to see when OCO2 observes a location
% first I need to convert the OCO2 time to the hour of that day, rather
% than the total seconds since Jan 1 1970
for i = 1:15722
    array_dt(i) = datetime(date_string{i});

end
X = convertTo(array_dt,'epochtime','Epoch','1970-01-01');
%%
OCO_seconds_of_day = min([Big_Lite_Struct.oco2_time],[Big_Lite_Struct.oco3_time])-double(X);
OCO_time_wrt_SN = (OCO_seconds_of_day - solar_noon_array)/(60*60); %i'm actually starting on such a terrible foot by not saving anything
OCO_time_wrt_SN(OCO_time_wrt_SN< -24) = OCO_time_wrt_SN(OCO_time_wrt_SN< -24) + 24;
OCO_time_wrt_SN(OCO_time_wrt_SN> 24) = OCO_time_wrt_SN(OCO_time_wrt_SN> 24) -24;


%whoopsies what can I do
%save('C:\Users\cmarchet\Box\JPL\Processed_Data\OCO_time_wrt_SN.mat','OCO_time_wrt_SN')