% Computes motion vectors using Four Step Search method
%
% Based on the paper by Lai-Man Po, and Wing-Chung Ma
% IEEE Trans. on Circuits and Systems for Video Technology
% Volume 6, Number 3, June 1996 :  Pages 313:317
%
% Input
%   imgP : The image for which we want to find motion vectors
%   imgI : The reference image
%   mbSize : Size of the macroblock
%   p : Search parameter  (read literature to find what this means)
%
% Ouput
%   motionVect : the motion vectors for each integral macroblock in imgP
%   SS4computations: The average number of points searched for a macroblock
%
% Written by Aroh Barjatya


function [motionVect, SS4Computations] = motionEst4SS(imgI,imgP,mbSize)

[row col] = size(imgI);

vectors = zeros(2,row*col/mbSize^2);
costs = ones(3, 3) * 65537;


% we start off from the top left of the image
% we will walk in steps of mbSize
% for every marcoblock that we look at we will look for
% a close match p pixels on the left, right, top and bottom of it
computations = 0;


mbCount = 1;
for i = 1 : mbSize : row-mbSize+1
    for j = 1 : mbSize : col-mbSize+1
        
        % the 4 step search starts
        % we are scanning in raster order
        
        x = j;
        y = i;
        
        costs(2,2) = costFuncMAD(imgP(i:i+mbSize-1,j:j+mbSize-1), ...
                                    imgI(i:i+mbSize-1,j:j+mbSize-1),mbSize);
        computations = computations + 1;
        
        % This is the calculation of the 9 points
        % As this is the first stage, we evaluate all 9 points
        for m = -2 : 2 : 2        
            for n = -2 : 2 : 2
                refBlkVer = y + m;   % row/Vert co-ordinate for ref block
                refBlkHor = x + n;   % col/Horizontal co-ordinate
                if ( refBlkVer < 1 || refBlkVer+mbSize-1 > row ...
                     || refBlkHor < 1 || refBlkHor+mbSize-1 > col)
                     continue;
                end

                costRow = m/2 + 2;
                costCol = n/2 + 2;
                if (costRow == 2 && costCol == 2)
                    continue
                end
                costs(costRow, costCol ) = costFuncMAD(imgP(i:i+mbSize-1,j:j+mbSize-1), ...
                    imgI(refBlkVer:refBlkVer+mbSize-1, refBlkHor:refBlkHor+mbSize-1), mbSize);
                computations = computations + 1;

            end
        end
        
        % Now we find the vector where the cost is minimum
        % and store it ... 
        
        [dx, dy, cost] = minCost(costs);      % finds which macroblock in imgI gave us min Cost
            
              
       
        % The flag_4ss is set to 1 when the minimum
        % is at the center of the search area           
        
        if (dx == 2 && dy == 2)
            flag_4ss = 1;
        else
            flag_4ss = 0;
            xLast = x;
            yLast = y;
            x = x + (dx-2)*2;
            y = y + (dy-2)*2;
        end

        costs = ones(3,3) * 65537;
        costs(2,2) = cost;
        
        stage = 1;
        while (flag_4ss == 0 && stage <=2)
            for m = -2 : 2 : 2        
                for n = -2 : 2 : 2
                    refBlkVer = y + m;   % row/Vert co-ordinate for ref block
                    refBlkHor = x + n;   % col/Horizontal co-ordinate
                    if ( refBlkVer < 1 || refBlkVer+mbSize-1 > row ...
                        || refBlkHor < 1 || refBlkHor+mbSize-1 > col)
                        continue;
                    end

                    if (refBlkHor >= xLast - 2 && refBlkHor <= xLast + 2 ...
                           && refBlkVer >= yLast - 2 && refBlkVer <= yLast + 2 )
                        continue;
                    end
                    
                    costRow = m/2 + 2;
                    costCol = n/2 + 2;
                    if (costRow == 2 && costCol == 2)
                        continue
                    end
                           
                    costs(costRow, costCol ) = costFuncMAD(imgP(i:i+mbSize-1,j:j+mbSize-1), ...
                                            imgI(refBlkVer:refBlkVer+mbSize-1, ...
                                              refBlkHor:refBlkHor+mbSize-1), mbSize);
                    computations = computations + 1;
                                              
                end
            end
                
            [dx, dy, cost] = minCost(costs);
            
            
            if (dx == 2 && dy == 2)
                flag_4ss = 1;
            else
                flag_4ss = 0;
                xLast = x;
                yLast = y;
                x = x + (dx-2)*2;
                y = y + (dy-2)*2;
            end
            
            costs = ones(3,3) * 65537;
            costs(2,2) = cost;
            stage = stage + 1;
           
            
        end  % while loop ends here
        
        
        % we now enter the final stage
        
        % 最后一步，将搜索模板修改为3x3
        for m =         
            for n = 
                refBlkVer = y + m;   % row/Vert co-ordinate for ref block
                refBlkHor = x + n;   % col/Horizontal co-ordinate
                if ( refBlkVer < 1 || refBlkVer+mbSize-1 > row ...
                     || refBlkHor < 1 || refBlkHor+mbSize-1 > col)
                     continue;
                end

                costRow = m + 2;
                costCol = n + 2;
                if (costRow == 2 && costCol == 2)
                    continue
                end
                costs(costRow, costCol ) = costFuncMAD(imgP(i:i+mbSize-1,j:j+mbSize-1), ...
                imgI(refBlkVer:refBlkVer+mbSize-1, refBlkHor:refBlkHor+mbSize-1), mbSize);
                computations = computations + 1;
            end
        end
        
        % Now we find the vector where the cost is minimum
        % and store it ... 
        
        [dx, dy, cost] = minCost(costs);
        
        x = x + dx - 2;
        y = y + dy - 2;
        
        vectors(1,mbCount) = y - i;    % row co-ordinate for the vector
        vectors(2,mbCount) = x - j;    % col co-ordinate for the vector            
        mbCount = mbCount + 1;
        costs = ones(3,3) * 65537;
        
    end
end
    
motionVect = vectors;
SS4Computations = computations/(mbCount - 1);
    
    
    
 