function [Subsampled_Struct] = calc_VPD(Subsampled_Struct)
q = Subsampled_Struct.GEOS_humidity; %kg/kg
p = Subsampled_Struct.GEOS_pressure; %pa
T = Subsampled_Struct.GEOS_temp; %T
eps = 0.622;

q = q*100; %g/kg
p = p/100;%hPa
T = T -272.15; %C

%these equations are cited in my paper if you want the original sources
r = q./(1-q); %mixing ratio
vpair = p.*(r./(r+eps));
vpsat = 6.112.*exp((17.67*T)./(T + 243.5));

Subsampled_Struct.VPD = vpsat - vpair;






end