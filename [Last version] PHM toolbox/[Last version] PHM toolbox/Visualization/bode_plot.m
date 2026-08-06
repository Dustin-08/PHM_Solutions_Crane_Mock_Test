function [pha,pp,rot_speed]=bode_plot(signal, signal_tacho, fs, seglen)
%% 보데선도를 계산하는 함수
%% input
% signal : 입력신호
% signal_tacho : 타코신호
% fs : 샘플링 주파수
% seglen : 보데정보를 추출하기위한 신호의 분할길이 (초)
%% output
% pha : 페이즈 정보
% pp : 진폭 정보
% rot_speed : 회전속도 정보

slen=length(signal)/fs;
n_seg_data=floor(slen/seglen);
rot_speed=zeros(n_seg_data,1);
pha=zeros(n_seg_data,1);
pp=zeros(n_seg_data,1);
for i=1:n_seg_data
    segsig=signal((i-1)*fs*seglen+1:i*fs*seglen); %입력 신호를 분할함
    segsig_tacho=signal_tacho((i-1)*fs*seglen+1:i*fs*seglen); % 타코신호를 분할함
    rot_speed(i)=getRPM(segsig_tacho,fs); % 회전속도 추출 (RPM)
    a=find(segsig_tacho<min(segsig_tacho)*3/5); 
    b=find(diff(a)~=1);
    [~,pk1]=max(segsig(a(b(1)):a(b(2)))); % heavy spot
    
    pha(i)=360*pk1/abs(a(b(1))-a(b(2))); % 페이즈 계산
    
    pp(i)=max(segsig); % 진폭 계산
end