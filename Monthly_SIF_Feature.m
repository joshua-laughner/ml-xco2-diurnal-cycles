function [Subsampled_Struct] = Monthly_SIF_Feature(Subsampled_Struct, SIF_Struct, Struct_Daynames)
%% function that adds monthly SIF as a feature in the Subsampled Struct
%inputs: Subsampled Struct: Struct of the 3x subsampled TCCON observations
%SIF_Struct: Structure of monthly SIF parsed by TCCON location
%Struct_Daynames: array of dates for each of the subsampled struct rows

%example: Subsampled_ETL = Monthly_SIF_Feature(Subsampled_ETL, Monthly_SIF.ETL, Subsampled_ETL.daynames);

    Subsampled_Struct.monthly_SIF = nan(length(Subsampled_Struct.xco2(:,1)),1);
    years = year(Struct_Daynames);
    months = month(Struct_Daynames);
    month_count = (months - 8) + 12*(years - 2002);
    for i = 1:length(SIF_Struct)
        ind = find(month_count == i);
        Subsampled_Struct.monthly_SIF(ind) = SIF_Struct(i);

    end

end