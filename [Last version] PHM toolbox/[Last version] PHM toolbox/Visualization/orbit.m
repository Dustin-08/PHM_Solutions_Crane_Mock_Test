function [x_data, y_data, hx, hy]=orbit(signal_x, signal_y, signal_tacho, fs, rot)
%% Orbit을 계산하는 함수
%% input
% signal_x : 입력 신호 1
% signal_y : 입력 신호 2
% signal_tacho : 타코신호
% fs : 샘플링 주파수
% rot : 센서의 부착 각도
%% output
% x_data : orbit의 x축 데이터
% y_data : orbit의 y축 데이터
% hx : heavy spot의 x축 정보
% hy : heavy spot의 y축 정보

x=signal_x;
y=signal_y;

RPM=getRPM(signal_tacho,fs);

a=find(abs(signal_tacho)>max(abs(signal_tacho))*3/5);
hs=find(diff(a)~=1);

% Butterworth low pass filter to remove high frequency components
[b2,a2] = butter(6,5*(RPM/60)/(fs/2),'low');
dataInX = x;
x_data = filter(b2,a2,dataInX); %filter command filters
dataInY = y;
y_data = filter(b2,a2,dataInY);

% butter worth band pass to only plot for 1X frequency component
[b1,a1] = butter(1,[((RPM-RPM*0.1)/60)/(fs/2) ((RPM+RPM*0.1)/60)/(fs/2)],'bandpass');
dataInX = x_data;
x_data = filter(b1,a1,dataInX); %filter command filters
dataInY = y_data;
y_data = filter(b1,a1,dataInY);
RCDis = [cosd(rot) -sind(rot);sind(rot) cosd(rot)]*[x_data, y_data]'; %센서부착각도를 고려하여 orbit 회전
x_data = RCDis(1,:); y_data = RCDis(2,:);

hx=x_data(a(hs));
hy=y_data(a(hs));

