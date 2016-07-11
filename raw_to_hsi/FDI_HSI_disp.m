function varargout = FDI_HSI_disp(varargin)
% FDI_HSI_DISP MATLAB code for FDI_HSI_disp.fig
%      FDI_HSI_DISP, by itself, creates a new FDI_HSI_DISP or raises the existing
%      singleton*.
%
%      H = FDI_HSI_DISP returns the handle to a new FDI_HSI_DISP or the handle to
%      the existing singleton*.
%
%      FDI_HSI_DISP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FDI_HSI_DISP.M with the given input arguments.
%
%      FDI_HSI_DISP('Property','Value',...) creates a new FDI_HSI_DISP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FDI_HSI_disp_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FDI_HSI_disp_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FDI_HSI_disp

% Last Modified by GUIDE v2.5 28-Jan-2015 14:42:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FDI_HSI_disp_OpeningFcn, ...
                   'gui_OutputFcn',  @FDI_HSI_disp_OutputFcn, ...
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


% --- Executes just before FDI_HSI_disp is made visible.
function FDI_HSI_disp_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FDI_HSI_disp (see VARARGIN)

axes(handles.HSI_axes);set(gca,'ytick',[],'xtick',[],'xcolor',get(gcf,'color'),'ycolor',get(gcf,'color'));
handles.rawpathname=getappdata(0,'rawpathname');
handles.HSImage_name=getappdata(0,'HSImage_name');

[handles.HSImage,info] = GenericHSILoad(handles.HSImage_name);
%handles.WLs=str2num(info.Wavelength(3:end-1));
handles.WLs=info.Wavelength;

data_length = size(handles.HSImage,3);
if data_length < 1
    helpdlg('No valid files found.  check extension and input directory are correct','Error');
    return;
end

min_d_l = 1;
max_d_l = data_length;
start_d_l = 1;

set(handles.wls_slider,'value',start_d_l); %
set(handles.wls_slider,'max',max_d_l); %
set(handles.wls_slider,'min',min_d_l);
set(handles.wls_slider,'SliderStep',[1/(max_d_l-min_d_l),20/(max_d_l-min_d_l)]);

current_position=round(get(handles.wls_slider,'Value')); % gets initial position of slider

handles.I=handles.HSImage(:,:,current_position);

dispname=(['Current wavelenght: ' num2str(handles.WLs(current_position)) ' nm.']);
set(handles.wavelegth_text,'String',dispname);

axes(handles.HSI_axes);
imshow(handles.I,[0 65535]);

% Choose default command line output for FDI_HSI_disp
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes FDI_HSI_disp wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = FDI_HSI_disp_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function wls_slider_Callback(hObject, eventdata, handles)
% hObject    handle to wls_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
current_position=round(get(handles.wls_slider,'Value')); % gets current position of slider

handles.I=handles.HSImage(:,:,current_position);

dispname=(['Current wavelenght: ' num2str(handles.WLs(current_position)) ' nm.']);
set(handles.wavelegth_text,'String',dispname);

axes(handles.HSI_axes);
imshow(handles.I,[0 65535]);

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function wls_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to wls_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
