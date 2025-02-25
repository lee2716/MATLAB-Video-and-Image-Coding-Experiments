function varargout = MPEG(varargin)
% MPEG M-file for MPEG.fig
%      MPEG, by itself, creates a new MPEG or raises the existing
%      singleton*.
%
%      H = MPEG returns the handle to a new MPEG or the handle to
%      the existing singleton*.
%
%      MPEG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MPEG.M with the given input arguments.
%
%      MPEG('Property','Value',...) creates a new MPEG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MPEG_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MPEG_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MPEG

% Last Modified by GUIDE v2.5 14-May-2013 20:55:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MPEG_OpeningFcn, ...
                   'gui_OutputFcn',  @MPEG_OutputFcn, ...
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

% --- Executes just before MPEG is made visible.
function MPEG_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MPEG (see VARARGIN)

% Choose default command line output for MPEG
handles.output = hObject;

handles.VideoLoaded = false;

% Update handles structure
guidata(hObject, handles);

draw_Toolbar(hObject,handles);
% UIWAIT makes MPEG wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MPEG_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
% 载入原始视频序列
function OpenFile_Callback(hObject, eventdata, handles)
% hObject    handle to OpenFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile( ...
{'*.cif;*.qcif;','Video Files (*.cif, *.qcif)'},...
   'Pick a file','../TestVideos/');
if ~isequal(filename,0)
    
    [pathstr, name, ext] = fileparts(filename);
    fullname = fullfile(pathname, filename);
   
    if ((strcmp(ext,'.cif')) | (strcmp(ext,'.qcif')))
        
        OperationOnTheFly(true,handles);
    
        [im_seq_y] = read_yuv_luminanance_only(handles,fullname);  
        
        N = size(im_seq_y,3);
        
        handles.totalFrameRead = N;
        OperationOnTheFly(false,handles);
        
        handles.im_seq_y = im_seq_y;
        handles.VideoLoaded = true;
       
        guidata(hObject, handles);

        VideoLoaded(handles);
        ShowTargetFrames(handles);
    else
        set(handles.StatusText,'string','Status: unsupported vidoe file format!');
    end      
end

% --- Executes on button press in BlockMatchingBtn.
function BlockMatchingBtn_Callback(hObject, eventdata, handles)
% hObject    handle to BlockMatchingBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (handles.VideoLoaded)
    
    %获得参考帧
    AnchorFrameNum=floor(get(handles.FrameSlider,'value'));
    AnchorFrame = handles.im_seq_y(:,:,AnchorFrameNum); 

    %获得目标帧
    % 利用get(handles.,....)获取块匹配算法的参数
    % 获取参考帧的距离
    ref_distance =get(handles.RefDistancePopup,'value');
    
    TargetFrameNum = AnchorFrameNum + ref_distance;
    TargetFrame = handles.im_seq_y(:,:,TargetFrameNum); 
    
    %调用ShowBlockMatching进行运动估计
    ShowBlockMatching(AnchorFrame,TargetFrame,handles);
end


% --- Executes on slider movement.
function FrameSlider_Callback(hObject, eventdata, handles)
% hObject    handle to FrameSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
if (handles.IsBusy==false)
    ShowTargetFrames(handles);
end


% --- Executes during object creation, after setting all properties.
function FrameSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FrameSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function FrameEdit_Callback(hObject, eventdata, handles)
% hObject    handle to FrameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FrameEdit as text
%        str2double(get(hObject,'String')) returns contents of FrameEdit as a double


% --- Executes during object creation, after setting all properties.
function FrameEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FrameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in BlockSizePopup.
function BlockSizePopup_Callback(hObject, eventdata, handles)
% hObject    handle to BlockSizePopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns BlockSizePopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from BlockSizePopup


% --- Executes during object creation, after setting all properties.
function BlockSizePopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BlockSizePopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in SearchAlgorithmPopup.
function SearchAlgorithmPopup_Callback(hObject, eventdata, handles)
% hObject    handle to SearchAlgorithmPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SearchAlgorithmPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SearchAlgorithmPopup


% --- Executes during object creation, after setting all properties.
function SearchAlgorithmPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SearchAlgorithmPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in SearchRangePopup.
function SearchRangePopup_Callback(hObject, eventdata, handles)
% hObject    handle to SearchRangePopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns SearchRangePopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SearchRangePopup


% --- Executes during object creation, after setting all properties.
function SearchRangePopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SearchRangePopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in DoMotionEstimationCheck.
function DoMotionEstimationCheck_Callback(hObject, eventdata, handles)
% hObject    handle to DoMotionEstimationCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DoMotionEstimationCheck


function BlockMatchingMSEEdit_Callback(hObject, eventdata, handles)
% hObject    handle to BlockMatchingMSEEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BlockMatchingMSEEdit as text
%        str2double(get(hObject,'String')) returns contents of BlockMatchingMSEEdit as a double


% --- Executes during object creation, after setting all properties.
function BlockMatchingMSEEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BlockMatchingMSEEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function BlockMatchingPSNREdit_Callback(hObject, eventdata, handles)
% hObject    handle to BlockMatchingPSNREdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BlockMatchingPSNREdit as text
%        str2double(get(hObject,'String')) returns contents of BlockMatchingPSNREdit as a double


% --- Executes during object creation, after setting all properties.
function BlockMatchingPSNREdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BlockMatchingPSNREdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function NumOfMVsEdit_Callback(hObject, eventdata, handles)
% hObject    handle to NumOfMVsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NumOfMVsEdit as text
%        str2double(get(hObject,'String')) returns contents of NumOfMVsEdit as a double


% --- Executes during object creation, after setting all properties.
function NumOfMVsEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NumOfMVsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in MPEGPSearchAlgorithPopup.
function MPEGPSearchAlgorithPopup_Callback(hObject, eventdata, handles)
% hObject    handle to MPEGPSearchAlgorithPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns MPEGPSearchAlgorithPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MPEGPSearchAlgorithPopup

% --- Executes during object creation, after setting all properties.
function MPEGPSearchAlgorithPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MPEGPSearchAlgorithPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function NumOfFramesEdit_Callback(hObject, eventdata, handles)
% hObject    handle to NumOfFramesEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NumOfFramesEdit as text
%        str2double(get(hObject,'String')) returns contents of NumOfFramesEdit as a double


% --- Executes during object creation, after setting all properties.
function NumOfFramesEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NumOfFramesEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


% --------------------------------------------------------------------
function ExitFile_Callback(hObject, eventdata, handles)
% hObject    handle to ExitFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.figure1);

function TargetFrameEdit_Callback(hObject, eventdata, handles)
% hObject    handle to TargetFrameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TargetFrameEdit as text
%        str2double(get(hObject,'String')) returns contents of TargetFrameEdit as a double


% --- Executes during object creation, after setting all properties.
function TargetFrameEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TargetFrameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in RefDistancePopup.
function RefDistancePopup_Callback(hObject, eventdata, handles)
% hObject    handle to RefDistancePopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns RefDistancePopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from RefDistancePopup
if (handles.VideoLoaded)
    if (handles.IsBusy==false)
        VideoLoaded(handles);
        ShowTargetFrames(handles);
    end    
end

% --- Executes during object creation, after setting all properties.
function RefDistancePopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RefDistancePopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
