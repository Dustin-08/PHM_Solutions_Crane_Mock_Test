close all;
clear all;
x=zeros(4,1);
y=zeros(4,1);

ch1_to_ch2=1790; % 채널1에서 채널2까지의 거리
ch2_to_ch3=1650; % 채널2에서 채널3까지의 거리
ch1_to_ch3=1855; % 채널1에서 채널3까지의 거리
ch1_to_ch4=1980; % 채널1에서 채널4까지의 거리
ch2_to_ch4=2884.5; % 채널2에서 채널4까지의 거리
ch3_to_ch4=1500; % 채널3에서 채널4까지의 거리
v= 4087591.240876; % 속도
rootPath='./2.위치테스트'; %폴더경로 (예 : rootPath='c:/root/')

x(1)=0;
y(1)=0;
x(2)=ch1_to_ch2; 
y(2)=0;


x(3)=(x(2).^2+ch1_to_ch3.^2-ch2_to_ch3.^2)/(2*x(2));
y(3)=sqrt(ch1_to_ch3.^2-x(3).^2);

x(4)=(x(2).^2+ch1_to_ch4.^2-ch2_to_ch4.^2)/(2*x(2));
y(4)=(x(3).^2+y(3).^2-2*x(3)*x(4)+ch1_to_ch4.^2-ch3_to_ch4.^2)/(2*y(3));



figure(1);
hold on;
grid on;
for i=1:4
    plot(x(i),y(i),'ko');
    text(x(i),y(i),['ch' num2str(i)]);
end
% set(gca,'YDir','reverse');
% camroll(-125)
prev_num_file=0;
while 1
    dirData = dir([rootPath '/*.wfs']);      %# Get the data for the current directory
    dirIndex = [dirData.isdir];  %# Find the index for directories
    fileList = {dirData(~dirIndex).name}';  %'# Get a list of the files
    if prev_num_file < length(fileList)
        [signals,t,fs]=wfsread([rootPath '/' fileList{end}]);
        
        arrival_time=zeros(4,1);
%         figure(j+2);
        for i=1:4
%             ax(i)=subplot(4,1,i);
%             plot(t,signals(:,i));
            idx=find(abs(signals(:,i))>0.002);
            arrival_time(i)=t(idx(1));
        end
%         linkaxes(ax,'x')
%         xlim([0 1.5e-3])
        
        
        t1=arrival_time(1);
        t2=arrival_time(2);
        t3=arrival_time(3);
        
        tx=x(2);
        ty=y(2);
        tx2=x(3);
        ty2=y(3);
        
        v2t12=v.^2*t1.^2;
        v2t22=v.^2*t2.^2;
        v2t32=v.^2*t3.^2;
        A=(v2t12-v2t22+tx.^2)/(2*tx);
        B=2*v.^2*(t2-t1)/(2*tx);
        C=(v2t12-v2t32-2*A*tx2+tx2.^2+ty2.^2)/(2*ty2);
        D=(-2*v.^2*t1+2*v.^2*t3-2*B*tx2)/(2*ty2);
        
        I=A.^2+C.^2-v2t12;
        J=2*A*B+2*C*D+2*v.^2*t1;
        K=B.^2+D.^2-v.^2;
        ts=roots([K,J,I]);
        
        cond1=sum((arrival_time-ts(1)>0));
        cond2=sum((arrival_time-ts(2)>0));
        if cond1>cond2
            tidx=1;
        else
            tidx=2;
        end
        ts=ts(tidx);
        
        cx=A+B*ts;
        cy=C+D*ts;
        
        figure(1);
        %     if cy<-2000
        %         cy=cy+4000;
        %     end
        
        h=plot(cx,cy,'r*');
        
        d=sqrt((x-cx).^2+(y-cy).^2);
%         d=v*(arrival_time-ts);
        fprintf(1,'ch1_to_pencil:%f, ch2_to_pencil:%f, ch3_to_pencil:%f, ch4_to_pencil:%f\n', d(1), d(2), d(3), d(4));
        prev_num_file=length(fileList);
    end
    pause(0.001);
end
% xlim([-100 1200]);
% ylim([-100 1000]);