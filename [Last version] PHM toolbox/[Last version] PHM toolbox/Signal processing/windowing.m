function [x, normfact]=windowing(signal, w_type, n, overlap)
%% 윈도우 함수
%% input
% signal : 입력신호
% w_type : 윈도우 종류 (0: hanning window, 1: flattop window)
% n : 윈도우 개수
% overlap : 중첩 정도 (0~1사이)
%% output
% x: 윈도우가 적용된 신호
% normfact : 정규화 상수(normalization factor)
%% 윈도우 생성 단계
siglen=length(signal);
w=zeros(siglen,1);
nw=ceil(siglen/(n-n*overlap+overlap)); %% 윈도우의 크기 계산
if w_type==0
    hw=hann(nw); % hanning 윈도우 생성
elseif w_type==1
   hw=flattopwin(nw); % flattop 윈도우 생성
end
%% 윈도우 적용 단계
for i=1:n
    startidx=1+(i-1)*nw*(1-overlap); %% i번째 분할 신호의 윈도우 적용 시작위치
    endidx=(i-1)*nw*(1-overlap)+nw; %% i번째 분할 신호의 윈도우 적용 끝위치
    if endidx>siglen
        hw=hw(1:end-(endidx-siglen)); %% 끝위치가 신호의 마지막 인덱스를 넘어기지 않기 위해 마지막 신호를 잘라냄
        endidx=siglen;
    end
    w(startidx:endidx)=w(startidx:endidx)+hw; % n개의 윈도우를 정합함
end
x=signal.*w; % 윈도우를 적용함
e=sum(abs(x));
e2=sum(abs(signal));
normfact=e2/e;   