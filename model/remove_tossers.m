function [Daily_Struct] = remove_tossers(Daily_Struct, tossers)
%% removes the days in the daily_struct that get removed in the quarter hour
%averaging process (so that the eofs and the daily arrays match up)
%inputs: Daily_struct: structure by tccon location of variables separated
%by day
%tossers: indexes of the days thrown out in quarter hour averaging process
%example: [Daily_Struct_ETL] = remove_tossers(Daily_Struct_ETL, Tossers_ETL);

    fields = fieldnames(Daily_Struct);
    for i = 1:length(fields)
        
        if ( i ==5|| i ==6)
               Daily_Struct.(fields{i})(tossers) = [];
               continue
        end
        Daily_Struct.(fields{i})(:,tossers) = [];

    end
    
end