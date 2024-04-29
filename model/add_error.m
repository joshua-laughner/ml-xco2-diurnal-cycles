function [Subsampled_Struct] = add_error(Subsampled_Struct,Daily_Struct,varargin)
A.type = 'oco2-3';
A.location = 'ETL';
A.error = 0;
A.method = 0; %0 for systematic errors don't cancel, 1 for they do 
A = parse_pv_pairs(A,varargin);

load Uncertainty_Struct.mat
if strcmp(A.location,'Lauder')
    A.location = 'Lau';
elseif strcmp(A.location,'Lamont')
    A.location = 'Lam';
end

SN = Daily_Struct.solar_min;
Uncertainties = Unc_Struct.(A.location);

if A.method ==0
sigma_oco2 = sqrt(0.8^2 + 1/(0.5*Uncertainties.oco2_soundings));
sigma_oco3 = sqrt(0.8^2 + 1/(0.5*Uncertainties.oco3_soundings));
else
    sigma_oco2 = sqrt( 1/(0.5*Uncertainties.oco2_soundings));
    sigma_oco3 = sqrt(1/(0.5*Uncertainties.oco3_soundings));
end
oco2_dist = makedist('Normal','mu',0,'sigma',sigma_oco2);
oco3_dist = makedist('Normal','mu',0,'sigma',sigma_oco3);

if strcmp(A.type,'oco2-3')
for day = 1:size(Subsampled_Struct.xco2,1)
    [~,oco2_ind] = min([Subsampled_Struct.xco2(day,1)-SN(day),Subsampled_Struct.xco2(day,2)-SN(day)]);
    
    for index = 1:2
        if index == oco2_ind
            err = random(oco2_dist);
        else
            err = random(oco3_dist);
        end

        Subsampled_Struct.xco2(day,index) = Subsampled_Struct.xco2(day,index)+err;
    end

   
end
 Subsampled_Struct.delta_xco2 = Subsampled_Struct.xco2(:,2) - Subsampled_Struct.xco2(:,1);
elseif strcmp(A.type,'self')
for day = 1:size(Subsampled_Struct.xco2,1)
    
    
    for index = 1:2
        err = random(oco3_dist);
        Subsampled_Struct.xco2(day,index) = Subsampled_Struct.xco2(day,index)+err;
    end
    
end
 Subsampled_Struct.delta_xco2 = Subsampled_Struct.xco2(:,2) - Subsampled_Struct.xco2(:,1);
else %create your own
    error_dist = makedist('Normal','mu',0,'sigma',A.error);
    
    for day = 1:size(Subsampled_Struct.xco2,1)
    
    
    for index = 1:size(Subsampled_Struct.xco2,2)
        err = random(error_dist);
        Subsampled_Struct.xco2(day,index) = Subsampled_Struct.xco2(day,index)+err;
    end
    for index = 1:size(Subsampled_Struct.xco2,2)-1

        Subsampled_Struct.delta_xco2(day,index) = Subsampled_Struct.xco2(day,index+1) - Subsampled_Struct.xco2(day,index);
    end
    end
end