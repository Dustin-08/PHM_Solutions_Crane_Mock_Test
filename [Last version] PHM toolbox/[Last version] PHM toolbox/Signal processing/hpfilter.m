function x=hpfilter(signal, fs, s_freq, margin_rate)
%% 밴드패스 필터
%% input
% signal : 입력 신호
% fs : 샘플링 주파수
% s_freq : 시작주파수 (passband)
% s_stop_freq, 시작주파수의 여유 (stopband)
%% output
%x : 필터링된 신호
fn=double(fs)/2;
[n, Wn]=buttord(s_freq/fn,s_freq*(1-margin_rate)/fn, 1, 10);
[bcoef, acoef]=butter(n, Wn, 'high');
[sos,g] = tf2sos(bcoef,acoef);
x = filtfilt(sos, g, signal);  