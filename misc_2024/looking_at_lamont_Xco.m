%% looking at lamont xco2 and xco

day = randi([1 1965])
day = 1714

figure(1)
clf
yyaxis left
scatter(Lam_Struct_xco.hours(:,day),Lam_Struct_xco.xco2(:,day),3,'filled')
xlim([15 22])
hold on
plot(Lam_Struct_xco.hours(:,day),movmean(Lam_Struct_xco.xco2(:,day),10),'LineWidth',1.25)
ylabel('xco2')
yyaxis right
scatter(Lam_Struct_xco.hours(:,day),Lam_Struct_xco.xco(:,day),3)
plot(Lam_Struct_xco.hours(:,day),movmean(Lam_Struct_xco.xco(:,day),10),'LineWidth',1.25)
xlim([15 22])

ylabel('xco')