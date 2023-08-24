
Longitudes = [-90.273, -104.98, 168.684,-97.486,-16.4991,33.381,150.879];
Latitudes = [45.945,54.35,45.038,36.604,28.309,35.141,34.406];

[pd_ETL_OCO,pd_ETL_diff,time_diff,OCO2_time] = fit_prob_dist(Latitudes(6),Longitudes(6),'fig',1,'site_num',6,'min_diff',0);
