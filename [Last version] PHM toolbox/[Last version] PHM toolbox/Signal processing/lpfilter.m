function x=lpfilter(signal, fs,e_freq, margin_rate)
%% 밴드패스 필터
%% input
% signal : 입력 신호
% fs : 샘플링 주파수
% e_freq : 끝주파수 (passband)
% e_stop_freq : 끝주파수의 여유 (stopband)
%% output
%x : 필터링된 신호

fn=fs/2;
[n, Wn]=buttord(e_freq/fn,(e_freq*(1+margin_rate))/fn,1, 10); % stopband 주파수와 passband corner 주파수를 입력으로 butterworth filter의 차수를 구하는 함수
% [n, Wn]=buttord([s_freq e_freq]/fn,[s_stop_freq e_stop_freq]/fn, 3, 40); % stopband 주파수와 passband corner 주파수를 입력으로 butterworth filter의 차수를 구하는 함수
[bcoef, acoef]=butter(n, Wn, 'low'); % butterworth filter의 a와 b 파라메터 생성
% x=filter(bcoef,acoef, signal); % bandpass filter 수행
[sos,g] = tf2sos(bcoef,acoef);
x = filtfilt(sos, g, signal);  
