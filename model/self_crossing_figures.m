%% Selfing season figures
savepath = 'C:\Users\cmarchet\Documents\ML_Code\figures\Paper_Figs\self_crossing_sim\';

%first we make the combined things
inbag_p_big = [];
inbag_r_big =[];
oob_p_big= [];
oob_r_big = [];
val_p0_big = [];
val_r0_big = [];
val_p1_big = [];
val_r1_big = [];

inbag_p_draw = [];
inbag_r_draw=[];
oob_p_draw= [];
oob_r_draw= [];
val_p0_draw = [];
val_r0_draw= [];
val_p1_draw = [];
val_r1_draw= [];


method0 = load("error_0_Self_Model.mat");
method1 = load('error_1_Self_Model.mat');

fieldn = fieldnames(method0.Self_Model);
for i = 1:length(fieldn)
    inbag_p_big = cat(2,inbag_p_big,method0.Self_Model.(fieldn{i}).inbag_predicted);
    inbag_r_big =cat(2,inbag_r_big,method0.Self_Model.(fieldn{i}).inbag_real);
    oob_p_big= cat(2,oob_p_big,method0.Self_Model.(fieldn{i}).oob_predicted);
    oob_r_big = cat(2,oob_r_big,method0.Self_Model.(fieldn{i}).oob_real);
    val_p0_big = cat(2,val_p0_big,method0.Self_Model.(fieldn{i}).val_predicted);
    val_r0_big = cat(2,val_r0_big,method0.Self_Model.(fieldn{i}).val_real);
    val_p1_big = cat(2,val_p1_big,method1.Self_Model.(fieldn{i}).val_predicted);
    val_r1_big = cat(2,val_r1_big,method1.Self_Model.(fieldn{i}).val_real);
   
    inbag_p_draw = cat(1,inbag_p_draw,method0.Self_Model.(fieldn{i}).inbag_draw_predicted);
    inbag_r_draw=cat(1,inbag_r_draw,method0.Self_Model.(fieldn{i}).inbag_draw_real);
    oob_p_draw= cat(1,oob_p_draw,method0.Self_Model.(fieldn{i}).oob_draw_predicted);
    oob_r_draw = cat(1,oob_r_draw,method0.Self_Model.(fieldn{i}).oob_draw_real);
    val_p0_draw = cat(1,val_p0_draw,method0.Self_Model.(fieldn{i}).val_draw_predicted);
    val_r0_draw = cat(1,val_r0_draw,method0.Self_Model.(fieldn{i}).val_draw_real);
    val_p1_draw = cat(1,val_p1_draw,method1.Self_Model.(fieldn{i}).val_draw_predicted);
    val_r1_draw = cat(1,val_r1_draw,method1.Self_Model.(fieldn{i}).val_draw_real);

end


%%
h1 = figure(1);
clf
r2rmse(inbag_p_big,inbag_r_big)
dscatter(inbag_r_big.',inbag_p_big.')
cmocean('solar')
ylim([-3 2.5])
xlim([-3 2.5])
rl = refline([1 0]);
rl.LineWidth = 1.25;
rl.Color = 'w';%the 1:1 line
rb = refline([1 0]);
rb.LineWidth = 0.7;
rb.Color = 'k';%the 1:1 line
%ylim([-2.5 2.1])
set(h1, 'Units', 'normalized');
set(h1, 'Position', [0.1, .55, .4, .45]);
colorbar
print('-dtiff',[savepath,'inbag_big'])
%%
h2 = figure(2);
clf

r2rmse(oob_p_big,oob_r_big)
dscatter(oob_r_big.',oob_p_big.')
cmocean('-matter')
set(h2, 'Units', 'normalized');
set(h2, 'Position', [0.1, .55, .4, .45]);
xlim([-3 2])
rl = refline([1 0]);
rl.LineWidth = 1.25;
rl.Color = 'w';%the 1:1 line
rb = refline([1 0]);
rb.LineWidth = 0.7;
rb.Color = 'k';%the 1:1 line
xlim([-2.2 2])
ylim([-2.2 2])
colorbar
print('-dtiff',[savepath,'oob_big'])
%%
h3 = figure(3);
r2rmse(val_p0_big,val_r0_big)
dscatter(val_r0_big.',val_p0_big.')
xlim([-2 2])
cmocean('thermal')
rl = refline([1 0]);
rl.LineWidth = 1.25;
rl.Color = 'w';%the 1:1 line
rb = refline([1 0]);
rb.LineWidth = 0.7;
rb.Color = 'k';%the 1:1 line
xlim([-2.2 2.2])
ylim([-2.2 2.2])
set(h3, 'Units', 'normalized')
set(h3, 'Position', [0.1, .55, .4, .45]);
colorbar
print('-dtiff',[savepath,'val0_big'])
%print('-dtiff',[savepath,'\method',num2str(method),skip,'_valptp'])
%%
h4 = figure(4);
r2rmse(inbag_p_draw,inbag_r_draw)
dscatter(inbag_r_draw,inbag_p_draw,'Filled',false,'Marker','o')
cmocean('solar')
rl = refline([1 0]);
rl.LineWidth = 1.25;
rl.Color = 'w';%the 1:1 line
rb = refline([1 0]);
rb.LineWidth = 0.7;
rb.Color = 'k';%the 1:1 line
%xlim([-2.7 2])
set(h4, 'Units', 'normalized');
set(h4, 'Position', [0.1, .55, .4, .45]);
colorbar
print('-dtiff',[savepath,'inbagdraw'])

%%
h5 = figure(5);
r2rmse(oob_p_draw,oob_r_draw)
dscatter(oob_r_draw,oob_p_draw,'Filled',false,'Marker','o')
cmocean('-matter')
refline([1 0]) %the 1:1 line
rl = refline([1 0]);
rl.LineWidth = 1.25;
rl.Color = 'w';%the 1:1 line
rb = refline([1 0]);
rb.LineWidth = 0.7;
rb.Color = 'k';%the 1:1 line
ylim([-2 1.75])
xlim([-2 1.75])
set(h5, 'Units', 'normalized');
set(h5, 'Position', [0.1, .55, .4, .45]);
colorbar
print('-dtiff',[savepath,'oobdraw'])
%%
h6 = figure(6);
r2rmse(val_p0_draw,val_r0_draw)
dscatter(val_r0_draw,val_p0_draw,'Filled',false,'Marker','o')
cmocean('thermal')
refline([1 0]) %the 1:1 line
rl = refline([1 0]);
rl.LineWidth = 1.25;
rl.Color = 'w';%the 1:1 line
rb = refline([1 0]);
rb.LineWidth = 0.7;
rb.Color = 'k';%the 1:1 line
ylim([-2.5 2])
xlim([-2.5 2])
set(h6, 'Units', 'normalized');
set(h6, 'Position', [0.1, .55, .4, .45]);
colorbar
%print('-dtiff',[savepath,'val1draw'])


%%
%r2rmse(method0.Self_Model.Lamont.inbag_predicted,method0.Self_Model.Lamont.inbag_real)
%r2rmse(method0.Self_Model.Lamont.oob_predicted,method0.Self_Model.Lamont.oob_real)
r2rmse(method0.Self_Model.Lamont.val_predicted,method0.Self_Model.Lamont.val_real)
%r2rmse(method0.Self_Model.Lamont.val_draw_predicted,method0.Self_Model.Lamont.val_draw_real)
%r2rmse(method0.Self_Model.Lamont.oob_draw_predicted,method0.Self_Model.Lamont.oob_draw_actual)
%r2rmse(method0.Self_Model.Lamont.inbag_draw_predicted,method0.Self_Model.Lamont.inbag_draw_actual)

