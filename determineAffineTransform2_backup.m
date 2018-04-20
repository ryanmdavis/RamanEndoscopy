%Ryan M Davis 06062016
% output:
%   shift,rotation (degrees),scale specify the transform required to
%   register image 2 to image 1.  For
%   example rotation gives how much image 2 is rotated CCW relative to Im 1
%   note that this function assumes the order of transormations: scale,
%   then rotation (around center of image), then shift.

function reg_parameters = determineAffineTransform2(im1,im2,varargin)

% assign optional arguments
invar = struct('spec_cx_cy',0);
argin = varargin;
invar = generateArgin(invar,argin);

if ~invar.spec_cx_cy
    figure
    set(gcf,'position',[303 518 1130 420]);

    subplot(1,2,2)
    imagesc(im2);
    axis off image

    subplot(1,2,1)
    imagesc(im1)
    impixelinfo
    axis off image
    title('click on two landmarks');
    [CX1,CY1,~] = improfile;
    close(gcf)

    figure
    set(gcf,'position',[303 518 1130 420]);

    subplot(1,2,2)
    imagesc(im1);
    axis off image
    line(CX1,CY1,'color','r','linewidth',3)

    subplot(1,2,1)
    imagesc(im2)
    impixelinfo
    title('click on two landmarks');
    axis off image
    [CX2,CY2,~] = improfile;
    close(gcf)
else
    CX1=invar.spec_cx_cy(1,:);
    CX2=invar.spec_cx_cy(2,:);
    CY1=invar.spec_cx_cy(3,:);
    CY2=invar.spec_cx_cy(4,:);
end
% registration parameters
reg_parameters=struct('shift_rc',[0 0],'rotation',0,'scale',1,'backwards_rot',0,'center_im1',[0 0],'padded_im_size_rc',[0 0],'padded_im_center_xy',[0 0],'im2_pad_size_rc',[0 0]);

% use real and imaginary for rotation
orientation1=CX1(end)-CX1(1)-1i*(CY1(end)-CY1(1));
orientation2=CX2(end)-CX2(1)-1i*(CY2(end)-CY2(1));

% determine relative scale and angle between two images
reg_parameters.scale=abs(orientation1/orientation2);
reg_parameters.rotation=180*angle(orientation1/orientation2)/pi;

%% determine shift between two images after im2 has been rotated and scaled
% find center of images in xyz basis
reg_parameters.center_im2_xyz = [size(im2,2)/2 size(im2,1)/2 0];
reg_parameters.center_im1_xyz = [size(im1,2)/2 size(im1,1)/2 0];

% find center of images when both are scaled to same size as photograph
pt1_im2_xyz=[CX2(1)-reg_parameters.center_im2_xyz(1) reg_parameters.center_im2_xyz(2)-CY2(1) 0]*reg_parameters.scale; %transforms from row x col notation to x by y notation (with origin at center and x going to right and y going up)
pt1_im1_xyz=[CX1(1)-reg_parameters.center_im1_xyz(1) reg_parameters.center_im1_xyz(2)-CY1(1) 0];
pt1_im2_xyz_rot=(rotz(reg_parameters.rotation)*pt1_im2_xyz.').';

% find shift between two images and store in row/column basis
shift_row=pt1_im2_xyz_rot(2)-pt1_im1_xyz(2);
shift_col=-(pt1_im2_xyz_rot(1)-pt1_im1_xyz(1));
reg_parameters.shift_rc=round([shift_row shift_col]);
% reg_parameters.shift=[0 0];

% find the zero-padding needed so that images can be shifted relative to
% eachother.  Make sure the padded images have even number of rows and
% columns for convenience later
reg_parameters.pad_size_rc=[abs(reg_parameters.shift_rc(1)) abs(reg_parameters.shift_rc(2))];
padded_row_size=ceil(max([size(im1,1) size(im2,1)*reg_parameters.scale]))+2*reg_parameters.pad_size_rc(1);
padded_col_size=ceil(max([size(im1,2) size(im2,2)*reg_parameters.scale]))+2*reg_parameters.pad_size_rc(2);
reg_parameters.padded_im_size_rc(1)=padded_row_size;
reg_parameters.padded_im_size_rc(2)=padded_col_size;
reg_parameters.padded_im_center_xy(1)=reg_parameters.padded_im_size_rc(2)/2+.5;
reg_parameters.padded_im_center_xy(2)=reg_parameters.padded_im_size_rc(1)/2+.5;
reg_parameters.im2_pad_size_rc=ceil([(reg_parameters.padded_im_size_rc(1)-ceil(size(im2,1)*reg_parameters.scale))/2 (reg_parameters.padded_im_size_rc(2)-ceil(size(im2,2)*reg_parameters.scale))/2]);

% determine transform to go from image 1 back to
% unscaled/unrotated/unshifted image 2.
% reg_parameters.backwards_rot=@(row,col) (rotz(reg_parameters.rotation)*[col-reg_parameters.shift_rc(2) -(row-reg_parameters.shift_rc(1)) 0].' + [reg_parameters.center_im1(1) -reg_parameters.center_im1(2) 0].')/reg_parameters.scale;
reg_parameters.backwards_rot=@(row,col) ceil((round(rotz(-reg_parameters.rotation)*([col-reg_parameters.shift_rc(2)-reg_parameters.padded_im_center_xy(1) reg_parameters.padded_im_center_xy(2)-(row-reg_parameters.shift_rc(1)) 0].').*[1 -1 1].'+[reg_parameters.padded_im_center_xy(1)-reg_parameters.im2_pad_size_rc(2) reg_parameters.padded_im_center_xy(2)-reg_parameters.im2_pad_size_rc(1) 0].'))/reg_parameters.scale);