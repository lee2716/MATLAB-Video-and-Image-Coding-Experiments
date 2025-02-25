function ShowBlockMatching(Reference_Frame,Target_Frame,handles)

OperationOnTheFly(true,handles);
set(handles.StatusText,'string','Status: Conducting Motion Estimation...');
        
%%%The size of frame:
Ny=size(Reference_Frame,1); 
Nx=size(Reference_Frame,2);

%%%Parameters for the block matching algorithm
% 利用get(handles.,....)获取块匹配算法的参数

% 1.获取块的大小，通过handles.BlockSizePopup
val=get(handles.BlockSizePopup,'value');
if(val==1)
   bsize=16;
elseif(val==2)
   bsize=8;
end
% 2.获取搜索范围，通过handles.SearchRangePopup
val=get(handles.SearchRangePopup,'value');
srange=val-1;

% 3.获取搜索算法，通过handles.SearchAlgorithmPopup
val=get(handles.SearchAlgorithmPopup,'value');

% 如果是全搜索法，采用motionEstES
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
elseif(val==5) % 如果是四步搜索法，采用motionEst4SS
    [motionVect,SS4Computations]=motionEst4SS(Reference_Frame,Target_Frame,bsize,srange);
    NUM=SS4Computations;
end

% Show motion vector
% 显示运动向量图
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

% 显示预测图像Predicte_Frame

axes(handles.PredictedFrameAxes);
% 利用motionComp函数进行运动补偿，获得预测图像Predicte_Frame
% 请补充
Predicte_Frame= motionComp(Reference_Frame,motionVect,bsize);

% 利用imshow显示之
imshow(uint8(Predicte_Frame));

% Show the Prediction Error image
% 显示残差图像
axes(handles.ErrorAxes);

% 计算残差图像errorImage
 errorImage=abs(Target_Frame-Predicte_Frame);

% 利用imshow显示之
imshow(uint8(errorImage));

%%%%Show various results .^2  /(Nx*Ny)
% 利用errorImage，计算MSE和PSNR，并显示到GUI界面中的编辑框BlockMatchingMSEEdit和BlockMatchingPSNREdit
MSE=sum(sum((Target_Frame-Predicte_Frame).^2)) /(Nx*Ny);
PSNR=10*log10((255.^2)./MSE);
set(handles.BlockMatchingMSEEdit,'string',num2str(MSE));
set(handles.BlockMatchingPSNREdit,'string',num2str(PSNR));

set(handles.StatusText,'string','Status: Motion Estimation Completed!');
OperationOnTheFly(false,handles);
