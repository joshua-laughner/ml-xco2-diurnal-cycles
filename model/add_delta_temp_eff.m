function [delta_reg, delta_abs] = add_delta_temp_eff(filename,day_array)
hour = ncread(filename, 'hour');
time = ncread(filename, 'time');
temp  = ncread(filename, 'prior_temperature');
pres = ncread(filename, 'prior_pressure');

calendar_time = datetime(1970,1,1) + seconds(time);
calendar_time.Format = 'yyyy-MM-dd';

for p = 1:length(day_array)
day_index = find(string(calendar_time) == day_array(p)); %finding all the points from that day

day_temp = temp(:,day_index);
day_pres = 1013.25.*pres(:,day_index);
tempday = [];
for i = 1:size(day_pres,2)
ton = day_pres(:,i);
ind1 = findin(700,ton);
val1 = ton(ind1);
ton(ind1) = 0; %need it to grab next closest, ensuring its not this one
ind2 = findin(700,ton);
val2 = ton(ind2);

perca = (700 - val2)/(val1 - val2);
percb = 1-perca;
%i should have linearly interpolated. this is weird. 
tempday(i) = perca*day_temp(ind1,i) + percb*day_temp(ind2,i);
end
  delta_reg(p) = tempday(end)-tempday(1);
  delta_abs(p) = abs(tempday(end)-tempday(1));
end