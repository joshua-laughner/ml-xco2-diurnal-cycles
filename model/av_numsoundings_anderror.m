% script thats finding the average number of soundings per crossing per
% site as well as average uncertainty

Longitudes = [-90.273, -104.98, 168.684,-97.486,-16.4991,33.381,150.879]; %the coordinates of the TCCON sites in order of the names listed
Latitudes = [45.945,54.35,-45.038,36.604,28.309,35.141,-34.406];
site_acr = ["PF","ETL","Lau","Lam","Iza","Nic","Wol"];
%for each site: OCO_2 av uncertainty and av num soundings, OCO_3 same thing
for site = 1:length(Longitudes)
    Unc_Struct.(site_acr(site)).oco2_unc = [];
    Unc_Struct.(site_acr(site)).oco3_unc = [];
    Unc_Struct.(site_acr(site)).oco2_soundings = [];
    Unc_Struct.(site_acr(site)).oco3_soundings = [];

end
for file = 1:10
    filename = ['Big_Lite_Struct_',num2str(file)];
    load(filename)
    av_lat = mean([[Big_Lite_Struct.oco2_latitude];[Big_Lite_Struct.oco3_latitude]],1);
    av_lon = mean([[Big_Lite_Struct.oco2_longitude];[Big_Lite_Struct.oco3_longitude]],1);
    
    for site = 1:6
        lon = Longitudes(site);
        lat = Latitudes(site);
        bool_array = [av_lat>lat-5;av_lat<lat+5;av_lon>lon-4;av_lon<lon+4];
        site_ind = find(all(bool_array,1));
        
        Unc_Struct.(site_acr(site)).oco2_unc = [Unc_Struct.(site_acr(site)).oco2_unc,[Big_Lite_Struct(site_ind).oco2_xco2_uncertainty]];
        Unc_Struct.(site_acr(site)).oco3_unc = [Unc_Struct.(site_acr(site)).oco3_unc,[Big_Lite_Struct(site_ind).oco3_xco2_uncertainty]];
        Unc_Struct.(site_acr(site)).oco2_soundings = [Unc_Struct.(site_acr(site)).oco2_soundings,[Big_Lite_Struct(site_ind).oco2_num_soundings]];
        Unc_Struct.(site_acr(site)).oco3_soundings = [Unc_Struct.(site_acr(site)).oco3_soundings,[Big_Lite_Struct(site_ind).oco3_num_soundings]];
        
    end
end

for site = 1:length(Longitudes)
    names = fieldnames(Unc_Struct.(site_acr(site)));
    for i = 1:length(names)
        Unc_Struct.(site_acr(site)).(names{i}) = nanmean(Unc_Struct.(site_acr(site)).(names{i}));
    end
end

save('C:\Users\cmarchet\Documents\ML_Code\Processed_Data\Uncertainty_Struct.mat','Unc_Struct')