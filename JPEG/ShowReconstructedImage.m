function [] = ShowReconstructedImage(handles)
axes(handles.ReconstructedImageAxis);
imshow(mat2gray(handles.reconstructedImage)); 