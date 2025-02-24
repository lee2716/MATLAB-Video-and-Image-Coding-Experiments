function [] = ShowOriginalImage(handles)
axes(handles.OriginalImageAxis);
imshow(mat2gray(handles.im)); 
