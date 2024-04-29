function Daily_Structs = init_sites(varargin)
load Daily_Struct_ETL.mat
load Daily_Struct_Iza.mat
load Daily_Struct_PF.mat
load Daily_Struct_Lauder.mat
load Daily_Struct_Lamont.mat
load Daily_Struct_Nic.mat

Daily_Structs_All.ETL = Daily_Struct_ETL;
Daily_Structs_All.PF = Daily_Struct_PF;
Daily_Structs_All.Nic = Daily_Struct_Nic;
Daily_Structs_All.Iza = Daily_Struct_Iza;
Daily_Structs_All.Lauder = Daily_Struct_Lauder;
Daily_Structs_All.Lamont = Daily_Struct_Lamont;

sites = varargin;

if strcmp(sites{1},'all')
   Daily_Structs = Daily_Structs_All;
else
  for i = 1:length(sites)
      Daily_Structs.(sites{i}) = Daily_Structs_All.(sites{i});
  end

end