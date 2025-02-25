function OperationOnTheFly(start,handles)

if (start==true)
    set(handles.StatusText,'String','Status: Please wait ...');
    set(handles.FrameSlider,'enable','inactive');
    handles.IsBusy=true;
else
    set(handles.StatusText,'String','Status: Ready!');
    set(handles.FrameSlider,'enable','on');
    handles.IsBusy=false;
end

drawnow;

guidata(handles.StatusText, handles);