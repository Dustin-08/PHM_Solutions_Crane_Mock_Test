function [zeroCrossIdx, zeroCrossNum] = findzerocross(x)
%% Find zerocrossings of functions
%% Input
% x : vector of function or signal
%% Output
% zeroCrossIdx : indexes of zeroscrossings
% zeroCrossNum : total number of zerocrossings
%% REMARKS
% This function is utilized for "decomp_emd.m" function.

% Copyright (C) Embedded System Lab., University of Ulsan - All Rights Reserved
% Unauthorized copying of this file, via any medium is strictly prohibited
% Proprietary and confidential

% Implemented by Alex P., 20-Feb-2017.
%% Find zerocrossings

N = length(x);

if size(x) ~= [1 N] % convert signal to 1xN dimenstional vector
    x = x';
end

zeroCrossNum = 0;
zeroCrossIdx = [];

s = sign(x);
d = s(1:end-1) - s(2:end);
zeroCrossNum = sum(d~=0);
zeroCrossIdx = find(d~=0);

end

