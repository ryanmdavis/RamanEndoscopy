function varargout = visualizeRaman(varargin)
% VISUALIZERAMAN MATLAB code for visualizeRaman.fig
%      VISUALIZERAMAN, by itself, creates a new VISUALIZERAMAN or raises the existing
%      singleton*.
%
%      H = VISUALIZERAMAN returns the handle to a new VISUALIZERAMAN or the handle to
%      the existing singleton*.
%
%      VISUALIZERAMAN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VISUALIZERAMAN.M with the given input arguments.
%
%      VISUALIZERAMAN('Property','Value',...) creates a new VISUALIZERAMAN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before visualizeRaman_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to visualizeRaman_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help visualizeRaman

% Last Modified by GUIDE v2.5 28-Feb-2018 17:55:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @visualizeRaman_OpeningFcn, ...
                   'gui_OutputFcn',  @visualizeRaman_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before visualizeRaman is made visible.
function visualizeRaman_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to visualizeRaman (see VARARGIN)

% Choose default command line output for visualizeRaman
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%load data structure returned by processRaman function
setupGui(handles);

function setupGui(handles,varargin)

invar = struct('prdata_source',0,'pr_file_location',[],'first_call',1,'prdata',[]);
argin = varargin;
invar = generateArgin(invar,argin);

if invar.prdata_source==0
%     error('when prdata_source = 0, ');
        
    [pr_file,path]=uigetfile(strcat(pwd,mkslash,'*.pr.mat'),'Select '',pr.mat'' file');
    
    % load processed Raman data (prdata)
    warning('off','MATLAB:load:variableNotFound');
    load(strcat(path,pr_file),'out','prdata');
    warning('on','MATLAB:load:variableNotFound');
    if ~exist('prdata','var')
        prdata=out;
    end
    clear out
    prdata.file_path=path;
    prdata.file_name=pr_file;
    prdata.pr_file_loc=strcat(path,pr_file);
    
    % now load raw Raman data
    prdata.rp = fixChangedPath(prdata.rp, pr_file, path);
    [im2,~]=loadRawRamanFromHD(prdata.rp);
    prdata.im2_raw=im2;
    clear im2
elseif invar.prdata_source == 1 %location of file is passed !!!may be broken now
    if ~exist(invar.pr_file_location,'dir')
        error('when prdata_source = 1, must pass a valid .pr.mat file in optional variable "pr_file_location"');
    end
    slash_locs=strfind(invar.pr_file_location,'\');
    load(invar.pr_file_location);
    if ~exist('prdata','var')
        prdata=out;
    end
    prdata.file_path=invar.pr_file_location(1:slash_locs(end));
    prdata.file_name=invar.pr_file_location(slash_locs(end)+1:end);
    prdata.pr_file_loc=strcat(prdata.file_path,prdata.file_name);
    clear out
elseif invar.prdata_source == 2 % all raw and processed data passed through function input
    if isempty(invar.prdata)
        error('when prdata_source = 2, must pass in the prdata structure via the optional input variable "prdata"');
    end
    prdata = invar.prdata;
end

% set visualizeRaman properties
if isfield(prdata,'vrprops')
    setVRProperties(prdata.vrprops,handles);
end

setappdata(gcf,'prdata',prdata);
setappdata(gcf,'handles',handles);

% set images
axes(handles.axes1)
imagesc(squeeze(prdata.im1_reg_rgb(1,:,:,:)))
axis image off
set(gcf,'WindowButtonDownFcn',@clickAxes);

axes(handles.axes2)
imagesc(squeeze(prdata.im2_reg_rgb(1,:,:,:)))
axis image off
set(handles.axes2,'ButtonDownFcn',@clickAxes);

axes(handles.axes3)
imagesc(squeeze(prdata.fused(1,:,:,:)))
axis image off
set(handles.axes3,'ButtonDownFcn',@clickAxes);

% set default click position
prdata.clicked_axis=1;
prdata.click_location_xy=[1 1];
setappdata(gcf,'prdata',prdata);


% set ratio popup menue values
% for channel_num=1:size(prdata.x,1)
%    vals{channel_num}=num2str(channel_num); 
% end
if invar.first_call
    set(handles.popupmenu1,'string',prdata.channel_names);
    set(handles.popupmenu2,'string',[prdata.channel_names {'sum'}]);
    if prdata.rp.num_np_channels==1
        set(handles.popupmenu1,'value',1);
    else
        set(handles.popupmenu1,'value',2);
    end
    set(handles.popupmenu2,'value',1);
    updateRatioImage(gcf,handles);
end
% set table row and column names
uitable_row_names=prdata.channel_names;
uitable_row_names{size(uitable_row_names,2)+1}='ROI mean';
uitable_row_names{size(uitable_row_names,2)+1}='ROI STD';
set(handles.uitable1,'RowName',uitable_row_names);
set(handles.uitable1,'ColumnName',{'Raw','-20log(Raw)'});

% setup slider
set(handles.slider1,'Min',1,'Max',size(prdata.x,1),'Value',1,'SliderStep',[1/(size(prdata.x,1)-1) 2/(size(prdata.x,1)-1)]);

% show fit as default
set(handles.checkbox3,'value',1);

% setup title font size
set(handles.text4,'FontSize',15);
set(handles.text5,'FontSize',15);
set(handles.text6,'FontSize',15);
updateImages(handles);

% set threshold popup menue
prdata=getappdata(gcf,'prdata');
menu_names=prdata.channel_names;
menu_names{end+1}='Current Ratio';
menu_names{end+1}='SERS Sum';
set(handles.popupmenu4,'String',menu_names);

% save gui figure handle
handles.gui=gcf;
setappdata(gcf,'gui_handle',gcf);

function clickAxes(gcbo,eventdata,handles)

handles=getappdata(gcf,'handles');
prdata=getappdata(gcf,'prdata');

click_location1=get(handles.axes1,'CurrentPoint');
click_location2=get(handles.axes2,'CurrentPoint');
click_location3=get(handles.axes3,'CurrentPoint');
click_location4=get(handles.axes4,'CurrentPoint');
click_location5=get(handles.axes5,'CurrentPoint');

if (click_location1(1,2)>=1)&&(click_location1(1,2)<=size(prdata.im1_reg_rgb,2))&&(click_location1(1,1)>=1)&&(click_location1(1,1)<=size(prdata.im1_reg_rgb,3))
    clicked_axis=1;
    click_location_xy=click_location1(1,1:2);
elseif (click_location2(1,2)>=1)&&(click_location2(1,2)<=size(prdata.im1_reg_rgb,2))&&(click_location2(1,1)>=1)&&(click_location2(1,1)<=size(prdata.im1_reg_rgb,3))
    clicked_axis=2;
    click_location_xy=click_location2(1,1:2);
elseif (click_location3(1,2)>=1)&&(click_location3(1,2)<=size(prdata.im1_reg_rgb,2))&&(click_location3(1,1)>=1)&&(click_location3(1,1)<=size(prdata.im1_reg_rgb,3))
    clicked_axis=3;    
    click_location_xy=click_location3(1,1:2);
elseif (click_location4(1,2)>=min(get(handles.axes4,'ylim')))&&(click_location4(1,2)<=max(get(handles.axes4,'ylim')))&&(click_location4(1,1)>=min(get(handles.axes4,'xlim')))&&(click_location4(1,1)<=max(get(handles.axes4,'xlim')))
    clicked_axis=4;    
    click_location_xy=click_location4(1,1:2);
elseif (click_location5(1,2)>=1)&&(click_location5(1,2)<=size(prdata.im1_reg_rgb,2))&&(click_location5(1,1)>=1)&&(click_location5(1,1)<=size(prdata.im1_reg_rgb,3))
    clicked_axis=5;
    click_location_xy=click_location5(1,1:2);
else
    clicked_axis=-1;
    click_location_xy=[0 0];
end

prdata.clicked_axis=clicked_axis;
prdata.click_location_xy=click_location_xy;
setappdata(gcf,'prdata',prdata);
f_gui=gcf;

axes(handles.axes4);
plotDecomp(f_gui,handles,'update_ratio_image',0);


function plotDecomp(f_gui,handles,varargin)
invar = struct('update_ratio_image',1,'f_h','','force_plot',0);
argin = varargin;
invar = generateArgin(invar,argin);

prdata=getappdata(f_gui,'prdata');
clicked_axis=prdata.clicked_axis;
click_location_xy=prdata.click_location_xy;

axes(handles.axes4);

if clicked_axis~=-1&&clicked_axis~=4
    click_location_rc=[click_location_xy(2) click_location_xy(1)];
    im2_loc_xy=prdata.reg_param.backwards_rot(click_location_rc(1),click_location_rc(2));
    im2_loc_rc(1)=im2_loc_xy(2);
    im2_loc_rc(2)=im2_loc_xy(1);
    
    % if clicked in the axis, but ouside of the range of "b", then don't
    % display anthing.  This usually happens with registered images
    if ~(im2_loc_rc(1)<1 || im2_loc_rc(1)>size(prdata.im2_raw.spectra,1) || im2_loc_rc(2)<1 || im2_loc_rc(2)>size(prdata.im2_raw.spectra,2)) || invar.force_plot
        if ~isempty(invar.f_h)
            figure(invar.f_h)
        end
        hold off
        
        if get(handles.checkbox4,'Value')
            % interpolate onto same x axis
            acq_spectrum_interp=interp1(prdata.im2_raw.wavenumber,squeeze(prdata.im2_raw.spectra(im2_loc_rc(1),im2_loc_rc(2),:)),prdata.im2_fit.wavenumber_b_est);
            lsq_fit=(prdata.A'*prdata.x(:,im2_loc_rc(1),im2_loc_rc(2))).';
            plot(prdata.im2_fit.wavenumber_b_est,acq_spectrum_interp-lsq_fit);
        else
            plot(prdata.im2_raw.wavenumber,squeeze(prdata.im2_raw.spectra(im2_loc_rc(1),im2_loc_rc(2),:)),'linewidth',2)
            hold on
            for channel_num=1:size(prdata.x,1)
               plot(prdata.im2_fit.wavenumber_b_est,prdata.A(channel_num,:)*prdata.im2_fit.x(channel_num,im2_loc_rc(1),im2_loc_rc(2)));
            end
            if get(handles.checkbox3,'value')
                plot(prdata.im2_fit.wavenumber_b_est,prdata.A'*prdata.im2_fit.x(:,im2_loc_rc(1),im2_loc_rc(2)),'r','linewidth',2);
            end
        end
        
        xlim([min(prdata.im2_fit.wavenumber_b_est) max(prdata.im2_fit.wavenumber_b_est)]);
        xlabel('Raman Shift (cm^-^1)');
        ylabel({'Raman scattering intensity','(counts/mW/s)'});
        title({'Raman scattering intensity in',strcat('pixel (',num2str(im2_loc_rc(1)),',',num2str(im2_loc_rc(2)),')')});
        
        prdata.im2_loc_rc=im2_loc_rc;
        prdata.click_location_rc=click_location_rc;
        setappdata(f_gui,'prdata',prdata);
        updateTable(handles,'update_ratio_image',invar.update_ratio_image);
    end
end

function varargout = visualizeRaman_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1

updateTable(handles);
updateRatioImage(gcf,handles);

% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2
updateRatioImage(gcf,handles)

% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function varargout = updateRatioImage(f_gui,handles,varargin)

invar = struct('colormap',[],'use_registered_raman_image',1,'save_result',1);
argin = varargin;
invar = generateArgin(invar,argin);

current_figure=gcf;
figure(f_gui);

% determine which channels to display
prdata=getappdata(f_gui,'prdata');
image1_channel=get(handles.popupmenu1,'value');
image2_channel=get(handles.popupmenu2,'value');

if get(handles.popupmenu2,'value')==size(prdata.x,1)+1 %then we are doing sum normalization
    image2_channel=1:prdata.rp.num_np_channels;
end

image1_concentration=prdata.rp.concentrations(image1_channel);
image2_concentration=prdata.rp.concentrations(image2_channel);

% determine colormap
if isempty(invar.colormap)
   invar.colormap=prdata.colormap; 
end

if invar.use_registered_raman_image
   image1=squeeze(prdata.im2_reg_grayscale(image1_channel,:,:));
   image2=squeeze(prdata.im2_reg_grayscale(image2_channel,:,:));
else
    image1=squeeze(prdata.x(image1_channel,:,:));
    image2=squeeze(prdata.x(image2_channel,:,:));
end

% convert images back to linear scale
if prdata.rp.use_dB ~= 0
    image1=10.^(image1/20);
    image2=10.^(image2/20);
end

% concentration correction
if size(image2_channel,2)>1
    for channel_num=1:size(image2_channel,2)
        image2(channel_num,:,:)=image2(channel_num,:,:)/image2_concentration(channel_num);
    end
    image2=squeeze(sum(image2,1));
else
    image2=image2/image2_concentration;
end

image1=image1/image1_concentration;


% take ratio of the two images

if get(handles.popupmenu5,'Value')==1
    combined_image=image1./image2;
elseif get(handles.popupmenu5,'Value')==2
    combined_image=image1-image2;
elseif get(handles.popupmenu5,'Value')==3
    combined_image=image1;
end
if get(handles.checkbox2,'Value')
    combined_image=log10im(combined_image);
end
prdata.combined_image=combined_image;

if invar.save_result
    setappdata(f_gui,'prdata',prdata);
end

if isnan(str2double(get(handles.edit2,'string'))) || isnan(str2double(get(handles.edit3,'string')))
   autoScaleRatioImage(gcf,handles); 
end

%determine intensity scaling of image
% thresh_mask=determineThresholdMask(f_gui,handles);
% quant=quantile(combined_image(~isnan(combined_image)&thresh_mask),10);
% ratio_range=[quant(3) quant(8)];
% ratio_range=autoScaleRatioImage(f_gui,handles);
ratio_range=[str2double(get(handles.edit2,'string')) str2double(get(handles.edit3,'string'))];
if sum(ratio_range==[1 1])==2
    ratio_range=[0 1];
end

ratio_rgb=intensity2RGB(combined_image,invar.colormap,ratio_range);

% if we are thresholding
if get(handles.checkbox1,'Value')
    raw=log10imInv(prdata.im2_reg_grayscale);
    threshold=str2num(get(handles.edit1,'String'));
    thresh_mask = determineThresholdMask(f_gui,handles);
    prdata.thresh_mask=thresh_mask;
    for rgb_num=1:3
        ratio_rgb(:,:,rgb_num)=squeeze(ratio_rgb(:,:,rgb_num)).*thresh_mask;
    end
end

% if there is a mask
if isfield(prdata,'current_mask')
    for rgb_num=1:3
        ratio_rgb(:,:,rgb_num)=squeeze(ratio_rgb(:,:,rgb_num)).*prdata.current_mask;
    end
end

if invar.save_result
    setappdata(f_gui,'prdata',prdata);
end

ax1_img=squeeze(prdata.im1_reg_rgb(1,:,:,:));
ratio_rgb=imfuse(ax1_img,ratio_rgb,'blend');

axes(handles.axes5);
hold off
imagesc(ratio_rgb,ratio_range);
colormap(prdata.colormap)
colorbar(handles.axes5)
axis image off

plotContour(handles);

if nargout == 1
    out=struct('rgb',ratio_rgb,'scale',ratio_range,'colormap',prdata.colormap,'ratio_image',combined_image);
    varargout{1}=out;
end

% return active figure to what it was at function call
figure(current_figure);

% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

updateImages(handles);

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function updateImages(handles)

prdata=getappdata(gcf,'prdata');
channel=get(handles.slider1,'Value');
f_gui=gcf;

ax1_img=squeeze(prdata.im1_reg_rgb(channel,:,:,:));
ax2_img=squeeze(prdata.im2_reg_rgb(channel,:,:,:));
ax3_img=squeeze(prdata.fused(channel,:,:,:));

% if threshold button is on, then do it
if get(handles.checkbox1,'Value')
    raw=log10imInv(prdata.im2_reg_grayscale);
    threshold=str2num(get(handles.edit1,'String'));
    thresh_mask=determineThresholdMask(f_gui,handles);
%     thresh_mask=double(raw>threshold);
    
    for rgb_num=1:3
        ax2_img(:,:,rgb_num)=squeeze(ax2_img(:,:,rgb_num)).*thresh_mask;
    end
    ax3_img=imfuse(ax1_img,ax2_img,'blend');
else
    ax1_img=squeeze(prdata.im1_reg_rgb(channel,:,:,:));
    ax2_img=squeeze(prdata.im2_reg_rgb(channel,:,:,:));
    ax3_img=squeeze(prdata.fused(channel,:,:,:));
end

% set images
axes(handles.axes1)
set(handles.text4,'String','photograph');
imagesc(ax1_img)
axis image off

axes(handles.axes2)
set(handles.text5,'String',prdata.channel_names{channel});
imagesc(ax2_img)
axis image off

axes(handles.axes3)
set(handles.text6,'String',prdata.channel_names{channel});
title(prdata.channel_names{channel});
imagesc(ax3_img)
axis image off


% --- Executes on button press in checkbox1.

function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1

updateImages(handles);
updateRatioImage(gcf,handles);
prdata=getappdata(gcf,'prdata');
prdata.vrprops.checkbox1_value=get(hObject,'Value');
setappdata(gcf,'prdata',prdata);
% prdata=rmfield(prdata,'im2_raw');
% save(prdata.pr_file_loc,'prdata');


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double

if isempty(str2num(get(hObject,'String')))
   set(hObject,'String',0);
   set(handles.checkbox1,'Value',0);
end

cf=gcf;

tic
updateImages(handles);
t=toc;

% flash a "please wait" message if this is going to take a while:
if t >0.2
    f_h=figure;
    imagesc(ones(20,100));
    text(10,10,'working, please wait','FontSize',30)
    axis image off
    drawnow
end
updateRatioImage(cf,handles);
if t>0.2
    figure(f_h);
end
prdata=getappdata(cf,'prdata');
prdata.vrprops.edit1_string=get(hObject,'String');
setappdata(cf,'prdata',prdata);
% prdata=rmfield(prdata,'im2_raw');
% save(prdata.pr_file_loc,'prdata');
if t>0.2
    close(f_h);
end
figure(cf);

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

set(hObject,'String','0');


% --- Executes on selection change in popupmenu4.
function popupmenu4_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu4
updateImages(handles);
updateRatioImage(gcf,handles);

prdata=getappdata(gcf,'prdata');
prdata.vrprops.popupmenu4_value=get(hObject,'Value');
setappdata(gcf,'prdata',prdata);
% prdata=rmfield(prdata,'im2_raw');
% save(prdata.pr_file_loc,'prdata');


% --- Executes during object creation, after setting all properties.
function popupmenu4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function thresh_mask = determineThresholdMask(f_gui,handles)

prdata=getappdata(f_gui,'prdata');
threshold_option=get(handles.popupmenu4,'Value');
threshold=str2num(get(handles.edit1,'String'));

if threshold_option>=0 && threshold_option<=size(prdata.channel_names,2)
    if prdata.rp.use_dB
        raw=log10imInv(squeeze(prdata.im2_reg_grayscale(threshold_option,:,:)));
    else
        raw=squeeze(prdata.im2_reg_grayscale(threshold_option,:,:));
    end
elseif threshold_option == size(prdata.channel_names,2)+1
    raw=prdata.combined_image;
elseif threshold_option == size(prdata.channel_names,2)+2
    raw=squeeze(sum(prdata.im2_reg_grayscale(1:prdata.rp.num_np_channels,:,:)));
end

thresh_mask=raw>=threshold;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setupGui(handles);


% --- Executes on selection change in popupmenu5.
function popupmenu5_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu5
% get(handles.popupmenu5,'Value')

% setappdata(gcf,'prdata',out);
updateRatioImage(gcf,handles);

% --- Executes during object creation, after setting all properties.
function popupmenu5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ratio_out = updateRatioImage(gcf,handles);
figure,imagesc(ratio_out.rgb,ratio_out.scale);
colorbar
colormap(ratio_out.colormap);
axis image off
% keyboard;


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

prdata=getappdata(gcf,'prdata');
f_gui=gcf;
f_new=figure;
plotDecomp(f_gui,handles,'f_h',f_new);
axis square
leg=prdata.channel_names;
leg(2:end+1)=leg;
leg{1}='raw spectrum';
leg{size(leg,2)+1}='sum of all';
legend(leg)
niceFigure(gcf);    


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% options
show_photo=1; % 1 or 0

%% display

prdata=getappdata(gcf,'prdata');
channel=get(handles.slider1,'Value');
f_gui=gcf;
fs=20;

ax1_img=squeeze(prdata.im1_reg_rgb(channel,:,:,:));
img_nan=isnan(ax1_img);
% num_channels=sum(cell2mat(strfind(prdata.channel_names,'S')));
ax1_img(img_nan)=1;
% num_plots=prdata.rp.num_np_channels+(prdata.rp.num_np_channels-1)+1; %one for each channel, one for each ratio, one for photograph
num_plots=prdata.rp.num_np_channels + show_photo; 

%ratio image:
ri = updateRatioImage(f_gui,handles);

% one row:
num_row=1;
num_col=num_plots;

% rectangle
% num_row=ceil(sqrt(num_plots));
% num_col=ceil(num_plots/num_row);
f_popup=figure;

% show photo
if show_photo
    subplot(num_row,num_col,1)
    imagesc(prdata.im1);
    axis image off
    title('photograph')
%     colorbar
end

% set channel names
% prdata.channel_names{1}='s420-CA9';
% prdata.channel_names{2}='s421-hIgG4';
% prdata.channel_names{3}='s440-CD47';

for channel_num=1:prdata.rp.num_np_channels
    subplot(num_row,num_col,channel_num+show_photo);
    
    % show each channel without blending
    %ax2_img=squeeze(prdata.im2_reg_rgb(channel_num,:,:,:));
    
    % show fused images
    ax2_img=squeeze(prdata.im2_reg_rgb(channel_num,:,:,:));

    % threshold options
    thresh_mask=determineThresholdMask(f_gui,handles);
%     thresh_mask=ones(size(squeeze(ax2_img(:,:,1))));
    
    for rgb_num=1:3
        ax2_img(:,:,rgb_num)=squeeze(ax2_img(:,:,rgb_num)).*thresh_mask;
    end
    
    % optional fuse
    ax3_img=imfuse(ax1_img,ax2_img,'blend');
    ax3_img(img_nan)=255;
    %ax3_img = ax2_img;
    
    % display
    % squeeze(prdata.im2.x(channel_num,:,:)).*thresh_mask
    c_range=[str2double(get(handles.edit2,'string')) str2double(get(handles.edit3,'string'))];
%     c_range = [0 1];
    imagesc(ax3_img,c_range); %% this scale might not be appropriate!!! fix later
    axis image off
%     colormap(prdata.colormap);
%     colorbar
    title(prdata.channel_names{channel_num},'FontSize',fs);
end

niceFigure(f_popup);
figure(f_gui);
updateRatioImage(gcf,handles);

figure,imagesc(ones(64));
colormap(prdata.colormap);
colorbar

% imagesc(ri.rgb,ri.scale);



% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2
updateRatioImage(gcf,handles);



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double

updateRatioImage(gcf,handles);

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double

updateRatioImage(gcf,handles);

% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ratio_range=autoScaleRatioImage(gcf,handles);
prdata=getappdata(gcf,'prdata');
prdata.ratio_range=ratio_range;
setappdata(gcf,'prdata',prdata);
updateRatioImage(gcf,handles);

function ratio_range=autoScaleRatioImage(gcf,handles)

prdata=getappdata(gcf,'prdata');

thresh_mask=determineThresholdMask(gcf,handles);
%if thresh_mask is blank, make it ones
if sum(sum(thresh_mask==0))==numel(thresh_mask)
    thresh_mask=ones(size(thresh_mask));
end
quant=quantile(prdata.combined_image(~isnan(prdata.combined_image)&thresh_mask),10);

ratio_range=[quant(3) quant(8)];
set(handles.edit2,'string',num2str(ratio_range(1)));
set(handles.edit3,'string',num2str(ratio_range(2)));


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(handles.checkbox1,'Value')
    % load image data
    prdata=getappdata(gcf,'prdata');
    
    axes(handles.axes5);
    title('Click on tissue sample');
    
    % wait until user gives a valid click
    k=1;
    axis5_click=0;
    while k~=0 || axis5_click==0
        k = waitforbuttonpress;
        click_location5=get(handles.axes5,'CurrentPoint');
        axis5_click=(click_location5(1,2)>=1)&&(click_location5(1,2)<=size(prdata.im1_reg_rgb,2))&&(click_location5(1,1)>=1)&&(click_location5(1,1)<=size(prdata.im1_reg_rgb,3));
    end
    
    axes(handles.axes5);
    title('');

    % generate ROI
    roi_in=zeros(size(prdata.im2_reg_grayscale,2),size(prdata.im2_reg_grayscale,3));
    roi_in(round(click_location5(1,2)),round(click_location5(1,1)))=1;
    
    mask=prdata.thresh_mask;
    
    prdata.current_roi = growRoi(roi_in,mask);
    setappdata(gcf,'prdata',prdata);
    updateRatioImage(gcf,handles);
    plotContour(handles);
    updateTable(handles);

else
    msgbox('Threshold box must be checked','Error')
end

function plotContour(handles)

prdata=getappdata(gcf,'prdata');
if isfield(prdata,'current_roi') && sum(sum(prdata.current_roi))>0
    axes(handles.axes5);
    hold on
    contour(prdata.current_roi,1,'LineWidth',2,'color','c');
end


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

prdata=getappdata(gcf,'prdata');
if isfield(prdata,'current_roi')
    prdata.current_roi=zeros(size(prdata.current_roi));
    setappdata(gcf,'prdata',prdata);
    updateRatioImage(gcf,handles);
end


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

prdata=getappdata(gcf,'prdata');
roi_values=prdata.combined_image(prdata.current_roi);
group_number = get(handles.popupmenu6,'Value');
group_strings = get(handles.popupmenu6,'String');
group_name=group_strings{group_number};

if ~evalin('base','exist(''roi_value_struct'')')
    roi_value_struct=struct('group',group_name,'values',roi_values,'file_path',prdata.rp.im2_path,'file_name',prdata.rp.im2_filename);
else
    roi_value_struct = evalin('base','roi_value_struct');
    roi_value_struct(size(roi_value_struct,2)+1)=struct('group',group_name,'values',roi_values,'file_path',prdata.rp.im2_path,'file_name',prdata.rp.im2_filename);
end

assignin('base','roi_value_struct',roi_value_struct);

% --- Executes on selection change in popupmenu6.
function popupmenu6_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu6 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu6


% --- Executes during object creation, after setting all properties.
function popupmenu6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function updateTable(handles,varargin)
invar = struct('update_ratio_image',1);
argin = varargin;
invar = generateArgin(invar,argin);

prdata=getappdata(gcf,'prdata');

% set the values of x for this voxel in the table
if isfield(prdata,'im2_loc_rc')
    table_data=[prdata.x(:,prdata.im2_loc_rc(1),prdata.im2_loc_rc(2)) prdata.im2_reg_grayscale(:,floor(prdata.click_location_rc(1)),floor(prdata.click_location_rc(2)))];
else
    table_data=0;
end

% if roi is specified, add mean and stdev
if invar.update_ratio_image
    updateRatioImage(gcf,handles);
end
if isfield(prdata,'current_roi') && isfield(prdata,'combined_image')
    if get(handles.checkbox2,'Value') == 0 
        if sum(sum(prdata.current_roi)) > 0
            table_data(size(table_data,1)+1,1)=mean(prdata.combined_image(logical(prdata.current_roi)));
            table_data(size(table_data,1)+1,1)=std(prdata.combined_image(logical(prdata.current_roi)));
        else
            table_data(size(table_data,1)+1,1)=0;
            table_data(size(table_data,1)+1,1)=0;
        end
    else
        table_data(size(table_data,1)+1,2)=mean(prdata.combined_image(prdata.current_roi));
        table_data(size(table_data,1)+1,2)=std(prdata.combined_image(prdata.current_roi));
    end
end
set(handles.uitable1,'Data',table_data);


% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prdata=getappdata(gcf,'prdata');
setupGui(handles,'prdata',processRaman(prdata.pr_file_loc,'data_input_mode',2,'redo',5,'input_data',prdata),'first_call',0,'prdata_source',2);
updateRatioImage(gcf,handles);


% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

prdata=getappdata(gcf,'prdata');
setupGui(handles,'prdata',processRaman(prdata.pr_file_loc,'data_input_mode',2,'redo',6,'input_data',prdata),'first_call',0,'prdata_source',2);
prdata=getappdata(gcf,'prdata');

% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prdata=getappdata(gcf,'prdata');
click_location_xy=prdata.click_location_xy;
setupGui(handles,'prdata',processRaman(prdata.pr_file_loc,'data_input_mode',2,'redo',7,'input_data',prdata),'first_call',0,'prdata_source',2);
updateRatioImage(gcf,handles);

% reset the old click position
prdata=getappdata(gcf,'prdata');
prdata.click_location_xy=click_location_xy;
setappdata(gcf,'prdata',prdata);
plotDecomp(gcf,handles);

% update pulldown menues
set(handles.popupmenu1,'string',prdata.channel_names);
set(handles.popupmenu2,'string',[prdata.channel_names {'sum'}]);


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3
plotDecomp(gcf,handles,'update_ratio_image',0);

function setVRProperties(vrprops,handles)

if isfield(vrprops,'checkbox1_value')
    set(handles.checkbox1,'value',vrprops.checkbox1_value);
end

if isfield(vrprops,'popupmenu4_value')
    set(handles.popupmenu4,'value',vrprops.popupmenu4_value);
end

if isfield(vrprops,'edit1_string')
    set(handles.edit1,'string',vrprops.edit1_string);
end


% --- Executes on button press in pushbutton15.
function pushbutton15_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

prdata=getappdata(gcf,'prdata');
axes(handles.axes5);
prdata.current_roi = roipoly;
setappdata(gcf,'prdata',prdata);
updateRatioImage(gcf,handles);
plotContour(handles);
updateTable(handles);


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4
plotDecomp(gcf,handles,'update_ratio_image',0);


% --- Executes on button press in pushbutton16.
function pushbutton16_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(get(hObject,'String'),'Draw Mask')
    prdata=getappdata(gcf,'prdata');
    axes(handles.axes5);
    prdata.current_mask = roipoly;
    setappdata(gcf,'prdata',prdata);
    updateRatioImage(gcf,handles);
    set(hObject,'String','Del. Mask');
elseif strcmp(get(hObject,'String'),'Del. Mask')
    prdata=getappdata(gcf,'prdata');
    if isfield(prdata,'current_mask')
        prdata=rmfield(prdata,'current_mask');
    end
    setappdata(gcf,'prdata',prdata);
    updateRatioImage(gcf,handles);
    set(hObject,'String','Draw Mask');
end
