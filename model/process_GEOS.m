function process_GEOS(year)
Longitudes = [-90.273, -104.98, 168.684,-97.486,-16.4991,33.381];
Latitudes = [45.945,54.35,-45.038,36.604,28.309,35.141];
site_acr = ["PF","ETL","Lau","Lam","Iza","Nic"];
time_list = ["0000.V01","0300.V01","0600.V01","0900.V01","1200.V01","1500.V01","1800.V01","2100.V01"];


    total_count = 0;
    for month = 01:12
        month
        for day = 01:eomday(year,month)
            total_count = total_count+1
            filedays(total_count) = datetime(year,month,day);
          %  cd(path)
            path = ['/oco3/ingest/geos5/GEOS5124/',num2str(year),'/',num2str(month,'%02.f'),'/',num2str(day,'%02.f'),'/'];
            filenames = dir(path);
            filenames_names = convertCharsToStrings({filenames(:).name});
            my_day_files = filenames_names(contains(filenames_names,'2d'));
           % files_3d = filenames_names(contains(filenames_names,'3d_asm'));
           % length(my_day_files)
            for file = 1:8
              
                hour_file = my_day_files(contains(my_day_files,time_list(file)));
                
                if(~isempty(hour_file))
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

                    lon_ind = find(abs(lon-Longitudes(site))<0.65);
                    lat_ind = find(abs(lat-Latitudes(site))<0.65);
                    
                    wgs84 = wgs84Ellipsoid("km");
                 %   distance_p = distance(Latitudes(site),Longitudes(site),lat(lat_ind),lon(lon_ind),wgs84);
                    pressure_near = pressure(lon_ind,lat_ind);
                    temp_near = temp(lon_ind,lat_ind);
                    humidity_near = humidity(lon_ind,lat_ind);
                    [Lat_mesh, Lon_mesh] = meshgrid(lat(lat_ind),lon(lon_ind));
                   % size(Lon_mesh)
                    %size(temp_near)
                    distances = distance(Latitudes(site),Longitudes(site),Lat_mesh,Lon_mesh,wgs84);
                    distances_inv = 1./distances;

                    temp_site = sum(temp_near.*distances_inv)/sum(distances_inv);
                    pressure_site = sum(pressure_near.*distances_inv)/sum(distances_inv);
                    humidity_site = sum(humidity_near.*distances_inv)/sum(distances_inv);          
                  
                    GEOS_Struct.(site_acr{site}).pressure(file,total_count) = pressure_site;
                    GEOS_Struct.(site_acr{site}).temp(file,total_count) = temp_site;
                    GEOS_Struct.(site_acr{site}).humidity(file,total_count) = humidity_site;


                end
                end
            end
        end
    end
    GEOS_Struct.days = filedays;
    Struct_Name = ['GEOS_Struct_',num2str(year),'.mat'];
    save(Struct_Name,'GEOS_Struct','-v7.3')

    close all
    clear
end