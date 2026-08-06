function [x_data, y_data]=orbit_rpm(signal_x, signal_y, RPM, fs, rot)
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

% Butterworth low pass filter to remove high frequency components
[b2,a2] = butter(6,10*(RPM/60)/(fs/2),'low');
x_data = filter(b2,a2,x); %filter command filters
y_data = filter(b2,a2,y);

% butter worth band pass to only plot for 1X frequency component
[b1,a1] = butter(1,[((RPM-RPM*0.1)/60)/(fs/2) ((RPM+RPM*0.1)/60)/(fs/2)],'bandpass');
x_data = filter(b1,a1,x_data); %filter command filters
y_data = filter(b1,a1,y_data);
RCDis = [cosd(rot) -sind(rot);sind(rot) cosd(rot)]*[x_data, y_data]'; %센서부착각도를 고려하여 orbit 회전
x_data = RCDis(1,:); y_data = RCDis(2,:);

