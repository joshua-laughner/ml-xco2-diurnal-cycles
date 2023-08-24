%% a script for the server -- just creating the values of VPD for each tccon location from 
%% GEOS-FPIT
clear all

for year = 2009:2024
    Longitudes = [-90.273, -104.98, 168.684,-97.486,-16.4991,33.381];
Latitudes = [45.945,54.35,-45.038,36.604,28.309,35.141];
site_names = ["Park Falls", "East Trout Lake", "Lauder", "Lamont", "Izana", "Nicosia"];
site_acr = ["PF","ETL","Lau","Lam","Iza","Nic"];

    total_count = 0;
    for month = 01:12
        for day = 01:eomday(year,month)
            total_count = total_count+1
            filedays(total_count) = datetime(year,month,day);
          %  cd(path)
            path = ['/oco3/ingest/geos5/GEOS5124/',num2str(year),'/',num2str(month,'%02.f'),'/',num2str(day,'%02.f'),'/'];
            filenames = dir(path);
            filenames_names = convertCharsToStrings({filenames(:).name});
            my_day_files = filenames_names(contains(filenames_names,'2d'));
           % length(my_day_files)
            for file = 1:length(my_day_files)
              
                hour_file = my_day_files(file);
        
                full_path = strcat(path,hour_file);
                ncid = netcdf.open(full_path);
                
                varid = netcdf.inqVarID(ncid,'PS');
                pressure = netcdf.getVar(ncid,varid); %Pa

                varid = netcdf.inqVarID(ncid,'T10M');
                temp = netcdf.getVar(ncid,varid); %K

                 varid = netcdf.inqVarID(ncid,'QV10M');
                humidity = netcdf.getVar(ncid,varid); %kg/kg
               
                 varid = netcdf.inqVarID(ncid,'lon');
                lon = netcdf.getVar(ncid,varid);
                 varid = netcdf.inqVarID(ncid,'lat');
                lat = netcdf.getVar(ncid,varid);
               netcdf.close(ncid);

                for site = 1:length(Longitudes)

                    lon_ind = find(abs(lon-Longitudes(site))<1);
                    lat_ind = find(abs(lat-Latitudes(site))<1);
                    
                    pressure_site = nanmean(pressure(lon_ind,lat_ind),'all');
                    temp_site = nanmean(temp(lon_ind,lat_ind),'all');
                    humidity_site = nanmean(humidity(lon_ind,lat_ind),'all');
                    % equation from https://earthscience.stackexchange.com/questions/2360/how-do-i-convert-specific-humidity-to-relative-humidity
                    
                    %relative_humidity = 0.263*pressure_site*humidity_site*((exp((17.67*(temp_site-273.16))/(temp_site-29.65)))^-1);

                    % equations from https://physics.stackexchange.com/questions/4343/how-can-i-calculate-vapor-pressure-deficit-from-temperature-and-relative-humidit
                    %saturation vapor pressure es
                    %es = 0.610*exp((17.27 * temp_site) / (temp_site + 237.3));
                    % actual vapor pressure ea
                    %ea = (relative_humidity/ 100) * es;
                    %VPD = ea - es;   
                   
                   % VPD_Struct.(site_acr{site})(file,total_count) = VPD;
                    

                end
            end
        end
    end
    Struct_Name = ['VPD_Struct_',num2str(year),'.mat'];
    save(Struct_Name,'VPD_Struct','-v7.3')


    names_name = ['filenames_',num2str(year),'.mat'];
    save(names_name,"filenames_names",'-v7.3')
    clearvars -except year
    close all
end