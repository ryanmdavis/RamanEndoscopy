% each dataset must be in it's own folder

function save_file_path = processRaman(dir_in,varargin)

% assign optional arguments
% use 'shift_std_spectra_wavenumber',-10 for Renishaw
% if 'input_recon_param_location' == 1 then we are specifying the location
% of the *reconstruction parameters.mat file
% data_input_mode:
%   0: put file location to read raw data from
%   1: put file location to read processed data from (i.e. *.pr.mat)
%   2: pass data from memory in the optional variable called "input_data"

invar = struct('use_dB',0,'redo',0,'shift_std_spectra_wavenumber',0,'show_images',0,'num_background_pc',3,'data_input_mode',0,'input_data',[]);
argin = varargin;
invar = generateArgin(invar,argin);

if (invar.data_input_mode == 1)
    warning('off','MATLAB:load:variableNotFound');
    load(dir_in,'out','prdata');
    warning('on','MATLAB:load:variableNotFound');
    if ~exist('out','var')
        out=prdata;
    end
    parent_dir=out.rp.parent_dir;
    rp=out.rp;
    im1=out.im1;
    im2=out.im2;  %% right now we are holding two image datasets in memory, this needs to be fixed.
elseif (invar.data_input_mode == 2)
    if isempty(invar.input_data)
        error('When setting invar.data_input_mode=2, you must pass the Raman image data into the optional variable "input_data"');
    end
    rp=invar.input_data.rp;
    parent_dir=rp.parent_dir;
    im1=invar.input_data.im1;
    im2=invar.input_data.im2;
    invar.input_data=[]; %free memory
else
    parent_dir=dir_in;
    % make sure parent dir has slash at end
    if ~strcmp(parent_dir(end),mkslash) parent_dir = strcat(parent_dir,mkslash); end
    rp=struct('im1_path','','im2_path','','reg_param',[],'im1',[],'im2',[],'im2_nrow',[],'im2_ncol',[],'fused',[],'tissue_map',[],'A',[],'wavenumber',[],'channel_names',[],'parent_dir',parent_dir,'shift_std_spectra_wavenumber',invar.shift_std_spectra_wavenumber,'A_info',[],'concentrations',[],'use_dB',invar.use_dB);
end

%% check if paths are valid - this code kicks in if the location of the file has been changed
if ~exist(rp.im2_path,'dir') && ~isempty(rp.im2_path)
    dot_loc=strfind(prdata.file_name,'.');
    txt_file_name=strcat(prdata.file_name(1:dot_loc(1)),'txt');
    if exist(strcat(prdata.file_path,prdata.file_name(1:dot_loc(1)),'txt'),'file')
        rp.im2_path=prdata.file_path;
    else
        warning(strcat('Cannot find original .txt file generated by endoscope: ',txt_file_name));
        rp.im2_path='';
    end
end


% % if the reconstruction parameters for this dataset already exist, load
% % them, if not then define the structure.
% if ~exist(strcat(parent_dir,'reconstruction parameters.mat'),'file') || invar.redo==-1
%     rp=struct('im1_path','','im2_path','','reg_param',[],'im1',[],'im2',[],'im2_nrow',[],'im2_ncol',[],'fused',[],'tissue_map',[],'A',[],'wavenumber',[],'channel_names',[]);
% else
%     rp = loadRp(parent_dir);
% end

% find location of Raman image and store in memory:
if isempty(rp.im2_path) || invar.redo==3 || invar.redo==-1
    [filename,pathname] = uigetfile({'*.txt','Endoscope data';'*.*','All Files';
            '*.spc','Microscope data';},'Locate the .txt file with Raman Data',parent_dir);
    % make sure parent dir has slash at end
    if ~strcmp(pathname(end),mkslash) pathname = strcat(pathname,mkslash); end
    rp.im2_path=pathname;
    rp.im2_filename=filename;
    dot_loc=strfind(rp.im2_filename,'.');
    filename_save=strcat(rp.im2_path,rp.im2_filename(1:dot_loc(end)-1));
    
    % save recon parameters
    saveRp(filename_save,rp);
else
    % define path to save the processed Raman data (.pr.mat)
    dot_loc=strfind(rp.im2_filename,'.');
    filename_save=strcat(rp.im2_path,rp.im2_filename(1:dot_loc(end)-1));
end

% load first image
if isempty(rp.im1_path) || invar.redo==1 || invar.redo==-1 || (invar.redo == 6 && strcmp(rp.im1_path,'none'))
    [filename,pathname] = uigetfile({'*.jpg;*.tif;*.png;*.gif','All Image Files';...
          '*.*','All Files' },'Locate a photograph for registration, or press cancel',...
          parent_dir);
    if pathname ~= 0
        parent_dir=pathname;
        rp.im1_path=strcat(pathname,filename);
        im1=imread(rp.im1_path);
    else
        rp.im1_path='none';
        im1=[];
    end
    saveRp(filename_save,rp);
elseif strcmp(rp.im1_path,'none')
    im1=[];
end


% draw user specified mask that surrounds tissue if performing registration
if ~strcmp(rp.im1_path,'none') && (isempty(rp.tissue_map) || invar.redo==2 || invar.redo==-1)
    f_p=figure;
    imagesc(im1);
    title({'Draw ROI surrounding tissue','but excluding fiducials'});
    axis image off
    xlabel('right click and "create mask"');
    niceFigure(f_p);
    rp.tissue_map=roipoly;
    close(f_p);
end

% recon second image based on if this the data were separated into rows
if (invar.data_input_mode == 0) && isempty(strfind(rp.im2_filename,'_to_')) && ~isempty(strfind(rp.im2_filename,'.spc'))
    spectra=readRenishawSpc(strcat(rp.im2_path,rp.im2_filename));
    rows_cols=[];
    system='Renishaw';
elseif (invar.data_input_mode==0) && ~isempty(strfind(rp.im2_filename,'.spc'))
    [spectra,rows_cols]=concatenateRamanSpectraRows(rp.im2_path);
    rp.im2_nrow=rows_cols(1);
    rp.im2_ncol=rows_cols(2);
    system='Renishaw';
elseif (invar.data_input_mode==0) && ~isempty(strfind(rp.im2_filename,'.txt'))
    spectra = readRamanEndoscopeTxt(strcat(rp.im2_path,rp.im2_filename));
    rows_cols=[];
    system='Endoscope';
else
    rows_cols=[size(im2.b,1) size(im2.b,2)];
end

% get info about image matrix size
if isempty(rows_cols) && (isempty(rp.im2_nrow) || invar.redo==4 || invar.redo==-1)
    display(strcat('Total spectra: ',num2str(size(spectra.spectra,1))));
    rp.im2_nrow=input('Enter the number of rows in the Raman map: ');
    saveRp(filename_save,rp);
end

if isempty(rows_cols) && (isempty(rp.im2_ncol) || invar.redo==4 || invar.redo==-1)
    rp.im2_ncol=input('Enter the number of cols in the Raman map: ');
    saveRp(filename_save,rp);
end

% reshape and arrange data for unmixing, unless raw data was split up into
% rows 
if isempty(rows_cols)
    b=permute(reshape(spectra.spectra,rp.im2_ncol,rp.im2_nrow,size(spectra.spectra,2)),[2,1,3]);
else
    b=spectra.spectra;
end

% if first image (i.e. photograph) is not loaded, set tissue mask as
% "everything"
if strcmp(rp.im1_path,'none')
   rp.tissue_map=ones(rp.im2_nrow,rp.im2_ncol);
   im1=zeros(rp.im2_nrow,rp.im2_ncol,3);
end

%% define forward problem A (b=Ax) and solve for x
if isempty(rp.A) || invar.redo==7 || invar.redo==-1
    % [A,channel_names,wavenumber]=defineRamanForwardProblem(system,invar.num_background_pc);
    [A,wavenumber,channel_names,num_np_channels,A_info]=queryA(rp.A_info);
    
    % if specified, shift standard spectra x axis
    wn_per_bin=wavenumber(2)-wavenumber(1);
    for channel_num=1:size(A,1)%-size(background_pc,1)
        A(channel_num,:)=interp1(wavenumber,A(channel_num,:),wavenumber-A_info.wavenumber_shift/wn_per_bin);
    end
    
    if A_info.wavenumber_shift>0
%         keyboard; %need to write this code
        first_non_NaN_index=find(isnan(A(1,:)),1,'last')+1;
        A_info.raman_shift_range=A_info.raman_shift_range(first_non_NaN_index:end);
        A=A(:,first_non_NaN_index:end);
        wavenumber=wavenumber(first_non_NaN_index:end);
    elseif A_info.wavenumber_shift<0
        last_non_NaN_index=find(isnan(A(1,:)),1)-1;
        A_info.raman_shift_range=A_info.raman_shift_range(1:last_non_NaN_index);
        A=A(:,1:last_non_NaN_index);
        wavenumber=wavenumber(1:last_non_NaN_index);
    end
        
    % remove bins that are NaN
    rp.A=A;
    rp.wavenumber=wavenumber;
    rp.channel_names=channel_names;
    rp.num_np_channels=num_np_channels;
    rp.A_info=A_info;
    saveRp(filename_save,rp);
end

% kludge fix: forthis dataset, one of the rows was shifted!?
if strcmp(parent_dir,'C:\Users\rdavis5\Documents\Gambhir lab\Gambhir Data and Analysis\Raman Endoscope\02172017 - CA9 and CD47 cells\')
    b(22,:,:)=circshift(b(22,:,:),[0 -9 0]);
end


% if we are specifying different concentrations for each channel
if invar.redo==5 % if we are specifying different concentrations for each channel
    [rp.concentrations,rp.control_channel]=queryRelativeConcGUI(rp.channel_names(1:rp.num_np_channels),rp.concentrations,rp.control_channel);
    out_unmix=im2;
elseif invar.redo==-1 || invar.redo==0 || isempty(rp.concentrations)
    rp.concentrations=ones(1,rp.num_np_channels);
    rp.control_channel=1;
    % perform unmixing
    out_unmix=pivUnmixing(b,rp.A,pinv(rp.A),spectra.wavenumber,rp.wavenumber);
else
    % perform unmixing
    out_unmix=pivUnmixing(b,rp.A,pinv(rp.A),spectra.wavenumber,rp.wavenumber);
end

%% perform registration
% find out the scale,shift, and rotation needed to match the two images
if (~strcmp(rp.im1_path,'none') && isempty(rp.reg_param)) || invar.redo==6 || invar.redo==-1
    rp.reg_param = determineAffineTransform2(im1,squeeze(out_unmix.x(2,:,:)));
    saveRp(filename_save,rp);
elseif isempty(rp.reg_param)
    % make im1 a RGB image of zeros of same size as im2
    im1 = zeros([size(squeeze(out_unmix.x(1,:,:))) 3]);
    rp.reg_param=struct('shift_rc',[0 0],'rotation',0,'scale',1,'backwards_rot',@(x,y) round([y x]),'center_im1',round([size(im1,1) size(im1,2)]),'padded_im_size_rc',[size(im1,1) size(im1,2)],'padded_im_center_xy',round([size(im1,2) size(im1,1)]/2),'im2_pad_size_rc',[size(im1,1) size(im1,2)],'pad_size_rc',[0 0]);
    saveRp(filename_save,rp);
end

% for each channel, do the registration and overlay
mf=mfilename('fullpath');
slash_loc=strfind(mf,mkslash);
colormap_path=strcat(mf(1:slash_loc(end)),'colormap',mkslash,'my colormaps.mat');
load(colormap_path,'colormap_bg','colormap_ratios');  %load the colormap
colormap_use=parula;
colormap_use(1,:)=0;

% out(1:size(out_unmix.x,1))=struct('fused',[],'im1_reg',[],'im2_reg',[],'im1',im1,'im2',out_unmix,'scale',[],'colormap',colormap_bg,'reg_param',rp.reg_param,'A',A,'x',out_unmix.x);
im_reg_blank=zeros([size(out_unmix.x,1) (rp.reg_param.padded_im_size_rc-2*rp.reg_param.pad_size_rc) 3]);
im_reg_blank_grayscale=zeros([size(out_unmix.x,1) (rp.reg_param.padded_im_size_rc-2*rp.reg_param.pad_size_rc)]);

% define structure
% changed colormap entry to parula from colormap_bg
out=struct('fused',im_reg_blank,'im1_reg_rgb',im_reg_blank,'im2_reg_rgb',im_reg_blank,'im2_reg_grayscale',im_reg_blank_grayscale,'im1',im1,'im2',out_unmix,'scale',zeros(size(out_unmix.x,1),2),'colormap',colormap_use,'ratio_colormaps',colormap_ratios,'reg_param',rp.reg_param,'A',rp.A,'x',out_unmix.x,'channel_names',{rp.channel_names},'pr_file_loc',[],'rp',rp);
for channel_num=1:size(out_unmix.x,1)
    % determine standarding range for Raman map
%     [im1_out, im2_out]=registerImagesByShiftingGrayScale(rp.tissue_map,squeeze(out_unmix.x(1,:,:)),rp.reg_param);
%     [reg_mask_out, im2_out]=registerImagesByShifting2(rp.tissue_map,squeeze(out_unmix.x(1,:,:)),rp.reg_param);
    [im2_out, reg_mask_out]=registerImagesByShifting2(squeeze(out_unmix.x(1,:,:)),rp.tissue_map,rp.reg_param);
    im2_out(im2_out<0)=1e-10;
    masked_im2=im2_out.*reg_mask_out; % apply ROI mask
    if rp.use_dB
        max_raman_intensity=20*log10(max(max(masked_im2)));
        out.scale(channel_num,:)=[max_raman_intensity-60 max_raman_intensity];
        channel_image=squeeze(out_unmix.x(channel_num,:,:));
        channel_image(channel_image<0)=1e-10;
        raman_grayscale=20*log10(channel_image);
        raman_rgb=intensity2RGB(raman_grayscale,colormap_bg,out.scale(channel_num,:));
    else
        max_raman_intensity=max(max(masked_im2));
        out.scale(channel_num,:)=[max_raman_intensity*0.05 max_raman_intensity*0.95];
        raman_grayscale=squeeze(out_unmix.x(channel_num,:,:));
        raman_rgb=intensity2RGB(raman_grayscale,colormap_bg,out.scale(channel_num,:));
    end

    % register and write output.  Show image only once if specified
    if channel_num==1 && invar.show_images
        show_boolean=1;
    else
        show_boolean=0;
    end
    [im1_out_rgb, im2_out_rgb]=registerImagesByShifting2(im1,raman_rgb,rp.reg_param,'show_images',show_boolean);
    out.fused(channel_num,:,:,:) = double(imfuse(im1_out_rgb,im2_out_rgb,'blend'))/255;
    out.im1_reg_rgb(channel_num,:,:,:) = im1_out_rgb;
    out.im2_reg_rgb(channel_num,:,:,:) = im2_out_rgb;
    
    % register and write output
    [~, im2_out_grayscale]=registerImagesByShifting2(im1,raman_grayscale,rp.reg_param);
    out.im2_reg_grayscale(channel_num,:,:) = reshape(im2_out_grayscale,1,size(im2_out_grayscale,1),size(im2_out_grayscale,2));
end

% generate file name for saving and save
slash_loc=strfind(rp.im2_path,mkslash);
dot_loc=strfind(rp.im2_filename,'.');

if strfind(rp.im2_filename(1:dot_loc(end)-1),'_to_')
    underscore_loc_filename=strfind(rp.im2_filename,'_');
    filename_save = rp.im2_filename(1:underscore_loc_filename(1)-1);
else
    filename_save=rp.im2_filename(1:dot_loc(end)-1);
end

if (invar.data_input_mode == 1)
    save_file_path=dir_in;
else
    save_file_path=strcat(rp.im2_path,filename_save,'.pr.mat');
end
out.pr_file_loc=save_file_path;
prdata=out; %#ok<NASGU>
save(out.pr_file_loc,'prdata','-v7.3');

% display(strcat('processed data written to: ',save_file_path))
end

function saveRp(filename_save,rp)
%     save(filename_save,'rp');
end

function rp = loadRp(filename_save)
%     load(filename_save,'rp');
end