function [feature_name_list, features_list, signal_list, time_list] = dtaread(filename)
fp=fopen(filename,'rb'); %% 파일 열기
CIDs = []; %% 채널 번호 목록
CHIDs=[]; %% 특징 번호 목록
PIDs=[]; %% Hit parametrics 목록
HLKs = containers.Map('KeyType','uint32','ValueType','uint32');
SRATEs= containers.Map('KeyType','uint32','ValueType','uint32');
TDLYs= containers.Map('KeyType','uint32','ValueType','int32');
features_list = cell(100,1);
for i=1:100
    features_list{i}=[];
    signal_list{i}=[];
    time_list{i}=[];
end
voltage_scale=10/32767;
feature_name_list={'Rise Time', 'Peak Counts', 'Counts', 'Energy', 'Duration', 'Amplitude', 'RMS', 'ASL' ,'Gain' ,'Threshold', 'Pre-Amp Current' ,'Lost Hits', 'Average Freq.', 'Reserved' , 'Reserved' , 'Reserved', 'RMS', 'Unknown', 'Init. Freq.', 'Sig. Strength'};
features_size=[2,2,2,2,4,1,1,1,1,1,1,4,2,2,6,4,2,1,2,4];
fidxs = [];
fidx=0;
sidxs=[];
sidx=0;
while ~feof(fp)
    LEN = fread(fp,1,'uint16');  %% Product Definition
    if isempty(LEN)
        break;
    end
    ID=fread(fp,1);
    c=0;
    if ID == 42
        fread(fp,3);
        while LEN>0
            c=c+1;
            SUBLEN = fread(fp,1, 'uint16');
            SUBID = fread(fp,1);
            if SUBID == 5
                nCHID = fread(fp,1);
                for i=1:nCHID
                    CHIDs=[CHIDs; fread(fp,1)];
                end
                nPID=fread(fp,1);
            elseif SUBID==173
                SSUBID=fread(fp,1);
                if SSUBID==42
                    fread(fp,2);
                    fread(fp,1);
                    fread(fp,2);
                    fread(fp,2);
                    CID=fread(fp,1);
                    HLKs(CID)=fread(fp,1, 'uint16');
                    fread(fp,2);
                    SRATEs(CID)=fread(fp,1,'uint16');
                    fread(fp,2);
                    fread(fp,2);
                    TDLYs(CID)=fread(fp,1,'int16');
                    fread(fp,SUBLEN-22);
                    %                     fprintf(1,'%d : %d, %d\n', CID,HLKs(CID),SRATEs(CID));
                else
                    fread(fp,SUBLEN-2);
                end
            else
                %                 fprintf(1,'%d: %d\n',SUBID, SUBLEN);
                fread(fp,SUBLEN-1);
            end
            LEN = LEN-SUBLEN;

        end
    elseif ID == 1
        %         fprintf(1,'%d : %d\n',ID,LEN);
        RTOT=fread(fp,1,'uint'); %4b
        tt=fread(fp,1, 'uint16'); % 2b
        t=(tt*4294967296 + RTOT)/4000000.0;
        CID=fread(fp,1); % 1b
        CIDs=[CIDs; CID];
        feature=[t];
        for i=1:nCHID
            if features_size(CHIDs(i))==1
                ff=fread(fp,1);
            elseif features_size(CHIDs(i))==2
                ff=fread(fp,1,'uint16');
            elseif features_size(CHIDs(i))==4
                ff=fread(fp,1,'uint');
            end
            if CHIDs(i)==17
                feature=[feature,ff*0.0002];
            elseif CHIDs(i)==20
                feature=[feature,ff*3.05];
            else
                feature=[feature,ff];
            end
        end
        for i=1:nPID
            fread(fp,3);
        end
        if CID == 0
            a=1;
        end
        features_list{CID}=[features_list{CID};feature];
    elseif ID==173
        SUBID = fread(fp,1);
        RTOT=fread(fp,1,'uint'); %4b
        tt=fread(fp,1, 'uint16'); % 2b
        ts=(tt*4294967296 + RTOT)/4000000.0;
        CID = fread(fp,1);
        ALB = fread(fp,1);
        if LEN > 10
            signal=fread(fp,HLKs(CID)*1024,'short');
            signal_list{CID}=[signal_list{CID},[ts;signal.*voltage_scale]];
            t=(double(TDLYs(CID)):double(TDLYs(CID))+double(HLKs(CID))*1024-1)./double(SRATEs(CID)*1000);
            time_list{CID}=[time_list{CID},t'];
        else
            signal_list{CID}=[signal_list{CID},[ts;zeros(HLKs(CID)*1024,1)]];
            t=(double(TDLYs(CID)):double(TDLYs(CID))+double(HLKs(CID))*1024-1)./double(SRATEs(CID)*1000);
            time_list{CID}=[time_list{CID},t'];
        end
%         fread(fp,LEN-1);
    elseif ID==2
        %         fprintf(1,'%d : %d\n',ID,LEN);
        fread(fp,LEN-1);
    else
        %         fprintf(1,'%d : %d\n',ID,LEN);
        fread(fp,LEN-1);
    end
end
feature_name_list = feature_name_list(CHIDs);
fclose(fp);