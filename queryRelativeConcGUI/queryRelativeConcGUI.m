function varargout = queryRelativeConcGUI(varargin)
% QUERYRELATIVECONCGUI MATLAB code for queryRelativeConcGUI.fig
%      QUERYRELATIVECONCGUI, by itself, creates a new QUERYRELATIVECONCGUI or raises the existing
%      singleton*.
%
%      H = QUERYRELATIVECONCGUI returns the handle to a new QUERYRELATIVECONCGUI or the handle to
%      the existing singleton*.
%
%      QUERYRELATIVECONCGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in QUERYRELATIVECONCGUI.M with the given input arguments.
%
%      QUERYRELATIVECONCGUI('Property','Value',...) creates a new QUERYRELATIVECONCGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before queryRelativeConcGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to queryRelativeConcGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help queryRelativeConcGUI

% Last Modified by GUIDE v2.5 04-May-2017 12:23:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @queryRelativeConcGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @queryRelativeConcGUI_OutputFcn, ...
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


% --- Executes just before queryRelativeConcGUI is made visible.
function queryRelativeConcGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to queryRelativeConcGUI (see VARARGIN)

% Choose default command line output for queryRelativeConcGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

if nargin <= 3
    error('must pass Raman channel names in GUI call');
end
if nargin>=4
    prdata.channel_names=varargin{1};
end
if nargin>=5
    prdata.concentrations=varargin{2};
else
    prdata.concentrations=ones(size(prdata.channel_names));
end
if nargin>=6
    prdata.control_channel=varargin{3};
else
    prdata.control_channel=1;
end
channel_names_plus_none=prdata.channel_names;
channel_names_plus_none{size(channel_names_plus_none,2)+1}='none';
set(handles.popupmenu1,'String',channel_names_plus_none);
set(handles.popupmenu2,'String',prdata.channel_names);
set(handles.popupmenu1,'Value',prdata.control_channel);
set(handles.edit1,'String',num2str(prdata.concentrations(get(handles.popupmenu2,'Value'))));
setappdata(gcf,'prdata',prdata);
% UIWAIT makes queryRelativeConcGUI wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = queryRelativeConcGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
prdata=getappdata(gcf,'prdata');
varargout{1} = prdata.concentrations;
varargout{2} = get(handles.popupmenu1,'value');
close(gcf);

% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1

prdata=getappdata(gcf,'prdata');
prdata.concentrations(get(hObject,'Value'))=1;
set(handles.edit1,'String',num2str(prdata.concentrations(get(handles.popupmenu2,'Value'))));
setappdata(gcf,'prdata',prdata);


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


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uiresume(handles.figure1);

% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2

prdata=getappdata(gcf,'prdata');
prdata.concentrations(get(handles.popupmenu1,'Value'))=1;
set(handles.edit1,'String',num2str(prdata.concentrations(get(handles.popupmenu2,'Value'))));
setappdata(gcf,'prdata',prdata);

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


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double

prdata=getappdata(gcf,'prdata');
text=get(hObject,'String');
num=str2num(text);
if isempty(num)
    set(hObject,'String','1');
    prdata.concentrations(get(handles.popupmenu2,'Value'))=1;
else
    prdata.concentrations(get(handles.popupmenu2,'Value'))=num;
    ensureControlNPIsOne(handles);
end
setappdata(gcf,'prdata',prdata);

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

function ensureControlNPIsOne(handles)

pu1_str=get(handles.popupmenu1,'String');
pu2_str=get(handles.popupmenu2,'String');
if strcmp(pu1_str{get(handles.popupmenu1,'Value')},pu2_str{get(handles.popupmenu2,'Value')})
    prdata.concentrations(get(handles.popupmenu2,'Value'))=1;
    set(handles.edit1,'String',num2str(1));
end
