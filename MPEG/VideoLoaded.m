function [] = VideoLoaded(handles)

%%%Change the Frame Slider Settings
N= handles.totalFrameRead ;

set(handles.FrameSlider,'visible','on');
set(handles.FrameSlider,'min',1);

ref_distance = get(handles.RefDistancePopup,'value');
set(handles.FrameSlider,'max',N-ref_distance);

set(handles.FrameSlider,'value',1);
set(handles.FrameSlider,'SliderStep',[1/(N-ref_distance) 0.01]);

set(handles.NumOfFramesEdit,'visible','on');
set(handles.NumOfFramesEdit,'string',['of ',num2str(N)]);

set(handles.text1,'visible','on');
set(handles.FrameEdit,'visible','on');
set(handles.text26,'visible','on');
set(handles.TargetFrameEdit,'visible','on');
set(handles.BlockMatchingBtn,'enable','on');