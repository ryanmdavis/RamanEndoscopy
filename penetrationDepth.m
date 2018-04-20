function out = penetrationDepth(image,boundary1,boundary2,threshold,um_per_pixel)

%% display option
display=0;
profile_plot_freq=5;

%% figure out which boundry is short and whichis long
if size(boundary1,1)>size(boundary2,1)
    bl=boundary1; %boundry long
    bs=boundary2; %boundry short
else
    bl=boundary2; %boundry long
    bs=boundary1; %boundry short
end

%% map short boundary position to long boundry position
long_position=zeros(1,size(bs,1));
for short_position=1:size(bs,1)
    normalized_short_position=short_position/size(bs,1);
    long_position(short_position)=round(normalized_short_position*size(bl,1));
end

%% calculate penetration depth
% this could easily be merged with previous for loop, but I'm keeping it
% separate for conceptual simplicity
penetration_depth_pixel=zeros(1,size(bs,1));
for short_position=1:size(bs,1)
    c=improfile(image,[bs(short_position,1) bl(short_position,1)],[bs(short_position,2) bl(short_position,2)]);
    penetration_depth_pixel(short_position)=sum(c>threshold);
end

%% calculate penetration depth in um
penetration_depth_um=penetration_depth_pixel*um_per_pixel;

%%
if display==1
    figure,imagesc(image,[0 100]);
    to_plot=1:profile_plot_freq:size(bs,1);
    line([bl(long_position(to_plot),1) bs(to_plot,1)].',[bl(long_position(to_plot),2) bs(to_plot,2)].','color','w');
    line([bl(long_position(to_plot),1) bs(to_plot,1)],[bl(long_position(to_plot),2) bs(to_plot,2)],'color','r','linewidth',2);
end

out=struct('pd',penetration_depth_um);