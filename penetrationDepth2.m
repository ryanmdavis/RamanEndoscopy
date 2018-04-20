function out = penetrationDepth2(image,surface_xy,bkg_mean,bkg_std,um_per_pixel,margin_width_um,varargin)

%% process optional inputs
invar = struct('caxis',[],'rows',[1 size(image,1)],'cols',[1 size(image,2)],'display',1);
argin = varargin;
invar = generateArgin(invar,argin);

%% processing parameters
smoothing_window=15;
threshold=5*bkg_std;
image=image-bkg_mean;

%% display option
profile_plot_freq=15;

%% calculate normal unit vectors:
surface_smoothed_xy=movmean(surface_xy,smoothing_window);
d_surface_smoothed_xy=diff(surface_smoothed_xy);
d_surface_smoothed_xy(d_surface_smoothed_xy==0)=1e-10; %avoid dividing by zero
normal_slope_xy=normr([-d_surface_smoothed_xy(:,2) d_surface_smoothed_xy(:,1)]);
normal_slope_xy(end+1,:)=normal_slope_xy(end,:);


%% calculate penetration depth
penetration_depth_pixel_count=zeros(1,size(surface_xy,1));
penetration_depth_pixel_std=zeros(1,size(surface_xy,1));
margin_width_pixel=round(margin_width_um/um_per_pixel);
x=zeros(size(normal_slope_xy,1),2);
y=zeros(size(normal_slope_xy,1),2);

% iterate through every position on tissue surface and calculate the Raman
% intensity profile and SERS nanoparticle penetration depth
for surface_position=1:size(surface_xy,1)
    
    % generate image profile
    normal_c=[surface_xy(surface_position,1)-normal_slope_xy(surface_position,1)*margin_width_pixel surface_xy(surface_position,1)+normal_slope_xy(surface_position,1)*margin_width_pixel];
    normal_r=[surface_xy(surface_position,2)-normal_slope_xy(surface_position,2)*margin_width_pixel surface_xy(surface_position,2)+normal_slope_xy(surface_position,2)*margin_width_pixel];
    x(surface_position,:)=normal_c;
    y(surface_position,:)=normal_r;
    c_temp=improfile(image,normal_c,normal_r);
    c_temp(isnan(c_temp))=bkg_mean;
    
    % initialize memory if this is the first loop iteration
    if surface_position==1
        c_padded_size=size(c_temp,1)+max(size(image)); %the profile length will change from position to position by a few pixels
        profiles=zeros(size(surface_xy,1),c_padded_size);
        profiles_com=zeros(size(surface_xy,1),c_padded_size+2*(margin_width_pixel));
    end
    
    % put profile in a vector with well-defined length
    c_padded=zeros(1,c_padded_size);
    c_padded(1:size(c_temp,1))=c_temp;
    
    % store profile in memory
    profiles(surface_position,:)=c_padded.';
    
    %% pixel cound method
    % find the com and shift center of profile to com
    if sum(c_padded)==0
        [~,com]=max(c_padded);
    else
        com=round(sum(((1:size(c_padded,2)).*c_padded))/sum(c_padded));
    end
    profiles_com(surface_position,:)=circshift(padarray(c_padded.',margin_width_pixel,bkg_mean),floor(size(c_padded,2)/2)-com);
    
    % save penetration depth in memory
    penetration_depth_pixel_count(surface_position)=sum(c_padded>threshold);
    
    %% standard deviation method
    pos=1:size(c_padded,2);
    c_padded(c_padded<5*bkg_std)=0;
    if sum(c_padded)>0
        c_padded_norm=abs(c_padded)/sum(abs(c_padded));
        mu=sum(pos.*c_padded_norm);
        stdev=sqrt(sum((pos-mu).^2.*c_padded_norm));
        penetration_depth_pixel_std(surface_position)=stdev;
    else
        penetration_depth_pixel_std(surface_position)=0;
    end
end
profiles=profiles-bkg_mean;
profiles_com=profiles_com-bkg_mean;

%% calculate penetration depth in um
penetration_depth_um_count=penetration_depth_pixel_count*um_per_pixel;
penetration_depth_um_std=penetration_depth_pixel_std*um_per_pixel;

%% calculate percent coverage
% this is percent of surface (i.e. percent of orthogonal profiles) that
% have any nanoparticles on the surface
surface_coverage_percent = 100*sum(penetration_depth_pixel_count>0)/size(penetration_depth_pixel_count,2);
%%
if invar.display==1
    figure,imagesc(image,invar.caxis);
    line(x(1:profile_plot_freq:end,:).',y(1:profile_plot_freq:end,:).','color','w','linewidth',2);
    line(surface_smoothed_xy(:,1),surface_smoothed_xy(:,2),'color','r','linewidth',4);
    axis image off
    xlim([invar.cols])
    ylim([invar.rows])
end

out=struct('pd_um_count',penetration_depth_um_count,'pd_mean_count',mean(penetration_depth_um_count),'pd_std_count',std(penetration_depth_um_count),'pd_median_count',median(penetration_depth_um_count),'pd_um_std',penetration_depth_um_std,'pd_mean_std',mean(penetration_depth_um_std),'pd_std_std',std(penetration_depth_um_std),'pd_median_std',median(penetration_depth_um_std),'profiles',profiles,'centered_profiles',profiles_com,'surface_coverage_percent',surface_coverage_percent);