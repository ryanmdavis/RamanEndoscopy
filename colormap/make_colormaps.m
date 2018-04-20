colormap_red=zeros(64,3);
colormap_green=zeros(64,3);
colormap_orange=zeros(64,3);
colormap_blue=zeros(64,3);

for ii=1:64
    colormap_red(ii,1)=(ii-1)/63;
end


for ii=1:64
    colormap_green(ii,2)=(ii-1)/63;
end

for ii=1:64
    colormap_blue(ii,3)=(ii-1)/63;
end


for ii=1:64
    colormap_orange(ii,1)=(ii-1)/63;
    colormap_orange(ii,2)=(165/255)*(ii-1)/63;
end

colormap_ratios=zeros(2,64,3);
colormap_ratios(1,:,:)=colormap_red;
colormap_ratios(2,:,:)=colormap_blue;
colormap_ratios(3,:,:)=colormap_green;
colormap_ratios(4,:,:)=colormap_orange;

save('C:\Users\rdavis5\Dropbox\MolecularEndoscopy\colormap\my colormaps.mat','colormap_ratios','-append');