function [im_seq_y] = read_yuv_luminanance_only(handles,in_file_name)

set(handles.StatusText,'string','Status: loading video file...');
drawnow;

fid= fopen(in_file_name,'rb');

[pathstr, name, ext] = fileparts(in_file_name);
    
if (strcmp(ext,'.qcif'))
    nRow = 288 / 2;
    nColumn = 352 / 2;       
else   
    nRow = 288;
    nColumn = 352;
end

%%%Read now the wanted frames
counter_frame=1;

while (~feof(fid) & counter_frame <= 100)
    
    %reading Y (luminance) component
	img_y = fread(fid, nRow * nColumn, 'uchar');
    
    if (numel(img_y)<nRow * nColumn)
        break;
    end

    img_y = reshape(img_y, nColumn, nRow);
    im_seq_y(:,:,counter_frame) = img_y';
       
    %reading U component    
    img_u = fread(fid, nRow * nColumn / 4, 'uchar'); 
    %reading V component
    img_v = fread(fid, nRow * nColumn / 4, 'uchar');   
    
    counter_frame=counter_frame+1;
    
end

fclose(fid);

 set(handles.StatusText,'string','Status: loading video completed!');
