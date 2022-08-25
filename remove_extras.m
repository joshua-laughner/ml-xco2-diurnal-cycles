function [Daily_Struct] = remove_extras(Daily_Struct)
%% function that removes the empty columns that sometimes appear at the end of the Daily_Struct after calling make_daily_array
%input: daily array

    end_num = length(Daily_Struct.days);
    if length(Daily_Struct.xco2(1,:))> end_num
    
        Daily_Struct.xco2(:,end_num+1:end)= [];
        Daily_Struct.solzen(:,end_num+1:end)= [];
        Daily_Struct.azim(:,end_num+1:end)= [];
        Daily_Struct.temp(:,end_num+1:end)= [];
        Daily_Struct.humidity(:,end_num+1:end)= [];
        Daily_Struct.hours(:,end_num+1:end)= [];
        Daily_Struct.pressure(:,end_num+1:end)= [];
        Daily_Struct.pres_alt(:,end_num+1:end)= [];
        Daily_Struct.wind_speed(:,end_num+1:end)= [];
        Daily_Struct.wind_dir(:,end_num+1:end)= [];
        Daily_Struct.mid_trop(:,end_num+1:end)= [];
        Daily_Struct.trop_alt(:,end_num+1:end)= [];
     

     
    end

end