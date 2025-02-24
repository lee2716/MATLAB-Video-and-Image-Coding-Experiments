function varargout = JPEGGUI(varargin)
% JPEGGUI M-file for JPEGGUI.fig
%      JPEGGUI, by itself, creates a new JPEGGUI or raises the existing
%      singleton*.
%
%      H = JPEGGUI returns the handle to a new JPEGGUI or the handle to
%      the existing singleton*.
%
%      JPEGGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in JPEGGUI.M with the given input arguments.
%
%      JPEGGUI('Property','Value',...) creates a new JPEGGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before JPEGGUI_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to JPEGGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help JPEGGUI

% Last Modified by GUIDE v2.5 27-Sep-2012 21:02:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @JPEGGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @JPEGGUI_OutputFcn, ...
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


% --- Executes just before JPEGGUI is made visible.
function JPEGGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to JPEGGUI (see VARARGIN)

% Choose default command line output for JPEGGUI
handles.output = hObject;

%%%%Axis off for all axes ...
axes(handles.OriginalImageAxis); axis off;
axes(handles.DCTImageAxis); axis off;
axes(handles.QuantizedDCTImageAxis); axis off;

axes(handles.ReconstructedQuantizedDCTImageAxis); axis off;
axes(handles.ReconstructedDCTImageAxis); axis off;
axes(handles.ReconstructedImageAxis); axis off;

%%%% This is set to true when an image is loaded
%初始化变量
handles.ImageLoaded=false;
handles.ImageDCTed=false;
handles.ImageDCTQuantized = false;
handles.entropyEncoded = false;
handles.entropyDecoded = false;
handles.Dequantized = false;

% Update handles structure
guidata(hObject, handles);

draw_Toolbar(hObject,handles);

% UIWAIT makes JPEGGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = JPEGGUI_OutputFcn(hObject, eventdata, handles) 
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
% 载入原始图像
function OpenFile_Callback(hObject, eventdata, handles)
% hObject    handle to OpenFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile( ...
{'*.bmp;*.tiff;*.png','Image Files (*.bmp,*.tiff,*.png)'},...
   'Pick a file','../TestImages/');
if ~isequal(filename,0)
    
    % 读入图像文件
    im=imread(fullfile(pathname, filename));
   
    if (size(im,3)==3)
        im = rgb2gray(im);
    end
    
    %图像数据类型转换
    im=double(im);
    
    % 保存到GUI句柄handles,它是一个全局变量，使得其他函数可以访问
    handles.im = im;
    
    % 获得图像的分辨率
    [mf,nf]=size(im); 
    
    %计算8x8分块的个数
    mb=mf/8; 
    nb=nf/8;  
    
    % 保存在GUI句柄中
    handles.mf = mf;
    handles.nf = nf;
    handles.mb = mb;
    handles.nb = nb;    
    
    set(handles.QualitySlider,'enable','on');
    
    handles.ImageLoaded = true; % 原始图像载入标志为true
    
    % 保存handles到GUI数据区中
    guidata(hObject, handles);
    
    % 显示原始图像
    ShowOriginalImage(handles);
end
   
% --- Executes on button press in DCTBtn.
%  正向离散余弦变换
function DCTBtn_Callback(hObject, eventdata, handles)
% hObject    handle to DCTBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (handles.ImageLoaded ~= true) % 如果尚未载入原始图像，则返回
    return; 
end

% 是否选择系数偏置。原始图像灰度值范围[1,256]。如果选择系数偏置，灰度值范围变为[-127，128],有利于降低DCT系数的绝对值
level_shift=get(handles.LevelshiftCheckBox,'value');

if(level_shift==1)
    levelshiftedImage = handles.im - 128;
else
    levelshiftedImage = handles.im;
end

% 利用blkproc函数进行DCT变换
% 请完善下面函数，使之对levelshiftedImage进行8x8分块的DCT变换。blkproc的用法请在matlab命令窗口输入help blkproc
fun=@dct2;
dctImage = blkproc(levelshiftedImage,[8,8],fun);

% 完善blkproc函数后，激活DCTBtn_Callback回调函数剩余代码
 handles.imDCT = dctImage;
 
 handles.ImageDCTed = true; % DCT变换标志为true
 guidata(hObject, handles);
 
 ShowDCTImage(handles);
 %figure,imshow(dctImage,[]);
 set(handles.StatusText,'string','Status: DCT is completed!');

% --- Executes on button press in QuantizationBtn.
% 量化
function QuantizationBtn_Callback(hObject, eventdata, handles)
% hObject    handle to QuantizationBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (handles.ImageDCTed ~= true) % 如果尚未DCT变换，则返回
    return; 
end

% quality values should range from 1 (terrible) to 100 (very good)
% Default is 50, which represents the tables defined by the standard used without scaling
quality = get(handles.QualityEditBox,'value');
    
% convert to linear quality scale
if (quality <= 0) 
    quality = 1; 
end
    
if (quality > 100) 
    quality = 100; 
end

if (quality < 50)
    quality = 5000 / quality;
else
    quality = 200 - quality*2;
end
    
% Perceptual scaler quantization for lum
Q =[16 11 10 16  24  40  51  61
    12 12 14 19  26  58  60  55
    14 13 16 24  40  57  69  56
    14 17 22 29  51  87  80  62
    18 22 37 56  68 109 103  77
    24 35 55 64  81 104 113  92
    49 64 78 87 103 121 120 101
    72 92 95 98 112 100 103 99];

%根据质量因子quality，计算最终的量化矩阵    
Q = floor((Q * quality + 50)/100);
    
Q(Q<1)=1;
Q(Q>255)=255;

% 完善下面代码，使之利用量化矩阵Q，对DCT系数(保存在handles.imDCT)进行量化，量化后的图像用Quantized_DCTImage表示
% 可以利用blkproc函数进行量化，也可以自行写代码实现
Quantized_DCTImage = blkproc(handles.imDCT,[8,8],'round(x./P1)',Q);

% 完善量化功能后，激活QuantizationBtn_Callback回调函数剩余代码
handles.Q = Q;
handles.imQuantizedDCT = Quantized_DCTImage;
handles.ImageDCTQuantized = true; % 量化标志为true
% 
guidata(hObject, handles);
% 
ShowQuantizedDCTImage(handles);
set(handles.StatusText,'string','Status: Quantization is completed!');

% --- Executes on button press in EntropyCodingBtn.
% 熵编码
function EntropyCodingBtn_Callback(hObject, eventdata, handles)
% hObject    handle to EntropyCodingBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
if (handles.ImageDCTQuantized ~= true) % 如果尚未量化，则返回
    return;
end

% DPCM of DC component, scaned row-wise
mb = handles.mb;
nb = handles.nb;
mf = handles.mf;
nf = handles.nf;

fdc=reshape(handles.imQuantizedDCT(1:8:mf,1:8:nf)',mb*nb,1);
% 对DC系数进行差分脉冲编码调制(DPCM)编码，可以单步调试进去看看是如何实现
fdpcm=dpcm(fdc,1); 

set(handles.StatusText,'string','Status: Encoding DC Coefficents...');

dccof=[];

for i=1:mb*nb
    % DC系数熵编码
    dccof=[dccof jdcenc(fdpcm(i))];
end

% Zig-Zag scanning of AC coefficients
z= [1   2   6   7  15  16  28  29
    3   5   8  14  17  27  30  43
    4   9  13  18  26  31  42  44
    10  12  19  25  32  41  45  54
    11  20  24  33  40  46  53  55
    21  23  34  39  47  52  56  61
    22  35  38  48  51  57  60  62
    36  37  49  50  58  59  63  64];

set(handles.StatusText,'string','Status: Encoding AC Coefficents...');

acseq=[];

for i=1:mb
    for j=1:nb
        % tmp is 1 by 64
        tmp(z)=handles.imQuantizedDCT(8*(i-1)+1:8*i,8*(j-1)+1:8*j);
     
        eobi=max(find(tmp~=0)); %end of block index
        % eob is labelled with 999
        
        acseq=[acseq tmp(2:eobi) 999];
    end
end

% AC系数熵编码，可以单步调试进去看看是如何实现
accof=jacenc(acseq);

handles.dccof = dccof;
handles.accof = accof;

dccof_bits = length(dccof);
accof_bits = length(accof);

total_bits = dccof_bits + accof_bits;

compression_rate = total_bits /(mf * nf);
compession_ratio = 8/compression_rate;

% 请完善代码，将compression_rate，
% compession_ratio分别显示到GUI界面右边上方两个编辑框：BitRateEditBox和
%CompressionRatioEditBox

 set(handles.BitRateEditBox,'string',num2str(compression_rate));
 set(handles.CompressionRatioEditBox,'string',num2str(compession_ratio));

% 完善功能后，激活EntropyCodingBtn_Callback回调函数剩余代码
handles.entropyEncoded = true;
guidata(hObject, handles);
set(handles.StatusText,'string','Status: Entropy encoding completed!');
    
% --- Executes on button press in EntropyDecodingBtn.
% 熵解码
function EntropyDecodingBtn_Callback(hObject, eventdata, handles)
% hObject    handle to EntropyDecodingBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (handles.entropyEncoded ~= true) % 如果尚未熵编码，则返回
    return;
end

mb = handles.mb;
nb = handles.nb;
mf = handles.mf;
nf = handles.nf;

set(handles.StatusText,'string','Status: Decoding AC Coefficents...');

% 对AC系数进行熵解码，可以单步调试进去看看是如何实现
acarr=jacdec(handles.accof);

set(handles.StatusText,'string','Status: Decoding DC Coefficents...');

% 对DC系数进行熵解码，可以单步调试进去看看是如何实现
dcarr=jdcdec(handles.dccof);

Eob=find(acarr==999);

kk=1;
ind1=1;
n=1;

for ii=1:mb
    for jj=1:nb
        ac=acarr(ind1:Eob(n)-1);
        ind1=Eob(n)+1;
        n=n+1;
        
        imDecodedQuantizedDCT(8*(ii-1)+1:8*ii,8*(jj-1)+1:8*jj) = dezz([dcarr(kk) ac zeros(1,63-length(ac))]);
        
        kk=kk+1;
    end
end

handles.DecodedQuantizedDCTImage = imDecodedQuantizedDCT;

handles.entropyDecoded = true;
guidata(hObject, handles);

ShowDecodedQuantizedDCTImage(handles);

set(handles.StatusText,'string','Status: Entropy decoding completed!');
     
    
% --- Executes on button press in DeQuantizationBtn.
% 反量化
function DeQuantizationBtn_Callback(hObject, eventdata, handles)
% hObject    handle to DeQuantizationBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (handles.entropyDecoded ~= true) % 如果尚未熵解码，则返回
    return; 
end

% 参考量化回调函数，完善反量化
handles.DequantizedDCTImage = blkproc(handles.DecodedQuantizedDCTImage,[8 8],'round(x.*P1)',handles.Q);

%完善后，激活回调函数剩余代码
 handles.Dequantized = true;
%     
 guidata(hObject, handles);
% 
 ShowDequantizedDCTImage(handles);
 set(handles.StatusText,'string','Status: DeQuantization is completed!');


% --- Executes on button press in IDCTBtn.
% 反离散余弦变换
function IDCTBtn_Callback(hObject, eventdata, handles)
% hObject    handle to IDCTBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (handles.Dequantized ~= true) % 如果尚未反量化，则返回
    return; 
end

% 参考DCT回调函数，完善IDCT
handles.IDCTImage =blkproc(handles.DequantizedDCTImage,[8 8], 'idct2'); 

%完善后，激活下面代码
 level_shift=get(handles.LevelshiftCheckBox,'value');
% 
 if(level_shift==1)
     handles.reconstructedImage = round(handles.IDCTImage +128);
 else
     handles.reconstructedImage = handles.IDCTImage;
 end

% errorImage = (handles.im - handles.reconstructedImage);
   
% 计算MSE , PSNR，显示在GUI右边下边两个编辑框：MSEEditBox和PSNREditBox
error = handles.im - handles.reconstructedImage;
MSE = mean(error(:).^2);    
PSNR=10*log10(255^2/MSE);
% k = 8;
% fmax = 2.^k - 1;
% a = fmax.^2;
% error=im-handles.IDCTImage;
% MSE=mean(error(:).^2);
% MSE=(double(im2uint8(im)) -double( im2uint8(handles.IDCTImage))).^2;
% b = mean(MSE);
% PSNR = 10*log10(a/MSE);
set(handles.PSNREditBox,'string',num2str(PSNR));
set(handles.MSEEditBox,'string',num2str(MSE));
plot(MSE,PSNR);

%完善后，激活下面代码    
 guidata(hObject, handles);
% 
 ShowReconstructedImage(handles);
 set(handles.StatusText,'string','Status: IDCT is completed!');

function MSEEditBox_Callback(hObject, eventdata, handles)
% hObject    handle to MSEEditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MSEEditBox as text
%        str2double(get(hObject,'String')) returns contents of MSEEditBox as a double


% --- Executes during object creation, after setting all properties.
function MSEEditBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MSEEditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function QualitySlider_Callback(hObject, eventdata, handles)
% hObject    handle to QualitySlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
val = floor(get(handles.QualitySlider,'value'));
set(handles.QualityEditBox,'string',num2str(val));
set(handles.QualityEditBox,'value',val);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function QualitySlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to QualitySlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function QualityEditBox_Callback(hObject, eventdata, handles)
% hObject    handle to QualityEditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of QualityEditBox as text
%        str2double(get(hObject,'String')) returns contents of QualityEditBox as a double


% --- Executes during object creation, after setting all properties.
function QualityEditBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to QualityEditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function BitRateEditBox_Callback(hObject, eventdata, handles)
% hObject    handle to BitRateEditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of BitRateEditBox as text
%        str2double(get(hObject,'String')) returns contents of BitRateEditBox as a double


% --- Executes during object creation, after setting all properties.
function BitRateEditBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BitRateEditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function CompressionRatioEditBox_Callback(hObject, eventdata, handles)
% hObject    handle to CompressionRatioEditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CompressionRatioEditBox as text
%        str2double(get(hObject,'String')) returns contents of CompressionRatioEditBox as a double


% --- Executes during object creation, after setting all properties.
function CompressionRatioEditBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CompressionRatioEditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in LevelshiftCheckBox.
function LevelshiftCheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to LevelshiftCheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of LevelshiftCheckBox

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
%cd('../..');
delete(hObject);

% --------------------------------------------------------------------
function ExitFile_Callback(hObject, eventdata, handles)
% hObject    handle to ExitFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.figure1);

function PSNREditBox_Callback(hObject, eventdata, handles)
% hObject    handle to PSNREditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PSNREditBox as text
%        str2double(get(hObject,'String')) returns contents of PSNREditBox as a double


% --- Executes during object creation, after setting all properties.
function PSNREditBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PSNREditBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

