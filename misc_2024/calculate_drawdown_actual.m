function [Drawdown_Struct] = calculate_drawdown_actual(etl,pf,lau,lam,iza,nic)
sitenames = ["ETL",'Lam','Lau','PF','Iza','Nic'];
site_struct.ETL = etl;
site_struct.Lamont = lam;
site_struct.Lauder = lau;
site_struct.PF = pf;
site_struct.Iza = iza;
site_struct.Nic = nic;

names = fieldnames(site_struct);

for i = 1:length(sitenames)
   
    for days = 1:size(site_struct.(names{i}),1)
        Drawdown_Struct.(names{i})(days) = site_struct.(names{i})(days,22) - site_struct.(names{i})(days,6);
    end
end