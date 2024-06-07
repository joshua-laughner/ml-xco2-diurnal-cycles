%% group days by common week
function unq_weeks = groupby_commonweek(daily_struct_array)
unq_weeks = [1];

match_day = daily_struct_array(1);
week_num = 1;
for days = 2:length(daily_struct_array)
if caldays(between(datetime(match_day),datetime(daily_struct_array(days)),'Days'))<=7
unq_weeks = [unq_weeks,week_num];
else
    week_num = week_num+1;
    match_day = daily_struct_array(days);
    unq_weeks = [unq_weeks,week_num];

end
end