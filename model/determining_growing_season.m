%make a growing season window knowing trees start growing season by having
%5 days of 5 degree C daily mean, and season ends when the first day has a
%daily mean less than 5C

addpath C:\Users\cmarchet\Documents\ML_Code\Processed_Data
addpath C:\Users\cmarchet\Documents\ML_Code\Data


start_mode.ETL = 0;
start_mode.PF  = 1;
start_mode.Lauder = 1;
start_mode.Lamont = 1;
start_mode.Iza = 1;
start_mode.Nic = 1;


%load Daily_Structs.mat
sites = fieldnames(Daily_Structs);
for site = 1:length(sites)


daily_mean_temp = nanmean(Daily_Structs.(sites{site}).temp,1);
time = datetime(Daily_Structs.(sites{site}).days);

[ft,rmse] = sinefit(time,daily_mean_temp);
y = sineval(ft,time);

grow_array = [];
count = 0;
current_mode = start_mode.(sites{site});
for i = 1:length(time)
    try
        slope  =  y(i+10)-y(i-10) ;
    catch
        try
        slope = y(i) - y(i-10);
        catch
         slope = y(i+10) - y(i);
        end
    end
    if current_mode == 0
        if(daily_mean_temp(i)>5)
            count = count+1;
            if count == 5 && slope > 0
        
                current_mode = 1;
                grow_array(i) = 1;
            else
                grow_array(i) = 0;
            end
        else
            count = 0;
            grow_array(i) = 0;

        end

    else
        if daily_mean_temp(i) <5 && slope < 0
        
             current_mode = 0;
             count = 0;
             grow_array(i) = 0;
        else
            grow_array(i) = 1;
        end

    end

end

Grow_Season.(sites{site}) = grow_array;
end
save('C:\Users\cmarchet\Documents\ML_Code\Processed_Data\Grow_Season.mat','Grow_Season')
%%

load Grow_Season.mat
sites = fieldnames(Daily_Structs);
site = 1;

daily_mean_temp = nanmean(Daily_Structs.(sites{site}).temp,1);
time = datetime(Daily_Structs.(sites{site}).days);
[ft,rmse] = sinefit(time,daily_mean_temp);
y = sineval(ft,time);
figure()
clf
plot(time,y)
hold on
scatter(time,daily_mean_temp,2,'filled')

scatter(time,Grow_Season.ETL*10,10,'filled')
%%
time = Daily_Structs.Iza.days;
time = datetime(time);
temp = Daily_Structs.Iza.temp;
temp = nanmean(temp,1);
figure()
scatter(time,temp,2,'filled')
