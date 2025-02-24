function [] = ShowDCTImage(handles)
axes(handles.DCTImageAxis);
imshow(mat2gray(handles.imDCT)); 