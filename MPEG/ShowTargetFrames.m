function ShowTargetFrames(handles)

OperationOnTheFly(true,handles);

AnchorFrameNum=floor(get(handles.FrameSlider,'value'));
set(handles.FrameEdit,'string',num2str(AnchorFrameNum));

%%%Show the anchor frame
axes(handles.OriginalImageAxis);

im1 = handles.im_seq_y(:,:,AnchorFrameNum);  

im1 = uint8(im1);
imshow(im1);

ref_distance = get(handles.RefDistancePopup,'value');
TargetFrameNum = AnchorFrameNum +ref_distance;
set(handles.TargetFrameEdit,'string',num2str(TargetFrameNum));

%%%Show the target frame
axes(handles.NextFrameAxes);

im2 = handles.im_seq_y(:,:,TargetFrameNum); 

im2 = uint8(im2);
imshow(im2);

OperationOnTheFly(false,handles);  
    