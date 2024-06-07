function [Quart_Hour_Av_Struct,Quart_Hour_Hours_Struct, Subsampled_Struct,Daily_Struct_Struct] = cleanup_nans(Subsampled_Struct,Quart_Hour_Av_Struct,Quart_Hour_Hours_Struct,Daily_Struct_Struct)

%first find where the subsampled has nan values and get rid of the
%corresponding quarter hour averaged days, since the model gets rid of them
%anyway
locations = fieldnames(Subsampled_Struct);
for loc= 1: length(locations)
    Subsampled = Subsampled_Struct.(locations{loc});
    Daily_Struct = Daily_Struct_Struct.(locations{loc});
    Quart_Hour_Av = Quart_Hour_Av_Struct.(locations{loc});
    Quart_Hour_Hours = Quart_Hour_Hours_Struct.(locations{loc});

    nanind = find(isnan(Subsampled.xco2(:,1)));

    [Daily_Struct] = remove_tossers(Daily_Struct, nanind);

    Quart_Hour_Av(nanind,:) = [];
    Quart_Hour_Hours(nanind,:) = [];
    fields = fieldnames(Subsampled);
    for i = 1:length(fields)
        if i == length(fields) || i == length(fields) -1
            Subsampled.(fields{i})(nanind) = [];
            continue
        end
        Subsampled.(fields{i})(nanind,:) = [];

    end
    Subsampled_Struct.(locations{loc}) = Subsampled;
    Daily_Struct_Struct.(locations{loc}) = Daily_Struct;
    Quart_Hour_Av_Struct.(locations{loc}) = Quart_Hour_Av;
    Quart_Hour_Hours_Struct.(locations{loc}) = Quart_Hour_Hours;
end
