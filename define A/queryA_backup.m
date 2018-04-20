%call: [A,wavenumber,channel_names,num_np_channels,A_info]=queryA(rp.A_info);

function varargout = queryA(varargin)
% QUERYA MATLAB code for queryA.fig
%      QUERYA by itself, creates a new QUERYA or raises the
%      existing singleton*.
%
%      H = QUERYA returns the handle to a new QUERYA or the handle to
%      the existing singleton*.
%
%      QUERYA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in QUERYA.M with the given input arguments.
%
%      QUERYA('Property','Value',...) creates a new QUERYA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before queryA_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to queryA_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help queryA

% Last Modified by GUIDE v2.5 04-May-2017 09:56:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @queryA_OpeningFcn, ...
                   'gui_OutputFcn',  @queryA_OutputFcn, ...
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

% --- Executes just before queryA is made visible.
function queryA_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to queryA (see VARARGIN)

% Choose default command line output for queryA
handles.output = 'Yes';

% Update handles structure
guidata(hObject, handles);

% Insert custom Title and Text if specified by the user
% Hint: when choosing keywords, be sure they are not easily confused 
% with existing figure properties.  See the output of set(figure) for
% a list of figure properties.
if(nargin > 3)
    for index = 1:2:(nargin-3),
        if nargin-3==index, break, end
        switch lower(varargin{index})
         case 'title'
          set(hObject, 'Name', varargin{index+1});
         case 'string'
          set(handles.text1, 'String', varargin{index+1});
        end
    end
end

% Determine the position of the dialog - centered on the callback figure
% if available, else, centered on the screen
FigPos=get(0,'DefaultFigurePosition');
OldUnits = get(hObject, 'Units');
set(hObject, 'Units', 'pixels');
OldPos = get(hObject,'Position');
FigWidth = OldPos(3);
FigHeight = OldPos(4);
if isempty(gcbf)
    ScreenUnits=get(0,'Units');
    set(0,'Units','pixels');
    ScreenSize=get(0,'ScreenSize');
    set(0,'Units',ScreenUnits);

    FigPos(1)=1/2*(ScreenSize(3)-FigWidth);
    FigPos(2)=2/3*(ScreenSize(4)-FigHeight);
else
    GCBFOldUnits = get(gcbf,'Units');
    set(gcbf,'Units','pixels');
    GCBFPos = get(gcbf,'Position');
    set(gcbf,'Units',GCBFOldUnits);
    FigPos(1:2) = [(GCBFPos(1) + GCBFPos(3) / 2) - FigWidth / 2, ...
                   (GCBFPos(2) + GCBFPos(4) / 2) - FigHeight / 2];
end
FigPos(3:4)=[FigWidth FigHeight];
set(hObject, 'Position', FigPos);
set(hObject, 'Units', OldUnits);

% % Show a question icon from dialogicons.mat - variables questIconData
% % and questIconMap
% load dialogicons.mat
% 
% IconData=questIconData;
% questIconMap(256,:) = get(handles.figure1, 'Color');
% IconCMap=questIconMap;
% 
% Img=image(IconData, 'Parent', handles.axes1);
% set(handles.figure1, 'Colormap', IconCMap);

% set(handles.axes1, ...
%     'Visible', 'off', ...
%     'YDir'   , 'reverse'       , ...
%     'XLim'   , get(Img,'XData'), ...
%     'YLim'   , get(Img,'YData')  ...
%     );

% Make the GUI modal
set(handles.figure1,'WindowStyle','modal')

% load data for defining A
% out = readRamanEndoscopeTxt('C:\Users\rdavis5\Dropbox\process and visualize Raman - sharable\background\define A gui\quartz and water background 23x11.txt');
% prdata.endoscope_quartz_and_water=out.spectra;
load(strcat(getParentDir('standard spectra'),'reference standards.mat'));
prdata.endoscope_wavenumber=raman_shift_end;
prdata.endoscope_s420=s420_background_subtracted_end;
prdata.endoscope_s421=s421_background_subtracted_end;
prdata.endoscope_s440=s440_background_subtracted_end;
prdata.endoscope_s481=s481_background_subtracted_end;
prdata.endoscope_s482=s482_background_subtracted_end;
prdata.endoscope_cp3=cp3_background_subtracted_end;
prdata.endoscope_ir785=ir785_background_subtracted_end;
prdata.microscope_ddtc=ddtc_mic;
prdata.microscope_ir775=ir775_mic;
prdata.microscope_ir780=ir780_mic;
prdata.microscope_ir797=ir797_mic;
prdata.microscope_ir813=ir813_mic;
prdata.microscope_wavenumber=raman_shift_mic;
setappdata(gcf,'prdata',prdata);

if nargin==3 || (nargin ==4 && isempty(varargin{1})) %defaults
    % set default background spectra
    prdata.quartz_background_folder=getParentDir('quartz background');
    prdata.quartz_background_file='default endoscope background quartz.txt';
    prdata.tissue_background_folder=getParentDir('tissue background');
    prdata.tissue_background_file='default endoscope background tissue.txt';


    set(handles.checkbox4,'value',1)

    % set default values
    set(handles.checkbox1,'value',1);
    set(handles.checkbox2,'value',1);
    set(handles.checkbox3,'value',1);
    set(handles.checkbox4,'value',1);
    set(handles.checkbox5,'value',1);
    set(handles.popupmenu2,'value',3);
    set(handles.edit1,'string','1');
    

    set(handles.edit4,'string','0');
    setDefaultFitRange(handles)
elseif (nargin ==4 && ~isempty(varargin{1})) %use previously defined values
    A_info=varargin{1};
    prdata.num_np_channels=A_info.num_np_channels;
    set(handles.checkbox1,'Value',A_info.standards(1));
    set(handles.checkbox2,'Value',A_info.standards(2));
    set(handles.checkbox3,'Value',A_info.standards(3));
    set(handles.checkbox8,'Value',A_info.standards(4));
    set(handles.checkbox9,'Value',A_info.standards(5));
    set(handles.checkbox10,'Value',A_info.standards(6));
    set(handles.checkbox11,'Value',A_info.standards(7));
    prdata.quartz_background_folder=A_info.quartz_background_folder;
    prdata.tissue_background_folder=A_info.tissue_background_folder;
    prdata.quartz_background_file=A_info.quartz_background_file;
    prdata.tissue_background_file=A_info.tissue_background_file;
    set(handles.popupmenu2,'value',A_info.num_pcs);
    set(handles.checkbox4,'value',A_info.include_quartz);
    set(handles.checkbox6,'value',A_info.include_tissue);    
    set(handles.checkbox5,'value',A_info.constant); 
    set(handles.checkbox17,'value',A_info.linear);
    set(handles.edit1,'string',A_info.smooth_amount);
    set(handles.checkbox7,'value',A_info.smooth_bool);
    set(handles.edit2,'string',num2str(A_info.A_range(1)));
    set(handles.edit3,'string',num2str(A_info.A_range(2)));
    set(handles.edit4,'string',num2str(A_info.wavenumber_shift));
else
    error('must be 0 or 1 arguments for input');
end
setappdata(gcf,'prdata',prdata);
modeCallback(handles);
makeBackgroundPCs(handles);
createA(handles);
% UIWAIT makes queryA wait for user response (see UIRESUME)
uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = queryA_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
prdata=getappdata(gcf,'prdata');

standards=[get(handles.checkbox1,'Value') get(handles.checkbox2,'Value') get(handles.checkbox3,'Value') get(handles.checkbox8,'Value') get(handles.checkbox9,'Value') get(handles.checkbox10,'Value') get(handles.checkbox11,'Value')]; 
A_range=[str2double(get(handles.edit2,'string')) str2double(get(handles.edit3,'string'))];
a_info=struct('num_np_channels',prdata.num_np_channels,'standards',standards,'quartz_background_folder',prdata.quartz_background_folder,'quartz_background_file',prdata.quartz_background_file,'tissue_background_folder',prdata.tissue_background_folder,'tissue_background_file',prdata.tissue_background_file,'num_pcs',get(handles.popupmenu2,'value'),'include_quartz',get(handles.checkbox4,'value'),'include_tissue',get(handles.checkbox6,'value'),'constant',get(handles.checkbox5,'value'),'linear',get(handles.checkbox17,'value'),'smooth_amount',str2num(get(handles.edit1,'string')),'smooth_bool',get(handles.checkbox7,'value'),'A_range',A_range,'raman_shift_range',prdata.raman_shift_range,'wavenumber_shift',str2double(get(handles.edit4,'string')));

varargout{1} = prdata.A;
varargout{2} = prdata.wavenumber(prdata.raman_shift_range);
varargout{3} = prdata.channel_names;
varargout{4} = prdata.num_np_channels;
varargout{5} = a_info;


% The figure can be deleted now
delete(hObject);

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = get(hObject,'String');

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure1);

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = get(hObject,'String');

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure1);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end


% --- Executes on key press over figure1 with no controls selected.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Check for "enter" or "escape"
if isequal(get(hObject,'CurrentKey'),'escape')
    % User said no by hitting escape
    handles.output = 'No';
    
    % Update handles structure
    guidata(hObject, handles);
    
    uiresume(handles.figure1);
end    
    
if isequal(get(hObject,'CurrentKey'),'return')
    uiresume(handles.figure1);
end    


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
setDefaultFitRange(handles);
modeCallback(handles);
createA(handles);

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


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4
createA(handles);


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1

createA(handles);

% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2

createA(handles);
% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3
createA(handles);

function createA(handles)

makeBackgroundPCs(handles);
prdata=getappdata(gcf,'prdata');
raman_shift_range = findRamanShiftRange(handles);
A=zeros(size(raman_shift_range));
channel_names={};
prdata.num_np_channels=0;

modes=get(handles.popupmenu1,'string');
mode=lower(modes{get(handles.popupmenu1,'value')});

if get(handles.checkbox9,'Value')
    A(size(A,1)+1,:)=prdata.(strcat(mode,'_s420'))(raman_shift_range);
    channel_names{size(channel_names,2)+1}='s420';
    prdata.num_np_channels=prdata.num_np_channels+1;
end

if get(handles.checkbox1,'Value')
    A(size(A,1)+1,:)=prdata.(strcat(mode,'_s421'))(raman_shift_range);
    channel_names{size(channel_names,2)+1}='s421';
    prdata.num_np_channels=prdata.num_np_channels+1;
end
if get(handles.checkbox2,'Value')
    A(size(A,1)+1,:)=prdata.(strcat(mode,'_s440'))(raman_shift_range);
    channel_names{size(channel_names,2)+1}='s440';
    prdata.num_np_channels=prdata.num_np_channels+1;
end
if get(handles.checkbox3,'Value')
    A(size(A,1)+1,:)=prdata.(strcat(mode,'_s481'))(raman_shift_range);
    channel_names{size(channel_names,2)+1}='s481';
    prdata.num_np_channels=prdata.num_np_channels+1;
end

if get(handles.checkbox8,'Value')
    A(size(A,1)+1,:)=prdata.(strcat(mode,'_s482'))(raman_shift_range);
    channel_names{size(channel_names,2)+1}='s482';
    prdata.num_np_channels=prdata.num_np_channels+1;
end



if get(handles.checkbox10,'Value')
    A(size(A,1)+1,:)=prdata.(strcat(mode,'_cp3'))(raman_shift_range);
    channel_names{size(channel_names,2)+1}='cp3';
    prdata.num_np_channels=prdata.num_np_channels+1;
end

if get(handles.checkbox11,'Value')
    A(size(A,1)+1,:)=prdata.(strcat(mode,'_s481'))(raman_shift_range);
    channel_names{size(channel_names,2)+1}='IR785';
    prdata.num_np_channels=prdata.num_np_channels+1;
end

if get(handles.checkbox12,'Value')
    A(size(A,1)+1,:)=prdata.(strcat(mode,'_ddtc'))(raman_shift_range);
    channel_names{size(channel_names,2)+1}='DDTC';
    prdata.num_np_channels=prdata.num_np_channels+1;
end

if get(handles.checkbox13,'Value')
    A(size(A,1)+1,:)=prdata.(strcat(mode,'_ir775'))(raman_shift_range);
    channel_names{size(channel_names,2)+1}='IR775';
    prdata.num_np_channels=prdata.num_np_channels+1;
end

if get(handles.checkbox14,'Value')
    A(size(A,1)+1,:)=prdata.(strcat(mode,'_ir780'))(raman_shift_range);
    channel_names{size(channel_names,2)+1}='IR780';
    prdata.num_np_channels=prdata.num_np_channels+1;
end

if get(handles.checkbox15,'Value')
    A(size(A,1)+1,:)=prdata.(strcat(mode,'_ir797'))(raman_shift_range);
    channel_names{size(channel_names,2)+1}='IR797';
    prdata.num_np_channels=prdata.num_np_channels+1;
end

if get(handles.checkbox16,'Value')
    A(size(A,1)+1,:)=prdata.(strcat(mode,'_ir813'))(raman_shift_range);
    channel_names{size(channel_names,2)+1}='IR813';
    prdata.num_np_channels=prdata.num_np_channels+1;
end

% add background spectra
if get(handles.checkbox4,'Value') || get(handles.checkbox6,'Value')
    num_pcs_include=get(handles.popupmenu2,'Value');
    A(size(A,1)+1:size(A,1)+num_pcs_include,:)=prdata.pcs(:,1:num_pcs_include).';
    for pc_num=1:num_pcs_include
        channel_names{size(channel_names,2)+1}=strcat('background-PC',num2str(pc_num));
    end
end

if get(handles.checkbox5,'Value')
    A(size(A,1)+1,:)=normr(ones(size(raman_shift_range)));
    channel_names{size(channel_names,2)+1}='constant';
end

if get(handles.checkbox17,'Value')
    A(size(A,1)+1,:)=normr(1:size(raman_shift_range,2));
    channel_names{size(channel_names,2)+1}='linear';
end

axes(handles.axes3)
if isempty(A)
    plot([],[]);
else
    plot(prdata.endoscope_wavenumber(raman_shift_range),A);
    xlim([min(prdata.endoscope_wavenumber(raman_shift_range)) max(prdata.endoscope_wavenumber(raman_shift_range))]);
end
prdata.A=A(2:end,:);
prdata.channel_names=channel_names;
prdata.raman_shift_range=raman_shift_range;
setappdata(gcf,'prdata',prdata);
% keyboard;


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2

createA(handles);

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


% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox5
createA(handles);

function makeBackgroundPCs(handles)
prdata=getappdata(gcf,'prdata');
background_spectra=[];
if get(handles.checkbox4,'value')
    if get(handles.popupmenu1,'value')==1
        quartz_out = readRamanEndoscopeTxt(strcat(getParentDir('quartz background'),prdata.quartz_background_file));
        background_wavenumber=quartz_out.wavenumber;
    else
        quartz_out = readRenishawSpc(strcat(getParentDir('quartz background'),prdata.quartz_background_file));
        background_wavenumber=quartz_out.wavenumber;
    end
    background_spectra=[background_spectra;quartz_out.spectra];
end
if get(handles.checkbox6,'value')
    if get(handles.popupmenu1,'value')==1
        tissue_out = readRamanEndoscopeTxt(strcat(getParentDir('tissue background'),prdata.tissue_background_file));
        background_wavenumber=quartz_out.wavenumber;
    else
        tissue_out = readRenishawSpc(strcat(getParentDir('tissue background'),prdata.quartz_background_file));
        background_wavenumber=quartz_out.wavenumber;
    end
    background_spectra=[background_spectra;tissue_out.spectra];
end


% find range and perform PCA
% setDefaultFitRange(handles);
[~,low_bin]=min(abs(prdata.wavenumber-str2double(get(handles.edit2,'string'))));
[~,high_bin]=min(abs(prdata.wavenumber-str2double(get(handles.edit3,'string'))));


coeff=pca(background_spectra(:,low_bin:high_bin));

% interpolate background pca's to the right x-axis
if get(handles.popupmenu1,'value')==2 %microscope
    coeff_to_interp=coeff;
    coeff=zeros(size(coeff,1),get(handles.popupmenu2,'value'));
    for pc_num=1:get(handles.popupmenu2,'value')
        coeff(:,pc_num)=interp1(background_wavenumber(low_bin:high_bin),coeff_to_interp(:,pc_num),prdata.wavenumber);
    end
    coeff(isnan(coeff))=0;
%     keyboard;
end

prdata.pcs=coeff;
if get(handles.checkbox7,'value')
    smooth_amount=str2double(get(handles.edit1,'string'));
    for pc_num=1:get(handles.popupmenu2,'value')
       prdata.pcs(:,pc_num)=smooth(prdata.pcs(:,pc_num),smooth_amount); 
    end
end
prdata.A=[];
prdata.channel_names=[];
prdata.wavenumbers=[];
setappdata(gcf,'prdata',prdata);


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

prdata=getappdata(gcf,'prdata');
[FileName,PathName,~] = uigetfile(strcat(prdata.quartz_background_folder,'*.txt'));
prdata.quartz_background_folder=PathName;
prdata.quartz_background_file_endoscope=FileName;
setappdata(gcf,'prdata',prdata);
createA(handles);


% --- Executes on button press in checkbox6.
function checkbox6_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox6

createA(handles);

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prdata=getappdata(gcf,'prdata');
[FileName,PathName,~] = uigetfile(strcat(prdata.tissue_background_folder,'*.txt'));
prdata.tissue_background_folder=PathName;
prdata.tisue_background_file=FileName;
setappdata(gcf,'prdata',prdata);
createA(handles);




function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double

prdata=getappdata(gcf,'prdata');
edit_val=get(handles.edit1,'string');
if str2num(edit_val)
    prdata.smooth=str2num(edit_val);
else
    prdata.smooth=1;
    edit_val=set(handles.edit1,'string','1');
end

setappdata(gcf,'prdata',prdata);

createA(handles);


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



% --- Executes on button press in checkbox7.
function checkbox7_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox7
if get(hObject,'Value')
    set(handles.edit1,'Enable','On');
else
    set(handles.edit1,'Enable','Inactive');
end
createA(handles);



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double
prdata=getappdata(gcf,'prdata');
if isnan(str2double(get(hObject,'String')))
    set(hObject,'String',num2str(min(prdata.endoscope_wavenumber)));
end

% set wavenumbers
shift_range = findRamanShiftRange(handles);
if get(handles.popupmenu1,'value')==1
    prdata.wavenumber_selected=prdata.endoscope_wavenumber(shift_range);
else
    prdata.wavenumber_selected=prdata.microscope_wavenumber(shift_range);
end
setappdata(gcf,'prdata',prdata);

createA(handles);

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

prdata=getappdata(gcf,'prdata');
if isnan(str2double(get(hObject,'String')))
    set(hObject,'String',num2str(max(prdata.endoscope_wavenumber)));
end

% set wavenumbers
shift_range = findRamanShiftRange(handles);
if get(handles.popupmenu1,'value')==1
    prdata.wavenumber_selected=prdata.endoscope_wavenumber(shift_range);
else
    prdata.wavenumber_selected=prdata.microscope_wavenumber(shift_range);
end
setappdata(gcf,'prdata',prdata);

createA(handles);


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

function shift_range = findRamanShiftRange(handles)
prdata=getappdata(gcf,'prdata');

if get(handles.popupmenu1,'value')==1
    [~,low_bin]=min(abs(prdata.endoscope_wavenumber-str2double(get(handles.edit2,'string'))));
    [~,high_bin]=min(abs(prdata.endoscope_wavenumber-str2double(get(handles.edit3,'string'))));
elseif get(handles.popupmenu1,'value')==2
    [~,low_bin]=min(abs(prdata.microscope_wavenumber-str2double(get(handles.edit2,'string'))));
    [~,high_bin]=min(abs(prdata.microscope_wavenumber-str2double(get(handles.edit3,'string'))));

else
    error('incorrect value of popupmenu');
end
shift_range=low_bin:high_bin;



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double

prdata=getappdata(gcf,'prdata');
if isnan(str2double(get(hObject,'String')))
    set(hObject,'String','0');
end
createA(handles);

% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox8.
function checkbox8_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox8
createA(handles);


% --- Executes on button press in checkbox9.
function checkbox9_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox9
createA(handles);


% --- Executes on button press in checkbox10.
function checkbox10_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox10
createA(handles);


% --- Executes on button press in checkbox11.
function checkbox11_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox11
createA(handles);


% --- Executes on button press in checkbox12.
function checkbox12_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox12
createA(handles);


% --- Executes on button press in checkbox13.
function checkbox13_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox13
createA(handles);


% --- Executes on button press in checkbox14.
function checkbox14_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox14

createA(handles);

% --- Executes on button press in checkbox15.
function checkbox15_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox15
createA(handles);


% --- Executes on button press in checkbox16.
function checkbox16_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox16
createA(handles);

function modeCallback(handles)
prdata=getappdata(gcf,'prdata');

if get(handles.popupmenu1,'value')==1 %endoscope
    set(handles.checkbox9,'enable','on'); %S420
    set(handles.checkbox1,'enable','on'); %S421
    set(handles.checkbox2,'enable','on'); %S440
    set(handles.checkbox3,'enable','on'); %S481
    set(handles.checkbox8,'enable','on'); %S482
    set(handles.checkbox10,'enable','on'); %cp3
    set(handles.checkbox12,'enable','inactive','value',0); %DDTC
    set(handles.checkbox13,'enable','on'); %IR775
    set(handles.checkbox14,'enable','inactive','value',0); %IR780
    set(handles.checkbox11,'enable','inactive','value',0); %IR785
    set(handles.checkbox15,'enable','inactive','value',0); %IR797
    set(handles.checkbox16,'enable','inactive','value',0); %IR813

    prdata.tissue_background_file='default endoscope background tissue.txt';
    prdata.quartz_background_file='default endoscope background quartz.txt';
    prdata.wavenumber=prdata.endoscope_wavenumber;
elseif get(handles.popupmenu1,'value')==2 %microscope
    set(handles.checkbox9,'enable','inactive','value',0); %S420
    set(handles.checkbox1,'enable','inactive','value',0); %S421
    set(handles.checkbox2,'enable','inactive','value',0); %S440
    set(handles.checkbox3,'enable','inactive','value',0); %S481
    set(handles.checkbox8,'enable','inactive','value',0); %S482
    set(handles.checkbox10,'enable','inactive','value',0); %cp3
    set(handles.checkbox12,'enable','on'); %DDTC
    set(handles.checkbox13,'enable','on');%IR775
    set(handles.checkbox14,'enable','on'); %IR780
    set(handles.checkbox11,'enable','on'); %IR785
    set(handles.checkbox15,'enable','on'); %IR797
    set(handles.checkbox16,'enable','on'); %IR813

    prdata.tissue_background_file='default microscope background tissue.spc';
    prdata.quartz_background_file='default microscope background quartz.spc';
    prdata.wavenumber=prdata.microscope_wavenumber;

end
prdata.wavenumber_selected=prdata.wavenumber;
setappdata(gcf,'prdata',prdata);


function setDefaultFitRange(handles)

prdata=getappdata(gcf,'prdata');

if get(handles.popupmenu1,'value')==1 %endoscope
    set(handles.edit2,'string',num2str(prdata.endoscope_wavenumber(1)));
    set(handles.edit3,'string',num2str(prdata.endoscope_wavenumber(end)));
elseif get(handles.popupmenu1,'value')==2 %microscope
    set(handles.edit2,'string',num2str(prdata.microscope_wavenumber(1)));
    set(handles.edit3,'string',num2str(prdata.microscope_wavenumber(end)));
end


% --- Executes on button press in checkbox17.
function checkbox17_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox17
createA(handles);