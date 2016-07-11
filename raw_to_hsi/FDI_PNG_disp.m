function varargout = FDI_PNG_disp(varargin)
% FDI_PNG_DISP MATLAB code for FDI_PNG_disp.fig
%      FDI_PNG_DISP, by itself, creates a new FDI_PNG_DISP or raises the existing
%      singleton*.
%
%      H = FDI_PNG_DISP returns the handle to a new FDI_PNG_DISP or the handle to
%      the existing singleton*.
%
%      FDI_PNG_DISP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FDI_PNG_DISP.M with the given input arguments.
%
%      FDI_PNG_DISP('Property','Value',...) creates a new FDI_PNG_DISP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FDI_PNG_disp_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FDI_PNG_disp_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FDI_PNG_disp

% Last Modified by GUIDE v2.5 26-Jan-2015 14:45:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FDI_PNG_disp_OpeningFcn, ...
                   'gui_OutputFcn',  @FDI_PNG_disp_OutputFcn, ...
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


% --- Executes just before FDI_PNG_disp is made visible.
function FDI_PNG_disp_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FDI_PNG_disp (see VARARGIN)

axes(handles.png_axes);set(gca,'ytick',[],'xtick',[],'xcolor',get(gcf,'color'),'ycolor',get(gcf,'color'));
handles.pngpathname=getappdata(0,'pngpathname');

handles.files = dir([handles.pngpathname '*.png']);
data_length = size(handles.files,1);
if data_length < 1
    helpdlg('No valid files found.  check extension and input directory are correct','Error');
    return;
end

min_d_l = 1;
max_d_l = data_length;
start_d_l = 1;

set(handles.slider1,'value',start_d_l); %
set(handles.slider1,'max',max_d_l); %
set(handles.slider1,'min',min_d_l);
set(handles.slider1,'SliderStep',[1/(max_d_l-min_d_l),20/(max_d_l-min_d_l)]);

input_file_number=round(get(handles.slider1,'Value')); % gets initial position of slider

handles.I=imread([handles.pngpathname, handles.files(input_file_number).name]);

dispname=(['File no: ' num2str(input_file_number) ' - ' handles.files(input_file_number).name]);
set(handles.filename_text,'String',dispname);

axes(handles.png_axes);
imshow(handles.I);

% Choose default command line output for FDI_PNG_disp
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes FDI_PNG_disp wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = FDI_PNG_disp_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
input_file_number=round(get(handles.slider1,'Value')); % gets initial position of slider

handles.I=imread([handles.pngpathname, handles.files(input_file_number).name]);
dispname=(['File no: ' num2str(input_file_number) ' - ' handles.files(input_file_number).name]);
set(handles.filename_text,'String',dispname);
axes(handles.png_axes);
imshow(handles.I);

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
