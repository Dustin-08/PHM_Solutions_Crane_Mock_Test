function [signals,t,fs, nch]=wfsread(filename, start_time, end_time)

[Number_of_channels,Sample_rate,Max_voltage,Header_length, delay_idx, pretrigger]=PCI2ReadHeader(filename); % read Heads
nch=Number_of_channels;
voltage_scale=Max_voltage/32767;
fs = Sample_rate*1e3;
pretrigger_time=pretrigger/fs;
if nargin==3
    signals=zeros(round(fs*(end_time-start_time)),Number_of_channels);
end
for ii=1:Number_of_channels
    fid = fopen(filename,'rb');
    fseek(fid,(Header_length+(2076*(ii-1))+28+(2*ii)),-1);
    if nargin==3
        
        status=fseek(fid,fs*start_time*2+floor(fs*start_time*2/2048)*((2078*(Number_of_channels-1))+30),0);
        if status==-1
            signals=[];
            t=[];
            fs=[];
            fclose(fid);
            return;
        end
        if(round(mod(fs*start_time,1024))>0)
            [channel, read_size] = fread(fid,round(1024-mod(fs*start_time,1024)),'1024*short',(2078*(Number_of_channels-1))+30);
            if read_size<round(1024-(mod(fs*start_time,1024)))
                signals=[];
                t=[];
                fs=[];
                fclose(fid);
                return;
            end
            fseek(fid,(2078*(Number_of_channels-1))+30,0);
            [tmp_channel,read_size]=fread(fid,round(fs*(end_time-start_time)-(1024-mod(fs*start_time,1024))),'1024*short',(2078*(Number_of_channels-1))+30);
            if read_size<round(fs*(end_time-start_time)-(1024-mod(fs*start_time,1024)))
                signals=[];
                t=[];
                fs=[];
                fclose(fid);
                return;
            end
            channel = [channel; tmp_channel];
        else
            [channel,read_size]=fread(fid,round(fs*(end_time-start_time)),'1024*short',(2078*(Number_of_channels-1))+30);
            if read_size<round(fs*(end_time-start_time))
                signals=[];
                t=[];
                fs=[];
                fclose(fid);
                return;
            end
        end
%         channel=channel(1:101024);
%         fix_delay=1;
    else
        channel=fread(fid,'1024*short',(2078*(Number_of_channels-1))+30);
%         fix_delay=353;
    end
    fclose(fid);
%     delay_idx=0;    
    if delay_idx<0
        if ii==3 || ii==4
            Ch = voltage_scale*double(channel(1:end+delay_idx));
        else
            Ch = voltage_scale*double(channel(1-delay_idx:end));
        end
    else
        if ii==1 || ii==2
            Ch = voltage_scale*double(channel(1:end-delay_idx));
        else
            Ch = voltage_scale*double(channel(1+delay_idx:end));
        end
    end
    signals(1:length(Ch),ii) = Ch;
end
if nargin==3
    t=(start_time:1/fs:end_time-1/fs);
else
    t=(pretrigger/fs:1/fs:(length(signals)+pretrigger-1)/fs);
end
t=t(:);


%==========================================================================
% Subroutine
%==========================================================================
function [Number_of_channels,Sample_rate,Max_voltage, ...
    Header_length, delay_idx, Pretrigger]=PCI2ReadHeader(filename)
delay_idx=0;
fid = fopen(filename,'rb');

% TABLE 1
Header.Size_table = fread(fid,1,'short');
fseek(fid, Header.Size_table, 0);

% TABLE 2
Header.Size_table = fread(fid,1,'short');
fseek(fid, 3, 0);
Header.Number_of_channels = fread(fid,1,'int8');
fseek(fid, -4, 0);
fseek(fid, Header.Size_table, 0);

% TABLE 3
for i=1:Header.Number_of_channels
    Header.Size_table = fread(fid,1,'short');
%     fprintf(1,'%d : %d\n',i,Header.Size_table)
    fseek(fid, 12, 0);
    Header.sample_rate = fread(fid,1,'short');
    Header.Trigger_mode = fread(fid,1,'short');
    Header.Trigger_source = fread(fid,1,'short');
    Header.pretrigger=fread(fid,1,'short');
    fseek(fid, 2, 0);
    Header.maxvoltage = fread(fid,1,'short');
    fseek(fid, -24, 0);
    fseek(fid, Header.Size_table, 0);
end;

k=1;
while Header.Size_table ~= 2076
    Header.Size_table = fread(fid,1,'short');
%     fprintf(1,'%d : %d\n',k,Header.Size_table)
    if k==15
        fread(fid,2,'uint8');
        fread(fid,1,'short');
        fread(fid,1,'short');
        for i=1:Header.Number_of_channels
            fread(fid,1,'uint8');
            fread(fid,1,'short');
            fread(fid,1,'short'); 
            fread(fid,1,'short'); 
            if i==1
                delay_idx=fread(fid,1,'int64');
            elseif i==3
                delay_idx=delay_idx-fread(fid,1,'int64');
            else
                fread(fid,1,'int64');
            end
        end 
    else
        fseek(fid, Header.Size_table, 0);
    end
    k=k+1;
end;

fseek(fid, -2078, 0);
Header.Length_of_header = ftell(fid);

Header.Pre_Size_table = 0;
% while ~feof(fid)
%     Header.Size_table = fread(fid,1,'short');
%     fseek(fid, Header.Size_table, 0);
%     if Header.Pre_Size_table ~= 0 && Header.Pre_Size_table ~= Header.Size_table
%         Header.Data_cnt = Header.Data_cnt + 1;
%         break;
%     else
%         Header.Pre_Size_table = Header.Size_table;
%         Header.Data_cnt = Header.Data_cnt + 1;
%     end;
% end;

fclose(fid);

Number_of_channels=Header.Number_of_channels;
Sample_rate=Header.sample_rate;
Max_voltage=Header.maxvoltage;
Header_length=Header.Length_of_header;
Pretrigger=Header.pretrigger;

