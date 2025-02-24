function [] = ShowDecodedQuantizedDCTImage(handles)
axes(handles.ReconstructedQuantizedDCTImageAxis);
imshow(mat2gray(handles.DecodedQuantizedDCTImage)); 