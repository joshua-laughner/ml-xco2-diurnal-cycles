%% I want to find how often there are 3 observations
% so basically heres the test. For each lite file I'll look at every other
% file and take out the indexes that pass my test
load /home/cmarchet/Data/Lite_Struct.mat

wgs84 = wgs84Ellipsoid("km");
triple_indexes = {};
count = 0;
for i = 1:length(Lite_Struct)
    i
    OCO2_difference = [Lite_Struct.OCO2_time] - Lite_Struct(i).OCO2_time;
    OCO3_difference = [Lite_Struct.OCO3_time] - Lite_Struct(i).OCO3_time;
    spatial_difference_2 = distance([Lite_Struct.OCO2_latitude],[Lite_Struct.OCO2_longitude],Lite_Struct(i).OCO2_latitude,Lite_Struct(i).OCO2_longitude,wgs84);
    spatial_difference_3 = distance([Lite_Struct.OCO3_latitude],[Lite_Struct.OCO3_longitude],Lite_Struct(i).OCO3_latitude,Lite_Struct(i).OCO3_longitude,wgs84);

    match_indexes = find(abs(OCO2_difference) <= 86400 & abs(OCO3_difference)<= 86400 & spatial_difference_3 <= 100 & spatial_difference_2 <= 100);
    if length(match_indexes)>1
        count = count+1;
        triple_indexes{count} = match_indexes;
    end

end

save('/home/cmarchet/Data/triple_indexes.mat','triple_indexes','-v7.3')
