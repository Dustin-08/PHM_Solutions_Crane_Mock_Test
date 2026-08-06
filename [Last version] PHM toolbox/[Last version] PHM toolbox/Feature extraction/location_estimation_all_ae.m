close all;
clear all;

ch1_to_ch2=1265;
ch1_to_ch3=775;
ch1_to_ch4=1265;
ch2_to_ch3=665;
ch2_to_ch4=605;
ch3_to_ch4=1010;
v=4899408.284024;

rootPath='./3. 위치테스트'; % 위치별 wfs파일들이 포함되어있는 폴더경로 (예 : rootPath='c:/root/')
%root폴더 내의 폴더는 다음과 같이 생성되있어야 함 : 'c:/root/위치1', 'c:/root/위치2', 'c:/root/위치3', 'c:/root/위치4'

[x,y]= getsensorloc([ch1_to_ch2 ch1_to_ch3 ch1_to_ch4 ch2_to_ch3 ch2_to_ch4 ch3_to_ch4]);

figure(1);
hold on;
grid on;
for i=1:4
    plot(x(i),y(i),'ko');
    text(x(i),y(i),['ch' num2str(i)]);
end
set(gca,'YDir','reverse');
% camroll(-125)
cl=['r', 'g', 'b', 'k'];


prev_num_file=0;
for k=1:4
    dirData = dir([rootPath '/위치' num2str(k) '/*.wfs']);      %# Get the data for the current directory
    dirIndex = [dirData.isdir];  %# Find the index for directories
    fileList = {dirData(~dirIndex).name}';  %'# Get a list of the files
    for j=1:length(fileList)
        [signals,t,fs]=wfsread([rootPath '/위치' num2str(k) '/' fileList{j}]);
        
        arrival_time=getTOA(signals,t,0.002);
        [cx,cy]=getpointloc(arrival_time,v,x,y);
        
        figure(1);        
        h=plot(cx,cy,[cl(k) '*']);
        d=sqrt((x-cx).^2+(y-cy).^2);
%         d=v*(arrival_time-ts);
        fprintf(1,'위치%d, ch1_to_pencil:%f, ch2_to_pencil:%f, ch3_to_pencil:%f, ch4_to_pencil:%f\n',k, d(1), d(2), d(3), d(4));
        prev_num_file=length(fileList);
    end
end
% xlim([-100 1200]);
% ylim([-100 1000]);