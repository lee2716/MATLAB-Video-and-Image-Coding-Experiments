function ShowBlockMatching(Reference_Frame,Target_Frame,handles)

OperationOnTheFly(true,handles);
set(handles.StatusText,'string','Status: Conducting Motion Estimation...');
        
%%%The size of frame:
Ny=size(Reference_Frame,1); 
Nx=size(Reference_Frame,2);

%%%Parameters for the block matching algorithm
% ����get(handles.,....)��ȡ��ƥ���㷨�Ĳ���

% 1.��ȡ��Ĵ�С��ͨ��handles.BlockSizePopup
val=get(handles.BlockSizePopup,'value');
if(val==1)
   bsize=16;
elseif(val==2)
   bsize=8;
end
% 2.��ȡ������Χ��ͨ��handles.SearchRangePopup
val=get(handles.SearchRangePopup,'value');
srange=val-1;

% 3.��ȡ�����㷨��ͨ��handles.SearchAlgorithmPopup
val=get(handles.SearchAlgorithmPopup,'value');

% �����ȫ������������motionEstES
if(val==1)
    [motionVect,EScomputations]=motionEstES(Reference_Frame,Target_Frame,bsize,srange);
    NUM=EScomputations;
elseif(val==2) 
    [motionVect,TSSComputations]=motionEstTSS(Reference_Frame,Target_Frame,bsize,srange);
    NUM=TSSComputations;
elseif(val==3)
    [motionVect,NTSSComputations]=motionEstNTSS(Reference_Frame,Target_Frame,bsize,srange);
    NUM=NTSSComputations;
elseif(val==4) 
    [motionVect,DSComputations]=motionEstDS(Reference_Frame,Target_Frame,bsize,srange);
    NUM=DSComputations;    
elseif(val==5) % ������Ĳ�������������motionEst4SS
    [motionVect,SS4Computations]=motionEst4SS(Reference_Frame,Target_Frame,bsize,srange);
    NUM=SS4Computations;
end

% Show motion vector
% ��ʾ�˶�����ͼ
axes(handles.MVAxes);

bdy=ceil(Ny/bsize); 
bdx=ceil(Nx/bsize);

motionVect_y = reshape(motionVect(1,:), [bdx,bdy]);
motionVect_x = reshape(motionVect(2,:), [bdx,bdy]);

motionVect_y = motionVect_y';
motionVect_x = motionVect_x';

[X,Y]=meshgrid(linspace(bsize/2,Nx,size(motionVect_x,2)),linspace(bsize/2,Ny,size(motionVect_y,1)) );
h=quiver(X,Y,5*motionVect_x(end:-1:1,:),-5*motionVect_y(end:-1:1,:)); 

set(h,'color','k');
axis([0 Nx 0 Ny]);
axis off;
axis equal;

% ��ʾԤ��ͼ��Predicte_Frame

axes(handles.PredictedFrameAxes);
% ����motionComp���������˶����������Ԥ��ͼ��Predicte_Frame
% �벹��
Predicte_Frame= motionComp(Reference_Frame,motionVect,bsize);

% ����imshow��ʾ֮
imshow(uint8(Predicte_Frame));

% Show the Prediction Error image
% ��ʾ�в�ͼ��
axes(handles.ErrorAxes);

% ����в�ͼ��errorImage
 errorImage=abs(Target_Frame-Predicte_Frame);

% ����imshow��ʾ֮
imshow(uint8(errorImage));

%%%%Show various results .^2  /(Nx*Ny)
% ����errorImage������MSE��PSNR������ʾ��GUI�����еı༭��BlockMatchingMSEEdit��BlockMatchingPSNREdit
MSE=sum(sum((Target_Frame-Predicte_Frame).^2)) /(Nx*Ny);
PSNR=10*log10((255.^2)./MSE);
set(handles.BlockMatchingMSEEdit,'string',num2str(MSE));
set(handles.BlockMatchingPSNREdit,'string',num2str(PSNR));

set(handles.StatusText,'string','Status: Motion Estimation Completed!');
OperationOnTheFly(false,handles);
