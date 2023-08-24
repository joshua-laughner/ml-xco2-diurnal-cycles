%% new triple index sort -- matching OCO3s
load /home/cmarchet/Data/Lite_Struct.mat
%load C:\Users\cmarchet\Box\JPL\Processed_Data\Lite_Struct.mat
wgs84 = wgs84Ellipsoid("km");
triple_indexes = {};
count = 0;
for i = 1%:length(Lite_Struct)
    i
    OCO2_difference = [Lite_Struct.OCO3_time] - Lite_Struct(i).OCO2_time; %finding where the OCO3s match both OCO2 and OCO3 in time
    OCO3_difference = [Lite_Struct.OCO3_time] - Lite_Struct(i).OCO3_time;
    finding where the OCO3s match both OCO2 and OCO3 in space
    spatial_difference_2 = distance([Lite_Struct.OCO3_latitude],[Lite_Struct.OCO3_longitude],Lite_Struct(i).OCO2_latitude,Lite_Struct(i).OCO2_longitude,wgs84);
    spatial_difference_3 = distance([Lite_Struct.OCO3_latitude],[Lite_Struct.OCO3_longitude],Lite_Struct(i).OCO3_latitude,Lite_Struct(i).OCO3_longitude,wgs84);

    match_indexes = find(abs(OCO2_difference) <= 86400 & abs(OCO3_difference)<= 86400 & spatial_difference_3 <= 100 & spatial_difference_2 <= 100);
    if length(match_indexes)>1
        count = count+1;
        triple_indexes{count,1} = match_indexes;
        triple_indexes{count,2} = i; %now you know which index has the OCO2 match. 
    end

end

save('/home/cmarchet/Data/triple_indexes_new.mat','triple_indexes','-v7.3')