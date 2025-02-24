function [] = ShowQuantizedDCTImage(handles)
axes(handles.QuantizedDCTImageAxis);
imshow(mat2gray(handles.imQuantizedDCT)); 