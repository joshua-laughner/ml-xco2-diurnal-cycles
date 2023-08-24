function process_GEOS_3d(year)
  Longitudes = [-90.273, -104.98, 168.684,-97.486,-16.4991,33.381];
Latitudes = [45.945,54.35,-45.038,36.604,28.309,35.141];
site_acr = ["PF","ETL","Lau","Lam","Iza","Nic"];
time_list = ["0000.V01","0300.V01","0600.V01","0900.V01","1200.V01","1500.V01","1800.V01","2100.V01"];
    total_count = 0;
    for month = 01:12
        for day = 01:eomday(year,month)
            total_count = total_count+1
            filedays(total_count) = datetime(year,month,day);
          %  cd(path)
            path = ['/oco3/ingest/geos5/GEOS5124/',num2str(year),'/',num2str(month,'%02.f'),'/',num2str(day,'%02.f'),'/'];
            filenames = dir(path);
            filenames_names = convertCharsToStrings({filenames(:).name});
            files_3d = filenames_names(contains(filenames_names,'3d_asm'));
           % length(my_day_files)
            for file = 1:8
           %     time_list(file)
                hour_file_3d = files_3d(contains(files_3d,time_list(file)));
                
                if(~isempty(hour_file_3d))
                   full_path = strcat(path,hour_file_3d);
                 
                ncid = netcdf.open(full_path);
                
                varid = netcdf.inqVarID(ncid,'lat');
               lat3d = netcdf.getVar(ncid,varid); 
                varid = netcdf.inqVarID(ncid,'lon');
               lon3d = netcdf.getVar(ncid,varid); 

                varid = netcdf.inqVarID(ncid,'H');
               height = netcdf.getVar(ncid,varid); 
                varid = netcdf.inqVarID(ncid,'PL');
               PL = netcdf.getVar(ncid,varid); 

               netcdf.close(ncid);



           
               for site = 1:length(Longitudes)

                    lon_ind = find(abs(lon3d-Longitudes(site))<1);
                    lat_ind = find(abs(lat3d-Latitudes(site))<1);
                    
                    height_site = nanmean(height(lon_ind,lat_ind),[1 2]);
                    PL_site = nanmean(PL(lon_ind,lat_ind),[1 2]);

                  %  height_ind = findin(500,PL_site);
                   % height_at_500 = height_site(height_ind);
                 
                    %GEOS_Struct_3d.(site_acr{site}).height_500(file,total_count) = height_at_500;
                    GEOS_Struct_3d.(site_acr{site}).height(file,total_count,:) = height_site;
                    GEOS_Struct_3d.(site_acr{site}).PL(file,total_count,:) = PL_site;
                end
                end
            end
        end
    end
    GEOS_Struct_3d.days = filedays;
    Struct_Name = ['GEOS_Struct_3d_',num2str(year),'.mat'];
    save(Struct_Name,'GEOS_Struct_3d','-v7.3')

    close all
    clear 
end