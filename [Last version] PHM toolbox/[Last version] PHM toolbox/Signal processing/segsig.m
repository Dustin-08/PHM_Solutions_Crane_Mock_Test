function wx = segsig(fsig, fs, n, sp)
%% 신호 분할 함수
%% input
% fsig : 입력신호
% fs : 샘플링 주파수
% n : 분할된 신호의 개수
% sp : 추출할 분할된 신호 (0부터 시작) 
% (예: n이 3이고 sp가 1면 fsig를 3개로 분할하고 2번째 부대역 신호를 추출함)
%% output
% wx : 분할된 신호

sec=length(fsig)/fs;
ws=2*sec/(double(n)+1);
winsize = floor(ws*fs);              % window size in sample
win = hann(winsize);                     % hanning window
hopsize = floor(winsize/2);              % 50% overlap
%% STFT starts
ep = winsize;
win=win(:);
fsig=fsig(:);
tmpsig=fsig(((sp-1)*hopsize+1):((sp-1)*hopsize+ep));
wx = win.*tmpsig;         % windowed signal