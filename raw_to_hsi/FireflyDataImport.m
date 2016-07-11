function varargout = FireflyDataImport(varargin)
% FIREFLYDATAIMPORT MATLAB code for FireflyDataImport.fig
%      FIREFLYDATAIMPORT, by itself, creates a new FIREFLYDATAIMPORT or raises the existing
%      singleton*.
%
%      H = FIREFLYDATAIMPORT returns the handle to a new FIREFLYDATAIMPORT or the handle to
%      the existing singleton*.
%
%      FIREFLYDATAIMPORT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FIREFLYDATAIMPORT.M with the given input arguments.
%
%      FIREFLYDATAIMPORT('Property','Value',...) creates a new FIREFLYDATAIMPORT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FireflyDataImport_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FireflyDataImport_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FireflyDataImport

% Last Modified by GUIDE v2.5 17-Feb-2015 14:24:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FireflyDataImport_OpeningFcn, ...
                   'gui_OutputFcn',  @FireflyDataImport_OutputFcn, ...
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


% --- Executes just before FireflyDataImport is made visible.
function FireflyDataImport_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FireflyDataImport (see VARARGIN)

% Choose default command line output for FireflyDataImport
handles.output = hObject;

handles.res=512;
handles.new_height=handles.res;
handles.crop_start_top=196;
handles.crop_start_bottom=316;

set(handles.aver_checkbox,'Value',0);
handles.averaging = get(handles.register_checkbox,'Value');

set(handles.register_checkbox,'Value',1);
handles.registration = get(handles.register_checkbox,'Value');

set(handles.dataselect_popupmenu,'Enable','off');
set(handles.dispHC_button,'Enable','off');
handles.dataselect_list = get(handles.dataselect_popupmenu,'String');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes FireflyDataImport wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = FireflyDataImport_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function raw_path_edit_Callback(hObject, eventdata, handles)
% hObject    handle to raw_path_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of raw_path_edit as text
%        str2double(get(hObject,'String')) returns contents of raw_path_edit as a double


% --- Executes during object creation, after setting all properties.
function raw_path_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to raw_path_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in choose_path_button.
function choose_path_button_Callback(hObject, eventdata, handles)
% hObject    handle to choose_path_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cla(handles.crop_axes,'reset')
set(handles.croptop_text,'String','...');
set(handles.cropbottom_text,'String','...');
set(handles.newresval_text,'String','...');

[~, handles.rawpathname, handles.raw_ext_index] = uigetfile({'*.raw';'*.txt'}, 'Select the folder with RAW data files');
cd(handles.rawpathname);
set(handles.raw_path_edit, 'String', handles.rawpathname);
handles.pngpathname = strcat(handles.rawpathname, 'PNGs\');
set(handles.png_path_edit, 'String', handles.pngpathname);

folder_check = exist(handles.pngpathname,'dir');
if folder_check == 7
    handles.png_files = dir([handles.pngpathname '*.png']);
    set(handles.dataselect_popupmenu,'Enable','on');
end

guidata(hObject,handles)

% --- Executes on button press in raw_to_png_button.
function raw_to_png_button_Callback(hObject, eventdata, handles)
% hObject    handle to raw_to_png_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.status_text,'String','Wait...');
set(handles.HC_status_text,'String','...');

folder_check = exist(handles.pngpathname,'dir');
if folder_check == 0
    mkdir ('PNGs');
    cd PNGs;
else cd PNGs;
end

%%
% procedure for raw data decoding from M Squared (adapted for this gui)

% Parameters to control the processing, 1 yes do it, 0 don't
% Note: don't have these on if processing a large number of files.  Too many figures will open and take up all the PC's memory!
% Plot_Input = 0;         % Plot the raw data
% Plot_Corrected = 1;     % Plot the geometric corrected data
PNG_Save = 1;           % Save to PNG file
PNG_Display_Info = 0;   % Show the header info for the file created
%PNG_Show = 1;           % Load the PNG file back and show it, for testing.

% Set the resolution of the images that are in this directory.  Any raw files that don't have this resolution will be discarded.
% Note this is raw capture size so a jpeg resolution 256x256 will had a raw resolution of 512x256 and that's what's needed here.
% If the input directory has a mix of raw resolutions it will need to be processed multiple times with different settings here.
Raw_Number_Pixels_Per_Line = 512;
Raw_Number_Lines = handles.res;

% Set the path to the raw files and the desired output directoy.  Also the file extension either .txt or .raw 
Raw_Directory = handles.rawpathname;
PNG_Directory = handles.pngpathname;

switch handles.raw_ext_index
    case 1
        Raw_Extension='.raw';
    case 2
        Raw_Extension='.txt';
    otherwise
end

%% Now do the processing, no more user config from here.
% Identify the raw files.
files = dir([Raw_Directory '\*' Raw_Extension]);
number_files = size(files,1);
if number_files < 1
    helpdlg('No valid files found.  check extension and input directory are correct','Error');
    return;
end
% number_files = 1; disp('Testing so only processing one file.  remove this line to do all');

% Process each file, one at a time.
for input_file_number=1:number_files
    status_text=['Processing ' num2str(input_file_number) ' out of  ' num2str(number_files) ' files' ];
    set(handles.status_text,'String',status_text);
    pause(0.05)
    % Now read the file.
    data_file = fopen([Raw_Directory, '\', files(input_file_number).name], 'r', 'l');
    if data_file == -1
        helpdlg('Data file couldn''t be opened - check path','Error');
        break;
    else
        disp(['Processing file "' files(input_file_number).name, '"']);
    end
    
    temp = fread(data_file, 'uint16');
    fclose(data_file);
    input_number_pixels_got = size(temp,1);
    if input_number_pixels_got ~= (Raw_Number_Lines * Raw_Number_Pixels_Per_Line)
        disp(['Error: file "', files(input_file_number).name, '" doesn''t have the configured size.']);
        disp(['Number pixels got = ', num2str(input_number_pixels_got), ' Raw_Number_Pixels_Per_Line = ', num2str(Raw_Number_Pixels_Per_Line), ' Raw_Number_Lines = ', num2str(Raw_Number_Lines), ' Total expected = ', num2str(Raw_Number_Pixels_Per_Line * Raw_Number_Lines), '. File skipped.']);
        continue;
    else
        if temp(1) == 0
            frame_id = 0;
        elseif temp(1) == 65535
            frame_id = 1;
        else
            frame_id = 2;
            disp('Frame ID not detected.  File skipped');
            continue;
        end
        disp(['Got correct resolution settings.  Frame ID = ', num2str(frame_id)]);
    end
    clear temp
    
    data_file = fopen([Raw_Directory, '\', files(input_file_number).name], 'r', 'l');
    buffer_raw = fread(data_file, [Raw_Number_Pixels_Per_Line,Raw_Number_Lines], 'uint16');
    fclose(data_file);
    
    % Perform basic geometric correction.  This averages the pixels when reducing the resolution.
    buffer = zeros(size(buffer_raw,2), size(buffer_raw,2));
    for n=1:Raw_Number_Lines
        if mod(n,2) == 1
            line = flipud(buffer_raw(:,n));
        else
            line = buffer_raw(:,n);
        end
        
        count = 1;
        if Raw_Number_Pixels_Per_Line == 512
            if Raw_Number_Lines == 512
                buffer(:,n) = line;
            elseif Raw_Number_Lines == 256
                for nn=1:2:Raw_Number_Pixels_Per_Line
                    if n == 1 && nn == 1  % Don't process the first pixel, keep frame id
                        continue;
                    end
                    buffer(count,n) = (line(nn) + line(nn+1)) / 2;
                    count = count+1;
                end
            elseif Raw_Number_Lines == 128
                for nn=1:4:Raw_Number_Pixels_Per_Line
                    if n == 1 && nn == 1  % Don't process the first pixel, keep frame id
                        continue;
                    end
                    buffer(count,n) = (line(nn) + line(nn+1) + line(nn+2) + line(nn+3)) / 4;
                    count = count+1;
                end
            elseif Raw_Number_Lines == 64
                for nn=1:8:Raw_Number_Pixels_Per_Line
                    if n == 1 && nn == 1  % Don't process the first pixel, keep frame id
                        continue;
                    end
                    buffer(count,n) = (line(nn) + line(nn+1) + line(nn+2) + line(nn+3) + line(nn+4) + line(nn+5) + line(nn+6) + line(nn+7)) / 8;
                    count = count+1;
                end
            end
        elseif Raw_Number_Pixels_Per_Line == 64
            buffer(:,n) = line;
        end
    end
    
    % Handle frame IDs and image flip.
    if frame_id == 0
        for n=1:Raw_Number_Lines
            buffer(n,:) = fliplr(buffer(n,:));
        end
    end
    
    %% Save the data as a PNG file
    if PNG_Save == 1
        length = strfind(files(input_file_number).name, '.');
        length = length(end);
        new_filename = [files(input_file_number).name(1:length-1) ' .png'];
        % The call to imwrite can be extended to add additional information into the file's header.
        % See this tutorial for details: http://dali.feld.cvut.cz/ucebna/matlab/toolbox/images/imwrite.html
        imwrite(uint16(buffer), [PNG_Directory, '\', new_filename], 'Author', 'M Squared Lasers Ltd', 'Comment', ['Created in Matlab from file ', files(input_file_number).name]);
        % To view the header information uncomment the following line
        if PNG_Display_Info == 1
            imfinfo([PNG_Directory, '\', new_filename])
        end
    end
end
set(handles.status_text,'String','All done');
disp('All done');
cd ..

handles.png_files = dir([handles.pngpathname '*.png']);
set(handles.dataselect_popupmenu,'Enable','on');
handles.HSImage_name=['HSImage_' handles.dataselect_list{get(handles.dataselect_popupmenu,'Value')} handles.png_files(1).name(15:23) ];
set(handles.HCfile_edit,'String',handles.HSImage_name);
guidata(hObject,handles)


function png_path_edit_Callback(hObject, eventdata, handles)
% hObject    handle to png_path_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of png_path_edit as text
%        str2double(get(hObject,'String')) returns contents of png_path_edit as a double


% --- Executes during object creation, after setting all properties.
function png_path_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to png_path_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in resolution_popupmenu.
function resolution_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to resolution_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns resolution_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from resolution_popupmenu
res_contents = get(hObject,'Value');

switch res_contents
    case 1
        handles.res=512;
        handles.crop_start_top=196;
        handles.crop_start_bottom=316;
    case 2
        handles.res=256;
        handles.crop_start_top=98;
        handles.crop_start_bottom=158;
    case 3
        handles.res=64;
        handles.crop_start_top=24;
        handles.crop_start_bottom=40;
    otherwise
end
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function resolution_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to resolution_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pngdisp_button.
function pngdisp_button_Callback(hObject, eventdata, handles)
% hObject    handle to pngdisp_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setappdata(0,'pngpathname',handles.pngpathname);
FDI_PNG_disp


% --- Executes on button press in loadexample_button.
function loadexample_button_Callback(hObject, eventdata, handles)
% hObject    handle to loadexample_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

min_pos_top = 0;
max_pos_top = handles.res/2;
start_pos_top = handles.crop_start_top;

set(handles.croptop_slider,'value',start_pos_top); 
set(handles.croptop_slider,'max',max_pos_top); 
set(handles.croptop_slider,'min',min_pos_top);
set(handles.croptop_slider,'SliderStep',[1/(max_pos_top-min_pos_top),5/(max_pos_top-min_pos_top)]);

min_pos_bottom = handles.res/2;
max_pos_bottom = handles.res;
start_pos_bottom = handles.crop_start_bottom;

set(handles.cropbottom_slider,'value',start_pos_bottom); 
set(handles.cropbottom_slider,'max',max_pos_bottom); 
set(handles.cropbottom_slider,'min',min_pos_bottom);
set(handles.cropbottom_slider,'SliderStep',[1/(max_pos_bottom-min_pos_bottom),5/(max_pos_bottom-min_pos_bottom)]);

curr_pos_top=round(get(handles.croptop_slider,'Value')); % gets updated position of top slider
curr_pos_bottom=round(get(handles.cropbottom_slider,'Value')); % gets updated position of bottom slider

handles.val_top = (min_pos_top + max_pos_top) - curr_pos_top;
handles.val_bottom = (min_pos_bottom + max_pos_bottom) - curr_pos_bottom;

handles.x=[1,handles.res];
handles.y_top=[handles.val_top,handles.val_top];
handles.y_bottom=[handles.val_bottom,handles.val_bottom];

set(handles.croptop_text,'String',num2str(handles.val_top));
set(handles.cropbottom_text,'String',num2str(handles.res-handles.val_bottom));
handles.new_height=handles.val_bottom-handles.val_top;
set(handles.newresval_text,'String',[num2str(handles.new_height) ' x ' num2str(handles.res)]);

handles.example_image=imread([handles.pngpathname, handles.png_files(1).name]);
axes(handles.crop_axes);
image(cat(3,handles.example_image,handles.example_image,handles.example_image)); 
hold on;
plot(handles.x,handles.y_top,'r-')
hold on
plot(handles.x,handles.y_bottom,'b-')

guidata(hObject,handles)


% --- Executes on slider movement.
function croptop_slider_Callback(hObject, eventdata, handles)
% hObject    handle to croptop_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
curr_pos_top=round(get(handles.croptop_slider,'Value')); % gets updated position of top slider
min_pos_top = 0;
max_pos_top = handles.res/2;
handles.val_top = (min_pos_top + max_pos_top) - curr_pos_top;
handles.y_top=[handles.val_top,handles.val_top];

set(handles.croptop_text,'String',num2str(handles.val_top));
handles.new_height=handles.val_bottom-handles.val_top;
set(handles.newresval_text,'String',[num2str(handles.new_height) ' x ' num2str(handles.res)]);

axes(handles.crop_axes);
image(cat(3,handles.example_image,handles.example_image,handles.example_image)); 
hold on;
plot(handles.x,handles.y_top,'r-')
hold on
plot(handles.x,handles.y_bottom,'b-')

guidata(hObject,handles)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function croptop_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to croptop_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function cropbottom_slider_Callback(hObject, eventdata, handles)
% hObject    handle to cropbottom_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

curr_pos_bottom=round(get(handles.cropbottom_slider,'Value')); % gets updated position of top slider
min_pos_bottom = handles.res/2;
max_pos_bottom = handles.res;
handles.val_bottom = (min_pos_bottom + max_pos_bottom) - curr_pos_bottom;

handles.y_bottom=[handles.val_bottom,handles.val_bottom];

set(handles.cropbottom_text,'String',num2str(handles.res-handles.val_bottom));
handles.new_height=handles.val_bottom-handles.val_top;
set(handles.newresval_text,'String',[num2str(handles.new_height) ' x ' num2str(handles.res)]);

axes(handles.crop_axes);
image(cat(3,handles.example_image,handles.example_image,handles.example_image)); 
hold on;
plot(handles.x,handles.y_top,'r-')
hold on
plot(handles.x,handles.y_bottom,'b-')

guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function cropbottom_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cropbottom_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in sizeinfo_but.
function sizeinfo_but_Callback(hObject, eventdata, handles)
% hObject    handle to sizeinfo_but (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
helpdlg('Suggested amount of pixel to be cropped (top and bottom the same): 512x512 - 60 pixel; 256x256 - 30 pixel; 64x64 - 8 pixel.','Crop info');


% --- Executes on selection change in dataselect_popupmenu.
function dataselect_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to dataselect_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns dataselect_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from dataselect_popupmenu
HCdata_type = get(hObject,'Value');

switch HCdata_type
    case 1
        %handles.HC_include_files=GetFileNames('*.png','Idler');
        handles.HSImage_name=['HSImage_' handles.dataselect_list{HCdata_type}(1:6) handles.png_files(1).name(15:23) ];
        set(handles.HCfile_edit,'String',handles.HSImage_name);
        handles.WLsstart=10;
        handles.WLsend=15;
    case 2
        %handles.HC_include_files=GetFileNames('*.png','Signal');
        handles.HSImage_name=['HSImage_' handles.dataselect_list{HCdata_type}(1:5) handles.png_files(1).name(15:23) ];
        set(handles.HCfile_edit,'String',handles.HSImage_name);
        handles.WLsstart=9;
        handles.WLsend=14;
    otherwise
end
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function dataselect_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dataselect_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in CreateHyperCube_button.
function CreateHyperCube_button_Callback(hObject, eventdata, handles)
% hObject    handle to CreateHyperCube_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cd PNGs

HCdata_type=get(handles.dataselect_popupmenu,'Value');

if HCdata_type==1
    handles.HC_include_files=GetFileNames('*.png','Idler');
elseif HCdata_type==2
    handles.HC_include_files=GetFileNames('*.png','Signal');
end

tempcube = zeros(handles.new_height,handles.res,size(handles.HC_include_files,1));
RegisteredCube = tempcube;
WLs_temp = zeros(size(handles.HC_include_files,1),1);

tempcube(:,:,1) = imcrop(imread(handles.HC_include_files{1}),[1 handles.val_top+1 handles.res handles.new_height-1]);
WLs_temp(1) = str2double(handles.HC_include_files{1}(handles.WLsstart:handles.WLsend));

for i=1:size(handles.HC_include_files,1)-1
    
    status_text=['Processing ' num2str(i+1) ' out of  ' num2str(size(handles.HC_include_files,1)) ' files' ];
    set(handles.HC_status_text,'String',status_text);
    pause(0.05);
    
    tempIM = imcrop(imread(handles.HC_include_files{i+1}),[1 handles.val_top handles.res handles.new_height-1]);

    tempcube(:,:,i+1) = tempIM;
    WLs_temp(i+1) = str2double(handles.HC_include_files{i+1}(handles.WLsstart:handles.WLsend));
    
end

    if handles.registration==1;
       tempcube = tempcube/65535;
       RegisteredCube(:,:,1) = tempcube(:,:,1);
            for i=2:size(tempcube,3)
                
             status_text=['Registering ' num2str(i) ' out of  ' num2str(size(tempcube,3)) ' files' ];
             set(handles.HC_status_text,'String',status_text);
             pause(0.05);

                  IM_fixed = RegisteredCube(:,:,i-1);
                  IM_move = tempcube(:,:,i);
                  IM_moved = TimSURFMatch(IM_fixed,IM_move);
                  RegisteredCube(:,:,i) = IM_moved;
                  fprintf('%d of %d\n',i,size(tempcube,3))
            end
        RegisteredCube=RegisteredCube*65535;
    else 
        RegisteredCube=tempcube;
    end

    uniqueWLs=unique(WLs_temp);
    post_aver_length=length(uniqueWLs);
    WLs = zeros(size(post_aver_length,1));
    cube = zeros(handles.new_height,handles.res,post_aver_length);

if handles.averaging==1
    for j=1:post_aver_length;
        
        status_text=['Averaging ' num2str(j) ' out of  ' num2str(size(RegisteredCube,3)/8) ' files' ];
        set(handles.HC_status_text,'String',status_text);
        pause(0.05);
        
        index=find(WLs_temp==uniqueWLs(j));
        
        cube(:,:,j)=median(RegisteredCube(:,:,index(1):index(end)),3);
        WLs(j)=uniqueWLs(j);
    end
else
    cube = RegisteredCube;
    WLs=WLs_temp;
end
        

cd ..
handles.final_file_name=get(handles.HCfile_edit,'String');

if HCdata_type==1
    handles.signalcube=handles.final_file_name;
elseif HCdata_type==2
    handles.idlercube=handles.final_file_name;
end

set(handles.HC_status_text,'String','Writing, please wait');
pause(0.05);
         
HSIWrite(cube,handles.final_file_name,WLs);

set(handles.HC_status_text,'String','All Done!');
set(handles.dispHC_button,'Enable','on');

guidata(hObject,handles)


% --- Executes on button press in register_checkbox.
function register_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to register_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of register_checkbox
handles.registration = get(handles.register_checkbox,'Value');

guidata(hObject,handles)

% --- Executes on button press in reg_help_button.
function reg_help_button_Callback(hObject, eventdata, handles)
% hObject    handle to reg_help_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
helpdlg('This checkbox implement correction of the "spatial movement" by image registration. No other correction for the shift is applied.','Registration info');



function HCfile_edit_Callback(hObject, eventdata, handles)
% hObject    handle to HCfile_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of HCfile_edit as text
%        str2double(get(hObject,'String')) returns contents of HCfile_edit as a double


% --- Executes during object creation, after setting all properties.
function HCfile_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HCfile_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in dispHC_button.
function dispHC_button_Callback(hObject, eventdata, handles)
% hObject    handle to dispHC_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setappdata(0,'rawpathname',handles.rawpathname);
setappdata(0,'HSImage_name',handles.final_file_name);
FDI_HSI_disp


% --- Executes on button press in aver_checkbox.
function aver_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to aver_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of aver_checkbox
handles.averaging = get(handles.aver_checkbox,'Value');

guidata(hObject,handles)


% --- Executes on button press in cat_button.
function cat_button_Callback(hObject, eventdata, handles)
% hObject    handle to cat_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.HC_status_text,'String','Please wait');
pause(0.05);

[Isig,IsigInfo] = HSILoad(handles.signalcube);
[Iidl,IidlInfo] = HSILoad(handles.idlercube);

Ifull=cat(3,Isig,Iidl);
If16=uint16(Ifull);

WLsfull=cat(2,IsigInfo.Wavelength,IidlInfo.Wavelength);

FullHSImage_name=['HSImage' handles.png_files(1).name(15:23) '_Full'];

HSIWrite(If16,FullHSImage_name,WLsfull);

set(handles.HC_status_text,'String','Done!');
pause(0.05);
      
guidata(hObject,handles)
