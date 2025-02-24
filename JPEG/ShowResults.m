function [] = ShowResults(handles)

set(handles.StatusText,'string','Status: Please wait ...');

im=handles.im;
QualityFactor = floor(get(handles.QualitySlider,'value'));

warning off;
imwrite(im,'JPEGImage.jpg','jpeg','Bitdepth',8,'Quality',QualityFactor);
warning on;
info = imfinfo('JPEGImage.jpg','jpeg');

%%%% Show compressed image
imJPEG = imread('JPEGImage.jpg');
imJPEG=double(imJPEG)/255;
axes(handles.CompressedImageAxis);
imshow(imJPEG); 

%%%% Show error image
ErrorImage = abs(im-imJPEG);
axes(handles.SquaredDifferenceAxis);
imshow(ErrorImage,[0 1]);

%%%% Show the various compression paramaters
ratio = numel(imJPEG)/(info.FileSize);
set(handles.CompressionRatioEditBox,'string',['1 : ',num2str(ratio)]);

BitRate=8/ratio;
set(handles.BitRateEditBox,'string',num2str(BitRate));

MSE = mean(mean(ErrorImage.^2)); PSNR = -10*log10(MSE);
set(handles.PSNREditBox,'string',num2str(PSNR));

%%%% Calculate and show the Block 8x8 DCT Coefficient
showDC=get(handles.ShowDCCheckBox,'value');
showAbsCoeffVals=get(handles.ShowABSCheckBox,'value');

BlockSize = [8 8];

v=(version('-date')); 
warning off;
if (str2num(v(end-4:end))<2010)
    B = blkproc(im,BlockSize,@dct2);
    BJpeg = blkproc(imJPEG,BlockSize,@dct2);
else
    fun = @(block_struct) dct2(block_struct.data);
    B = blockproc(im,BlockSize,fun);
    BJpeg = blockproc(imJPEG,BlockSize,fun);
end
warning on;

if (showDC==0)
    mask=ones(BlockSize);
    mask(1,1)=0; 
        
    warning off;
    if (str2num(v(end-4:end))<2010)
        B = blkproc(B,BlockSize,'P1.*x',mask);
        BJpeg = blkproc(BJpeg,BlockSize,'P1.*x',mask);
    else
        fun = @(block_struct) block_struct.data.*mask; 
        B = blockproc(B,BlockSize,fun);
        BJpeg = blockproc(BJpeg,BlockSize,fun);
    end
    warning on;
end

if (showAbsCoeffVals)
    B=abs(B);
    BJpeg=abs(BJpeg);
end
    
axes(handles.OriginalDCTCoeffsAxis);
imshow(mat2gray(B)); 
axis on; 

axes(handles.DCTCoeffsAxis);
imshow(mat2gray(BJpeg));  axis on;

%%%Refresh status
set(handles.StatusText,'string','Status: Ready !');
