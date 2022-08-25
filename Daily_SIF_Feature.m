function [Subsampled_Struct] = Daily_SIF_Feature(Subsampled_Struct, SIF_Struct, Struct_Daynames)
    %% Adds the Daily SIF Feature to the Subsampled Feature Struct
    %inputs: Subsampled_Struct: The 3x subsampled features struct. 
    %SIF_Struct is the Daily SIF Struct by location
    %Struct_Daynames is the days corresponding to each row in the
    %subsampled struct

    %ex: Subsampled_ETL = Daily_SIF_Feature(Subsampled_ETL, Daily_SIF.ETL, Subsampled_ETL.daynames);

    Subsampled_Struct.daily_SIF = nan(length(Subsampled_Struct.xco2(:,1)),1);
    Subsampled_Struct.SIF_solzen = nan(length(Subsampled_Struct.xco2(:,1)),1);
    string_dates = string(SIF_Struct.dates);
    for i = 1:length(Struct_Daynames )
        ind = find(string_dates == Struct_Daynames(i));
        if ~isempty(ind)
            Subsampled_Struct.daily_SIF(i) = SIF_Struct.SIF(ind);
            Subsampled_Struct.SIF_solzen(i) = SIF_Struct.solzen(ind);

        end
    end



end