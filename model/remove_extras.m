function [Daily_Struct] = remove_extras(Daily_Struct)
%% function that removes the empty columns that sometimes appear at the end of the Daily_Struct after calling make_daily_array
%input: daily array

    end_num = length(Daily_Struct.days);
    if length(Daily_Struct.xco2(1,:))> end_num
    
        fieldnames = fields(Daily_Struct);
        for i = 1:length(fieldnames)
            Daily_Struct.(fieldnames{i})(:,end_num+1:end) = [];
        end

     
    end

end