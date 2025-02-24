function [] = ShowIDCTImage(handles)
axes(handles.ReconstructedImageAxis);
imshow(mat2gray(handles.IDCTImage)); 