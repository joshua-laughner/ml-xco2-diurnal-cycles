function [Quart_Hour_Av,Quart_Hour_Hours, Subsampled,Daily_Struct,nanind] = detrend_using_prior(Subsampled,Quart_Hour_Av,Quart_Hour_Hours,Daily_Struct)

%first find where the subsampled has nan values and get rid of the
%corresponding quarter hour averaged days, since the model gets rid of them
%anyway

nanind = find(isnan(Subsampled.xco2(:,1)));

[Daily_Struct] = remove_tossers(Daily_Struct, nanind);

Quart_Hour_Av(nanind,:) = [];
Quart_Hour_Hours(nanind,:) = [];
fields = fieldnames(Subsampled);
for i = 1:length(fields)
Subsampled.(fields{i})(nanind,:) = [];

end

