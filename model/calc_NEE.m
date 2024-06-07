%% making a script that calculates NEE from the same time period as GKA
addpath C:\Users\cmarchet\Documents\ML_Code\Data\PF_TCCON\
filenames = dir('C:\Users\cmarchet\Documents\ML_Code\Data\PF_TCCON');
filenames = {filenames.name};
filenames = filenames(3:8);

av_VO2 = [];
delta_xco2 = [];

for i = 1:length(filenames)
    this_file = filenames{i};

    VO2 = ncread(this_file,'column_o2');
    solzen = ncread(this_file, 'solzen');
    xco2 = ncread(this_file,'xco2');
    time = ncread(this_file, 'time');
    hour = ncread(this_file, 'hour');
    qual_f = ncread(this_file,'flag');
    concatenated = [double(qual_f)==9000,double(qual_f)==0];
    qual_ind= find(any(concatenated,2));
   %want only the good quality observations
    VO2 = VO2(qual_ind);
    solzen = solzen(qual_ind);
    xco2 = xco2(qual_ind);
    hour = hour(qual_ind);
    time = time(qual_ind);

    calendar_time = datetime(1970,1,1) + seconds(time);
    calendar_time.Format = 'yyyy-MM-dd';
    unique_dates = unique(string(calendar_time));

    for days = 1:length(unique_dates)
     monthnum = month(unique_dates(days));
     nongrowing_season = [1,2,3,4,10,11,12];
     if ismember(monthnum,nongrowing_season)
         continue
     end
    disp(unique_dates(days))
    day_index = find(string(calendar_time) == unique_dates(days)); 
     xco2_i = xco2(day_index); %grabbing the corresponding values
     hour_i = hour(day_index);
     solzen_i = solzen(day_index);
     vo2_i = VO2(day_index);

    [sorted_hour, sortind] = sort(hour_i);
    solzen_sorted = solzen_i(sortind);

    if length(sorted_hour) < 40
        disp('not enough points')
        continue
    end
    p = polyfit(sorted_hour,solzen_sorted,2);
        
        d1p = polyder(p);                           % First Derivative
        d2p = polyder(d1p);                         % Second Derivative
        ips = roots(d1p);                           % Inflection Points
        xtr = polyval(d2p, ips);                    % Evaluate ‘d2p’ at ‘ips’
        solar_noon = ips((xtr > 0) & (imag(xtr)==0));   % Find Minima %the actual minimum time
       

         %okay so now we can see if there are points within 
    
         try 
         late_point = find(abs(hour_i- (solar_noon+2))<0.25);
         early_point = find(abs(hour_i-(solar_noon-2))<0.25);
         vo2_ind = find(abs(hour_i - solar_noon) < 2);
         catch
             disp('there arent points distributed correctly')
             continue
         end

         if isempty(late_point) || isempty(early_point) 
             disp('empty')
             continue
         end
            
         late_xco2 = mean(xco2_i(late_point));
         early_xco2 = mean(xco2_i(early_point));
         vo2_av = mean(vo2_i(vo2_ind));

        delta_xco2 = cat(1,delta_xco2,late_xco2 - early_xco2);
        av_VO2 = cat(1,av_VO2, vo2_av); 

    end

end
%%
NEE = (av_VO2./(0.20939)).*(delta_xco2./14400);
NEE = (NEE*10^4)/(6.022*10^23);
histogram(NEE)
%%
t1 = datetime(2006,07,24);
t2 = datetime(2006,07,30);
t = t1:t2;
t = t(:);
t.Format = 'yyyy-MM-dd';

x_array = [];
xco2_array = [];

for z = 1:length(t)
  day_index = find(string(calendar_time) == string(t(z))); 
 
  xco2_i = xco2(day_index);
  time_i = time(day_index);
  x_array = cat(1,x_array,time_i);
  xco2_array = cat(1,xco2_array,xco2_i);
end

scatter(x_array,xco2_array,'.')
ylim([374 382])