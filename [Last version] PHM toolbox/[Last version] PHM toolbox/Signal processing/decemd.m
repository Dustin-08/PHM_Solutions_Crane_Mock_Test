function imf = decemd(x, n)
%% EMD signal decomposition ( Edited 2017.01.23 by Alexander Prosvirin)
%% INPUT 
% x - original signal which should be decomposed (it should be vector, not
% a matrix).
% n - maximum number of IMF we would like to receive in the result
%% OUTPUT
% imf - array consists of all decomposed IMF and residue
%% REMARKS
% To perform EMD decomposition, you also need to attach "find_extrema" and "find_zerocross" scripts;

% Copyright (C) Embedded System Lab., University of Ulsan - All Rights Reserved
% Unauthorized copying of this file, via any medium is strictly prohibited
% Proprietary and confidential

% Implemented by Alex P., 20-Feb-2017.
%% Function body

L = length(x);

% If the signal is not [1xL] vector -> transpose
if size(x) ~= [1 L]
    c = x';
else
    c = x;
end

imf = zeros(n,L); 

for i = 1: n 
h = c; % on the first step h is a signal;

done = false;

while (~done)
[~,maxidx,~,minidx, extrnum] = find_extrema(h);
[~,zerocrossNum] = find_zerocross(h);

if extrnum < 2 % this is residue
    break;
end
%--------------------------------------------------------------------------
% spline interpolation to get max and min envelopes;
maxenv = spline(maxidx,h(maxidx),1:L);
minenv = spline(minidx,h(minidx),1:L);

m  = (maxenv + minenv) / 2;

% Meet the conditions of stopping iterations
done = (zerocrossNum == extrnum || abs(zerocrossNum - extrnum)<=1) && any(m == 0);

h = h - m;
end

imf(i,:) = h;

if extrnum < 2 % this is residue
    break;
end

c = c - h;
end
end