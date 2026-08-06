function rpm=getRPM(signal_tacho, fs)
%% 타코신호로부터 회전속도를 계산하는 함수
%% input
% signal_tacho : 타코신호
% fs : 샘플링 주파수
%% output
% rpm : 회전속도 (RPM)
%% 타코신호의 스펙트럼 생성
slen=length(signal_tacho)/fs;
spec=abs(fft(signal_tacho))/fs*2;
fbin=(0:1/slen:fs-1/slen);
%% 타코신호에서 회전속도의 주파수를 추출함
idx=find(spec>mean(abs(signal_tacho))*2/5); 
ran=(idx(1):idx(diff(idx)>1));
[~,idx2]=max(spec(ran));
rpm=fbin(ran(idx2))*60; %% RPM 계산