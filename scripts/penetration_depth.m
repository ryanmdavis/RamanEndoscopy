%% notes
% file saving convention.  take the raw x image, multiply by 10, make an
% int16, then save with dicomwrite.

plot_individual = 0;

%% tumor 2-20-2018
t02202018=dicomread('C:\Users\rdavis5\Documents\Gambhir lab\My Papers and Abstracts\Bladder SERS Paper\Passive penetration\Raman Images\tumor 2-20-2018.dcm');
t02202018_HE=imread('C:\Users\rdavis5\Documents\Gambhir lab\My Papers and Abstracts\Bladder SERS Paper\Passive penetration\HE images\tumor 2-20-2018.jpg');
load('C:\Users\rdavis5\Documents\Gambhir lab\My Papers and Abstracts\Bladder SERS Paper\Passive penetration\mat files\tumor_02222018.mat');
out_tumor_02202018=penetrationDepth2(t02202018,surface_tumor_02202018,s421_mean_tumor_02202018,s421_std_tumor_02202018,5,150,'caxis',[0 400],'display',0); %'rows',[290 381]
load('C:\Users\rdavis5\Dropbox\MolecularEndoscopy\colormap\my colormaps.mat');
colormap(colormap_bg); set(gcf,'Position',[272 688 1184 410]);
axis off

% rotate image
t02202018_rot=imrotate(t02202018,-20);

% display without profiles
if plot_individual
    figure,
    subplot(2,1,1);
    imagesc(t02202018_rot(298:370,265:450),[0 400])
    colormap(colormap_bg); axis image off;  
    line([130 180],[69 69],'linewidth',2,'color','w'); %500 microns
    subplot(2,1,2)
    imagesc(t02202018_HE(430:end,:,:));
    axis image off
end

%% normal 2-20-2018
n02202018=dicomread('C:\Users\rdavis5\Documents\Gambhir lab\My Papers and Abstracts\Bladder SERS Paper\Passive penetration\Raman Images\normal 2-20-2018.dcm');
n02202018_HE=imread('C:\Users\rdavis5\Documents\Gambhir lab\My Papers and Abstracts\Bladder SERS Paper\Passive penetration\HE images\normal 2-20-2018.jpg');
load('C:\Users\rdavis5\Documents\Gambhir lab\My Papers and Abstracts\Bladder SERS Paper\Passive penetration\mat files\normal 02202018.mat');
out_normal_02202018=penetrationDepth2(n02202018,surface_normal_02202018,s421_mean_normal_02202018,s421_std_normal_02202018,5,150,'caxis',[0 200],'display',0)
load('C:\Users\rdavis5\Dropbox\MolecularEndoscopy\colormap\my colormaps.mat');
axis image off; colormap(colormap_bg);

% display without profiles
if plot_individual
    figure
    subplot(2,1,1)
    imagesc(n02202018_HE(460:end,:,:)); axis image off;

    subplot(2,1,2);
    imagesc(n02202018,[0 200])
    load('C:\Users\rdavis5\Dropbox\MolecularEndoscopy\colormap\my colormaps.mat');
    axis image off; colormap(colormap_bg);
    line([6 141],[15 15],'linewidth',2,'color','w');
end



%% normal 8-2-2017
n08022017=dicomread('C:\Users\rdavis5\Documents\Gambhir lab\My Papers and Abstracts\Bladder SERS Paper\Passive penetration\Raman Images\normal 8-2-2017.dcm');
n08022017_HE=imread('C:\Users\rdavis5\Documents\Gambhir lab\My Papers and Abstracts\Bladder SERS Paper\Passive penetration\HE images\normal 8-2-2017.jpg');
load('C:\Users\rdavis5\Documents\Gambhir lab\My Papers and Abstracts\Bladder SERS Paper\Passive penetration\mat files\normal_08022017.mat');
out_normal_08022018=penetrationDepth2(n08022017,surface_normal_08022017,s421_std_normal_08022017,s421_std_normal_08022017,5,150,'caxis',[0 200],'display',0)

load('C:\Users\rdavis5\Dropbox\MolecularEndoscopy\colormap\my colormaps.mat');
colormap(colormap_bg); axis image;

if plot_individual
    figure
    subplot(2,1,1)
    imagesc(n08022017(1:66,:),[0 200]); axis image off; colormap(colormap_bg);
    line([5 55],[61 61],'linewidth',2,'color','w');

    subplot(2,1,2)
    imagesc(n08022017_HE(743:end,:,:))
    axis image off;
end

%% tumor  11-28-2017 - tip
t11282017_tip=imrotate(dicomread('C:\Users\rdavis5\Documents\Gambhir lab\My Papers and Abstracts\Bladder SERS Paper\Passive penetration\Raman Images\tumor 11-28-2017 - tip.dcm'),-20);
t11282017_tip_HE=imread('C:\Users\rdavis5\Documents\Gambhir lab\My Papers and Abstracts\Bladder SERS Paper\Passive penetration\HE images\tumor 11-28-2017 - tip.jpg');
load('C:\Users\rdavis5\Documents\Gambhir lab\My Papers and Abstracts\Bladder SERS Paper\Passive penetration\mat files\tumor 11282017 tip.mat');
out_tumor_11282018=penetrationDepth2(t11282017_tip,surface_tumor_11282017,s421_mean_tumor_11282017,s421_std_tumor_11282017,5,100,'caxis',[0 400],'display',0)

load('C:\Users\rdavis5\Dropbox\MolecularEndoscopy\colormap\my colormaps.mat');
colormap(colormap_bg); axis image;

if plot_individual
    figure
    subplot(2,1,1)
    imagesc(t11282017_tip(21:160,1:136),[0 400]);
    axis image off; colormap(colormap_bg);
    line([10 60],[130 130],'linewidth',3,'color','w')
    subplot(2,1,2)
    imagesc(t11282017_tip_HE(1:1000,560:1620,:))
    axis image off
    line([70 530],[60 60],'linewidth',3,'color','w')
end

%% tumor  11-28-2017 - edge
% t11282017_edge=dicomread('C:\Users\rdavis5\Documents\Gambhir lab\My Papers and Abstracts\Bladder SERS Paper\Passive penetration\Raman Images\tumor 11-28-2017 - edge.dcm');
% t11282017_edge_HE=imread('C:\Users\rdavis5\Documents\Gambhir lab\My Papers and Abstracts\Bladder SERS Paper\Passive penetration\HE images\tumor 11-28-2017 edge.jpg');
% load('C:\Users\rdavis5\Documents\Gambhir lab\My Papers and Abstracts\Bladder SERS Paper\Passive penetration\mat files\tumor 11282017 tip.mat');
% out_tumor_11282018_edge=penetrationDepth2(t11282017_edge,surface_tumor_11282017_edge,s421_mean_tumor_11282017_edge,s421_std_tumor_11282017_edge,5,100,'caxis',[0 400],'display',0)
% 
% load('C:\Users\rdavis5\Dropbox\MolecularEndoscopy\colormap\my colormaps.mat');
% colormap(colormap_bg); axis image;
% 
% if plot_individual
%     figure
%     subplot(2,1,1)
%     imagesc(t11282017_edge,[0 400]);
%     axis image off; colormap(colormap_bg);
%     line([10 60],[130 130],'linewidth',3,'color','w')
%     subplot(2,1,2)
%     imagesc(t11282017_edge_HE)
%     axis image off
%     line([70 530],[60 60],'linewidth',3,'color','w')
% end

%% normal 3-6-2018 - standard mapping measurement
n03062018_1191=dicomread('C:\Users\rdavis5\Documents\Gambhir lab\My Papers and Abstracts\Bladder SERS Paper\Passive penetration\Raman Images\normal 3-6-18 1191.dcm');
load('C:\Users\rdavis5\Documents\Gambhir lab\My Papers and Abstracts\Bladder SERS Paper\Passive penetration\mat files\normal_03062018_1191.mat')
n03062018_1191_HE=imread('C:\Users\rdavis5\Documents\Gambhir lab\My Papers and Abstracts\Bladder SERS Paper\Passive penetration\HE images\normal 3-6-2018 - 1191.jpg');

out_normal_03062018_1191=penetrationDepth2(n03062018_1191,surface_normal_03062018_1191,s421_mean_normal_03062018_1191,s421_std_normal_03062018_1191,5,150,'caxis',[0 1000],'display',0);

if plot_individual
    figure,plotProfileStats(out_normal_03062018_1191.centered_profiles,5,'x_lim',[-50 50]); niceFigure(gcf,'line',0);
    title('normal 3-6-2018');
    figure,subplot(2,1,1);
    imagesc(n03062018_1191,[0 600]); axis off
    line([5 55],[88 88],'width',3,'color','w')
    subplot(2,1,2);
    imagesc(n03062018_1191_HE(570:end,:,:)); axis off
end

%% tumor 3-6-2018 - standard mapping measurement
t03062018_1191=dicomread('C:\Users\rdavis5\Documents\Gambhir lab\My Papers and Abstracts\Bladder SERS Paper\Passive penetration\Raman Images\tumor 3-6-18 1191.dcm');
t03062018_1191_HE=imread('C:\Users\rdavis5\Documents\Gambhir lab\My Papers and Abstracts\Bladder SERS Paper\Passive penetration\HE images\tumor 3-6-2018 - 1191.jpg');
load('C:\Users\rdavis5\Documents\Gambhir lab\My Papers and Abstracts\Bladder SERS Paper\Passive penetration\mat files\tumor_03062018_1191.mat');

out_tumor_03062018_1191=penetrationDepth2(t03062018_1191,surface_tumor_03062018_1191,s421_mean_tumor_03062018_1191,s421_std_tumor_03062018_1191,11,150,'caxis',[0 1000],'display',0);

if plot_individual
    figure,plotProfileStats(out_tumor_03062018_1191.centered_profiles,5,'x_lim',[-50 50]); niceFigure(gcf,'line',0);
    title('tumor 3-6-2018');
    figure,subplot(2,1,1);
    imagesc(t03062018_1191,[0 200]); axis off
    line([5 5+500/11],[53 53],'linewidth',3,'color','w');
    subplot(2,1,2);
    imagesc(t03062018_1191_HE(600:end,:,:)); axis off
end

%% plot histogram
% figure
% t_hist=histogram([out_tumor_02202018.pd out_tumor_11282018.pd],0:20:250);
% hold on
% n_hist=histogram([out_normal_02202018.pd out_normal_08022018.pd],0:20:250);
% xlabel('penetration depth (\mum)');
% ylabel('# of profiles');
% axis square
% ylim([0 100]);
% niceFigure(gcf);
% 
% [h,p]=ttest2([out_normal_02202018.pd out_normal_08022018.pd],[out_tumor_02202018.pd out_tumor_11282018.pd],'VarType','Unequal')

%% plot all on same grid
imagesc(n02202018,[0 200])
load('C:\Users\rdavis5\Dropbox\MolecularEndoscopy\colormap\my colormaps.mat');

figure

% normal 2-20-18
subplot(4,3,1)
imagesc(n02202018_HE(460:end,:,:)); axis image off;
subplot(4,3,4)
imagesc(n02202018,[0 200]); axis image off; colormap(colormap_bg);
line([6 141],[15 15],'linewidth',2,'color','w');

% tumor 2-20-18
subplot(4,3,7)
imagesc(t02202018_HE(430:end,:,:)); axis image off
subplot(4,3,10)
imagesc(t02202018_rot(298:370,265:450),[0 400])
colormap(colormap_bg); axis image off;
line([130 180],[69 69],'linewidth',2,'color','w'); %500 microns

% normal 3-6-18
subplot(4,3,2)
imagesc(n03062018_1191_HE(570:end,:,:)); axis image off;
subplot(4,3,5)
imagesc(n03062018_1191,[0 600]); axis off
line([5 55],[88 88],'linewidth',3,'color','w')

% tumor 3-6-18
subplot(4,3,8)
imagesc(t03062018_1191_HE(600:end,:,:)); axis image off;
subplot(4,3,11);
imagesc(t03062018_1191,[0 200]); axis off
line([5 5+500/11],[53 53],'linewidth',3,'color','w');

% normal 8-2-2017
subplot(4,3,3)
imagesc(n08022017_HE(743:end,:,:)); axis image off;
subplot(4,3,6)
imagesc(n08022017(1:66,:),[0 200]); axis image off; colormap(colormap_bg);
line([5 55],[61 61],'linewidth',2,'color','w');

% tumor 11-28-2017
subplot(4,3,9)
imagesc(t11282017_tip_HE(1:800,:,:)); axis image off
line([70 70+2*345],[50 50],'linewidth',3,'color','k');
subplot(4,3,12)
imagesc(t11282017_tip(60:150,60:220),[0 400]);
axis image off; colormap(colormap_bg);
line([10 60],[5 5],'linewidth',3,'color','w')