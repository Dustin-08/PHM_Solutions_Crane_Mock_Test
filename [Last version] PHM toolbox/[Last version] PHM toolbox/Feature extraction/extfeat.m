function fvector = extfeat(x)
%% input : 
% x  : signal
%% output 
% fvector : feature vector
%% REMARKS
% Copyright (C) Embedded System Lab., University of Ulsan - All Rights Reserved
% Unauthorized copying of this file, via any medium is strictly prohibited
% Proprietary and confidential

% Implemented by Jaeyoung Kim <kjy7097@gmail.com>, 11-Jan-2015.
% Modified by Jaeyoung Kim, 14-Feb-2017.
% Added features called "frequency spectrum energy" (fvector(21) respectively). Alex P. 20-Feb-2017.
%% time-domain features
peak = max(abs(x));                                       % peak value
rootms = rms(x);                                          % root-mean-square

fvector(1) = peak;                                        % peak
fvector(2) = rootms;                                      % root-mean-square
fvector(3) = kurtosis(x);                                 % kurtosis
fvector(4) = peak/rootms;                                 % crest factor
fvector(5) = peak/(sum(abs(x))/length(x));                % impulse factor
fvector(6) = rootms/(sum(abs(x))/length(x));        % shape factor
fvector(7) = skewness(x);                                % skewness
fvector(8) = (sum(sqrt(abs(x)))/length(x))^2;            % square mean root
fvector(9) = max(x)/fvector(8);                         % margin factor
fvector(10) = max(x)-min(x);                            % peak to peak
fvector(11) = fvector(3)/rootms^4;                      % kurtosis factor
fvector(12) = entropy1d(x,256);                                 % entropy
fvector(13) = sum(x.^2);                                  % energy of signal (more appliable to sub-bands or intrinsic functions)
fvector(14) = peak/(sum(sqrt(abs(x)))/length(x))^2;        % clearance factor
fvector(15) = moment(x,5)/std(x)^5;       % 5th normalized moment
fvector(16) = moment(x,6)/std(x)^6;       % 6th normalized moment
fvector(17) = fvector(8)/(sum(abs(x))/length(x));        % shape factor2
%% frequency-domain features
s = abs(fft(x));
k=(1:length(s))';
fvector(18) = sum(k.*s)/sum(s);                                  %Spectral centroid
fvector(19) = rms(s);                                   %Root mean square of frequency
fvector(20) = rms(s-mean(s));                           %Root variance of frequency
fvector(21) = sum(s.^2);                                %Frequency spectrum energy
fvector(22) = get_peak(x);
