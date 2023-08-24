%this script takes the TROPOMI files and puts them into a daily array by
%location. I would use the saved .mat file Daily_SIF

ETL_lat = 54.35;
ETL_lon = -104.98;
PF_lat = 45.945;
PF_lon = -90.273;
Lamont_lat = 36.604;
Lamont_lon = -97.486;
Lauder_lat = -45.038;
Lauder_lon = 169.684;
Iza_lat = 28.309;
Iza_lon = -16.4991;
Nic_lat = 35.141;
Nic_lon = 33.381;

ETL_daily_SIF = [];
Lamont_daily_SIF = [];
Lauder_daily_SIF = [];
PF_daily_SIF = [];
Iza_daily_SIF = [];
Nic_daily_SIF = [];

ETL_daily_solzen = [];
Lamont_daily_solzen = [];
Lauder_daily_solzen = [];
PF_daily_solzen = [];
Iza_daily_solzen = [];
Nic_daily_solzen = [];

ETL_daily_dates = [];
Lamont_daily_dates = [];
Lauder_daily_dates = [];
PF_daily_dates = [];
Iza_daily_dates = [];
Nic_daily_dates = [];

year = 2018;
year
for month = 5:12
    month
        cd(['/home/cmarchet/ftp.sron.nl/open-access-data-2/TROPOMI/tropomi/sif/v2.1/l2b/',num2str(year, '%.2d'), '/',num2str(month, '%.2d')]);
       daily_files = dir(['/home/cmarchet/ftp.sron.nl/open-access-data-2/TROPOMI/tropomi/sif/v2.1/l2b/',num2str(year, '%.2d'), '/',num2str(month, '%.2d')]);
        cell_files = struct2cell(daily_files).';

        for day = 3: length(cell_files(:,1))
            
            filename = daily_files(day).name;
            try
            lat = ncread(filename, '/PRODUCT/latitude');
            lon = ncread(filename, '/PRODUCT/longitude');
            SIF = ncread(filename, '/PRODUCT/SIF_735');
            solzen = ncread(filename, '/PRODUCT/SUPPORT_DATA/GEOLOCATIONS/solar_zenith_angle');
            date = ncread(filename, '/PRODUCT/time');
            date = datetime(2010,1,1,0,0,date);
            date.Format = 'yyyy-MM-dd';
            catch
                disp(['weird file i guess',num2str(day)])
                continue
            end
            SIF(SIF > 1000 | SIF < 0 ) = NaN;
            ETL_ind = find(abs(lon- ETL_lon)<1 & abs(lat - ETL_lat) <1);
            if (~(isempty(ETL_ind)))
                ETL_daily_SIF = cat(1,ETL_daily_SIF, mean(SIF(ETL_ind), 'omitnan'));
                ETL_daily_solzen = cat(1,ETL_daily_solzen, mean(solzen(ETL_ind),'omitnan'));
                ETL_daily_dates = cat(1,ETL_daily_dates, date);
            end

            Lamont_ind = find(abs(lon- Lamont_lon)<1 & abs(lat - Lamont_lat) <1);
            if (~(isempty(Lamont_ind)))
               Lamont_daily_SIF = cat(1,Lamont_daily_SIF, mean(SIF(Lamont_ind),'omitnan'));
               Lamont_daily_solzen = cat(1,Lamont_daily_solzen, mean(solzen(Lamont_ind),'omitnan'));
               Lamont_daily_dates = cat(1,Lamont_daily_dates, date);
            end

            Lauder_ind = find(abs(lon- Lauder_lon)<1 & abs(lat - Lauder_lat) <1);
            if (~(isempty(Lauder_ind)))
                Lauder_daily_SIF = cat(1,Lauder_daily_SIF, mean(SIF(Lauder_ind),'omitnan'));
                Lauder_daily_solzen = cat(1,Lauder_daily_solzen, mean(solzen(Lauder_ind),'omitnan'));
                Lauder_daily_dates = cat(1,Lauder_daily_dates, date);
            end

            PF_ind = find(abs(lon- PF_lon)<1 & abs(lat - PF_lat) <1);
            if (~(isempty(PF_ind)))
                PF_daily_SIF = cat(1,PF_daily_SIF, mean(SIF(PF_ind),'omitnan'));
                PF_daily_solzen = cat(1,PF_daily_solzen, mean(solzen(PF_ind),'omitnan'));
                PF_daily_dates = cat(1,PF_daily_dates, date);
            end

            Iza_ind = find(abs(lon- Iza_lon)<1 & abs(lat - Iza_lat) <1);
            if (~(isempty(Iza_ind)))
                Iza_daily_SIF = cat(1,Iza_daily_SIF, mean(SIF(Iza_ind),'omitnan'));
                Iza_daily_solzen = cat(1,Iza_daily_solzen, mean(solzen(Iza_ind),'omitnan'));
                Iza_daily_dates = cat(1,Iza_daily_dates, date);
            end

            Nic_ind = find(abs(lon- Nic_lon)<1 & abs(lat - Nic_lat) <1);
            if (~(isempty(Nic_ind)))
                Nic_daily_SIF = cat(1,Nic_daily_SIF, mean(SIF(Nic_ind),'omitnan'));
                Nic_daily_solzen = cat(1,Nic_daily_solzen, mean(solzen(Nic_ind),'omitnan'));
                Nic_daily_dates = cat(1,Nic_daily_dates, date);
            end

        end
end

for year = 2019:2021
year
for month = 1:12
    month
        cd(['/home/cmarchet/ftp.sron.nl/open-access-data-2/TROPOMI/tropomi/sif/v2.1/l2b/',num2str(year, '%.2d'), '/',num2str(month, '%.2d')]);
       daily_files = dir(['/home/cmarchet/ftp.sron.nl/open-access-data-2/TROPOMI/tropomi/sif/v2.1/l2b/',num2str(year, '%.2d'), '/',num2str(month, '%.2d')]);
        cell_files = struct2cell(daily_files).';

        for day = 3: length(cell_files(:,1))-2
            
            %day
            filename = daily_files(day).name;
            try
            lat = ncread(filename, '/PRODUCT/latitude');
            lon = ncread(filename, '/PRODUCT/longitude');
            SIF = ncread(filename, '/PRODUCT/SIF_735');
            solzen = ncread(filename, '/PRODUCT/SUPPORT_DATA/GEOLOCATIONS/solar_zenith_angle');
            date = ncread(filename, '/PRODUCT/time');
            date = datetime(2010,1,1,0,0,date);
            date.Format = 'yyyy-MM-dd';
            catch
                disp(['weird file i guess',num2str(day)])
                continue
            end
            SIF(SIF > 1000 | SIF < 0) = NaN;
            ETL_ind = find(abs(lon- ETL_lon)<1 & abs(lat - ETL_lat) <1);
            if (~(isempty(ETL_ind)))
                ETL_daily_SIF = cat(1,ETL_daily_SIF, mean(SIF(ETL_ind),'omitnan'));
                ETL_daily_solzen = cat(1,ETL_daily_solzen, mean(solzen(ETL_ind),'omitnan'));
                ETL_daily_dates = cat(1,ETL_daily_dates, date);
            end

            Lamont_ind = find(abs(lon- Lamont_lon)<1 & abs(lat - Lamont_lat) <1);
            if (~(isempty(Lamont_ind)))
               Lamont_daily_SIF = cat(1,Lamont_daily_SIF, mean(SIF(Lamont_ind),'omitnan'));
               Lamont_daily_solzen = cat(1,Lamont_daily_solzen, mean(solzen(Lamont_ind),'omitnan'));
               Lamont_daily_dates = cat(1,Lamont_daily_dates, date);
            end

            Lauder_ind = find(abs(lon- Lauder_lon)<1 & abs(lat - Lauder_lat) <1);
            if (~(isempty(Lauder_ind)))
                Lauder_daily_SIF = cat(1,Lauder_daily_SIF, mean(SIF(Lauder_ind),'omitnan'));
                Lauder_daily_solzen = cat(1,Lauder_daily_solzen, mean(solzen(Lauder_ind),'omitnan'));
                Lauder_daily_dates = cat(1,Lauder_daily_dates, date);
            end

            PF_ind = find(abs(lon- PF_lon)<1 & abs(lat - PF_lat) <1);
            if (~(isempty(PF_ind)))
                PF_daily_SIF = cat(1,PF_daily_SIF, mean(SIF(PF_ind),'omitnan'));
                PF_daily_solzen = cat(1,PF_daily_solzen, mean(solzen(PF_ind),'omitnan'));
                PF_daily_dates = cat(1,PF_daily_dates, date);
            end

             Iza_ind = find(abs(lon- Iza_lon)<1 & abs(lat - Iza_lat) <1);
            if (~(isempty(Iza_ind)))
                Iza_daily_SIF = cat(1,Iza_daily_SIF, mean(SIF(Iza_ind),'omitnan'));
                Iza_daily_solzen = cat(1,Iza_daily_solzen, mean(solzen(Iza_ind),'omitnan'));
                Iza_daily_dates = cat(1,Iza_daily_dates, date);
            end

            Nic_ind = find(abs(lon- Nic_lon)<1 & abs(lat - Nic_lat) <1);
            if (~(isempty(Nic_ind)))
                Nic_daily_SIF = cat(1,Nic_daily_SIF, mean(SIF(Nic_ind),'omitnan'));
                Nic_daily_solzen = cat(1,Nic_daily_solzen, mean(solzen(Nic_ind),'omitnan'));
                Nic_daily_dates = cat(1,Nic_daily_dates, date);
            end

        end
end
end

%%
Daily_SIF.PF.SIF = PF_daily_SIF;
Daily_SIF.PF.solzen = PF_daily_solzen;
Daily_SIF.PF.dates = PF_daily_dates;

Daily_SIF.ETL.SIF = ETL_daily_SIF;
Daily_SIF.ETL.solzen = ETL_daily_solzen;
Daily_SIF.ETL.dates = ETL_daily_dates;

Daily_SIF.Lamont.SIF = Lamont_daily_SIF;
Daily_SIF.Lamont.solzen = Lamont_daily_solzen;
Daily_SIF.Lamont.dates = Lamont_daily_dates;

Daily_SIF.Lauder.SIF = Lauder_daily_SIF;
Daily_SIF.Lauder.solzen = Lauder_daily_solzen;
Daily_SIF.Lauder.dates = Lauder_daily_dates;

Daily_SIF.Iza.SIF = Iza_daily_SIF;
Daily_SIF.Iza.solzen = Iza_daily_solzen;
Daily_SIF.Iza.dates = Iza_daily_dates;

Daily_SIF.Nic.SIF = Nic_daily_SIF;
Daily_SIF.Nic.solzen = Nic_daily_solzen;
Daily_SIF.Nic.dates = Nic_daily_dates;
