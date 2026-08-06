% function x=bpfilter(signal, fs, s_freq, s_stop_freq, e_freq, e_stop_freq)
function x=bpfilter(signal, fs, s_freq, e_freq, margin_rate)
%% 밴드패스 필터
%% input
% signal : input_signal
% fs : sampling frequency
% s_freq : start frequency (passband)
% s_stop_freq, start frequency margin (stopband)
% e_freq : end frequency (passband)
% e_stop_freq : end frequency margin (stopband)
%% output
%x : filtered
fn=fs/2;

[n, Wn]=buttord([s_freq e_freq]/fn,[s_freq*(1-margin_rate) e_freq*(1+margin_rate)]/fn,1, 10); % stopband 주파수와 passband corner 주파수를 입력으로 butterworth filter의 차수를 구하는 함수

% [n, Wn]=buttord([s_freq e_freq]/fn,[s_stop_freq e_stop_freq]/fn, 3, 40); % stopband 주파수와 passband corner 주파수를 입력으로 butterworth filter의 차수를 구하는 함수
[bcoef, acoef]=butter(n, Wn); % butterworth filter의 a와 b 파라메터 생성
% x=filter(bcoef,acoef, signal); % bandpass filter 수행
[sos,g] = tf2sos(bcoef,acoef);
x = filtfilt(sos, g, signal);  