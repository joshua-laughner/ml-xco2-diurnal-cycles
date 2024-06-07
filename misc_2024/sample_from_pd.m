function [time, difference] = sample_from_pd(OCO_pd,diff_pd)
time = random(OCO_pd);
lower_prob = length(diff_pd{1,1}.InputData.data)/(length(diff_pd{1,1}.InputData.data)+length(diff_pd{1,2}.InputData.data));
chance = rand;
if chance <= lower_prob
difference = random(diff_pd{1});

else
difference = random(diff_pd{2});
end




end