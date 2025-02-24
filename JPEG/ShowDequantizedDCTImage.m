function [] = ShowDequantizedDCTImage(handles)
axes(handles.ReconstructedDCTImageAxis);
imshow(mat2gray(handles.DequantizedDCTImage)); 