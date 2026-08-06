close all;
clear all;
ch1_to_pencil=1040; % 채널1에서 펜슬브레이크까지의 거리
ch2_to_pencil=1600; % 채널2에서 펜슬브레이크까지의 거리
rootPath='./1.속도테스트'; % 속도파일이 있는 폴더 경로


prev_num_file=0;
while 1
    dirData = dir([rootPath '/*.wfs']);     
    dirIndex = [dirData.isdir];  
    fileList = {dirData(~dirIndex).name}'; 
    if prev_num_file<length(fileList)
        [signals,t,fs,nch]=wfsread([rootPath '/' fileList{end}]);
        figure;
        for j=1:2
            ax(j)=subplot(2,1,j);
            plot(t,signals(:,j));
            idx=find(abs(signals(:,j))>0.01);
            if isempty(idx)
                idx(1)=1;
            end
            arrival_time(j)=t(idx(1));
        end
        linkaxes(ax,'x')
        xlim([0 3e-3])
        delta_t=arrival_time(2)-arrival_time(1);
    %     if delta_t<0
    %         continue;
    %     end
        v1=(ch2_to_pencil-ch1_to_pencil)/(arrival_time(2)-arrival_time(1));
        fprintf(1,'dt : %f, 속도 : %f\n', delta_t, v1);
    %     dt(i)=delta_t;
    %     x(i)=file_daten;
    %       (delta_t-prev_delta_t)/((file_daten-prev_daten)*86400)
    %     ((file_daten-start_daten)*86400)*dt_gap-2e-05
        prev_num_file=length(fileList);
    end
    pause(0.001)
end
% 초당 딜레이 증가량 3.9130434782608695652173913043478e-7
