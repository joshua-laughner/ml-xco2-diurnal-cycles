function [Subsampled_Struct] = add_delta_temp(Subsampled_Struct,dates,sitename)

delta_abs = nan(1,length(dates));
delta_reg = nan(1,length(dates));
if strcmp(sitename,'lauder.nc')
    for i = 1:length(dates)
        if isbetween(datetime(dates(i)),datetime('2004-06-28'),datetime('2010-02-19'))
              [tempday,~] = extract_temp_700hpa('lauder01.nc',dates(i));
        elseif isbetween(datetime(dates(i)),datetime('2013-01-02'),datetime('2018-09-30'))
              [tempday,~] = extract_temp_700hpa('lauder02.nc',dates(i));
        else
              [tempday,~] = extract_temp_700hpa('lauder03.nc',dates(i));
        end
    delta_reg(i) = tempday(end)-tempday(1);
    delta_abs(i) = abs(tempday(end)-tempday(1));

    end
    Subsampled_Struct.delta_temp_abs = delta_abs;
    Subsampled_Struct.delta_temp_reg = delta_reg;
else
for i = 1:length(dates)
[tempday,~] = extract_temp_700hpa(sitename,dates(i));
delta_reg(i) = tempday(end)-tempday(1);
delta_abs(i) = abs(tempday(end)-tempday(1));

end
Subsampled_Struct.delta_temp_abs = delta_abs;
Subsampled_Struct.delta_temp_reg = delta_reg;
end
