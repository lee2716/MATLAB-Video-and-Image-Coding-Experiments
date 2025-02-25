% Computes the Mean Absolute Difference (MAD) for the given two blocks
% Input
%       currentBlk : The block for which we are finding the MAD
%       refBlk : the block w.r.t. which the MAD is being computed
%       block_size : block size
%
% Output
%       cost : The MAD for the two blocks

function cost = costFuncMAD(currentBlk,refBlk, block_size)

% 请计算当前块和参考块之间的MAD
 %cost = sum(sum(abs(currentBlk-refBlk)))/(block_size*block_size)
 
 %MSR
%cost = sum(sum(abs(currentBlk-refBlk).^2))/(block_size*block_size)

%SAD 
cost = sum(sum(abs(currentBlk-refBlk)));
