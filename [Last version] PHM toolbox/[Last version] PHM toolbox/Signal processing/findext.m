function [Maxima, MaxIdx, Minima, MinIdx, ExtremaNum] = findextrema(x)
%% Find all local extrema of function
%% Input
% x : input signal vector;
%% Output
% Maxima : function's local maximas
% MaximaIdx : indexes of local maximas
% Minima : function's local minimas
% MinimaIdx : indexes of local minimas

%% REMARKS
% This function is utilized for "decomp_emd.m" function.

% Copyright (C) Embedded System Lab., University of Ulsan - All Rights Reserved
% Unauthorized copying of this file, via any medium is strictly prohibited
% Proprietary and confidential

% Implemented by Alex P., 20-Feb-2017.

%% Find extremas
N = length(x); % get the amount of samples of signal X

if size(x) ~= [1 N]
    x = x';
end

[Maxima, MaxIdx] = findpeaks(x);
xInv = 1.01 * max(x) - x; % invert the signal to get local minima (1.01 - to keep all the inverted signal's values > 0)
[Minima, MinIdx] = findpeaks(xInv);

% The true minima:
Minima = x(MinIdx);

ExtremaNum = length(MaxIdx) + length(MinIdx);

MaxIdx = [1 MaxIdx N];
MinIdx = [1 MinIdx N];
end