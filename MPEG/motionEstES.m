% Computes motion vectors using exhaustive search method
%
% Input
%   imgP : The image for which we want to find motion vectors
%   imgI : The reference image
%   mbSize : Size of the macroblock
%   p : Search parameter  (read literature to find what this means)
%
% Ouput
%   motionVect : the motion vectors for each integral macroblock in imgP
%   EScomputations: The average number of points searched for a macroblock
%
% Written by Aroh Barjatya

function [motionVect, EScomputations] = motionEstES(imgI, imgP, mbSize, p)

[row col] = size(imgI);

vectors = zeros(2,row*col/mbSize^2);
costs = ones(2*p + 1, 2*p +1) * 65537;

computations = 0;

% we start off from the top left of the image
% we will walk in steps of mbSize
% for every marcoblock that we look at we will look for
% a close match p pixels on the left, right, top and bottom of it

mbCount = 1;
for i = 1 : mbSize : row-mbSize+1
    for j = 1 : mbSize : col-mbSize+1
        
        % the exhaustive search starts here
        % we will evaluate cost for  (2p + 1) blocks vertically
        % and (2p + 1) blocks horizontaly
        % m is row(vertical) index
        % n is col(horizontal) index
        % this means we are scanning in raster order
        
        % 对搜索范围中的所有块进行穷尽搜索，找到最佳匹配块
        for m = -p : p        
            for n = -p : p
                
                refBlkVer = i + m;   % row/Vert co-ordinate for ref block
                refBlkHor = j + n;   % col/Horizontal co-ordinate
                
                if ( refBlkVer < 1 || refBlkVer+mbSize-1 > row ...
                        || refBlkHor < 1 || refBlkHor+mbSize-1 > col)
                    continue;
                end
                
                % 请完善costFuncMAD函数，计算匹配块的cost
                costs(m+p+1,n+p+1) = costFuncMAD(imgP(i:i+mbSize-1,j:j+mbSize-1), ...
                     imgI(refBlkVer:refBlkVer+mbSize-1, refBlkHor:refBlkHor+mbSize-1), mbSize);
                
                 computations = computations + 1;
                
            end
        end
        
        % Now we find the vector where the cost is minimum
        % and store it ... this is what will be passed back.
        
        % 选择具有最小MAD的块为最佳匹配块
        [dx, dy, min] = minCost(costs); % finds which macroblock in imgI gave us min Cost
        
        % 计算当前块和参考块之间位移量，作为当前块的运动向量
        vectors(1,mbCount) = dy-p-1;    % row co-ordinate for the vector
        vectors(2,mbCount) = dx-p-1;    % col co-ordinate for the vector
        
        mbCount = mbCount + 1;
        costs = ones(2*p + 1, 2*p +1) * 65537;
    end
end

motionVect = vectors;
EScomputations = computations/(mbCount - 1);
                    