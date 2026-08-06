function [signals,t,fs, nch]=wfsread(filename, start_time, end_time)

[Number_of_channels,Sample_rate,Max_voltage,Header_length,Data_cnt, delay_idx]=PCI2ReadHeader(filename); % read Heads
nch=Number_of_channels;
voltage_scale=Max_voltage/32767;
fs = Sample_rate*1e3;
if nargin==3
    signals=zeros(floor(fs*(end_time-start_time)),Number_of_channels);
end
for ii=1:Number_of_channels
    fid = fopen(filename,'rb');
    fseek(fid,(Header_length+(2076*(ii-1))+28+(2*ii)),-1);
%     fseek(fid, Header_length+(2076*(ii-1))+(2*ii),-1);
%     a=fread(fid,(28),'uint8');
%     figure, plot(a)
    if nargin==3
        status=fseek(fid,fs*start_time*2+floor(fs*start_time*2/2048)*((2078*(Number_of_channels-1))+30),0);
        if status==-1
            signals=[];
            t=[];
            fs=[];
            fclose(fid);
            return;
        end
        if(mod(fs*start_time,1024)>0)
            [channel, read_size] = fread(fid,1024-mod(fs*start_time,1024),'1024*short',(2078*(Number_of_channels-1))+30);
            if read_size<floor(1024-mod(fs*start_time,1024))
                signals=[];
                t=[];
                fs=[];
                fclose(fid);
                return;
            end
            fseek(fid,(2078*(Number_of_channels-1))+30,0);
            [tmp_channel,read_size]=fread(fid,fs*(end_time-start_time)-(1024-mod(fs*start_time,1024))+969,'1024*short',(2078*(Number_of_channels-1))+30);
            if read_size<floor(fs*(end_time-start_time)-(1024-mod(fs*start_time,1024))+969)
                signals=[];
                t=[];
                fs=[];
                fclose(fid);
                return;
            end
            channel = [channel; tmp_channel];
        else
            [channel,read_size]=fread(fid,fs*(end_time-start_time)+969,'1024*short',(2078*(Number_of_channels-1))+30);
            if read_size<floor(fs*(end_time-start_time)+969)
                signals=[];
                t=[];
                fs=[];
                fclose(fid);
                return;
            end
        end
    else
        channel=fread(fid,'1024*short',(2078*(Number_of_channels-1))+30);
    end
    fclose(fid);
    
    Ch = voltage_scale*double(channel);
    Ch_size = size(channel)-970;
    signals(1:Ch_size(1,1)+1,ii) = Ch(970:end);
    if ii==3 || ii==4
        Ch_size = size(channel)-970+delay_idx;
        signals(1:Ch_size(1,1)+1,ii) = Ch(970-delay_idx:end);
    end
    
end
if nargin==3
    t=(start_time:1/fs:end_time-1/fs);
else
    t=(0:1/fs:Ch_size/fs);
end


%==========================================================================
% Subroutine
%==========================================================================
function [Number_of_channels,Sample_rate,Max_voltage, ...
    Header_length,Data_cnt, delay_idx]=PCI2ReadHeader(filename)

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
    a=fread(fid,1,'uint8');
    b=fread(fid,1,'uint8');
    c=fread(fid,1,'short');
    d=fread(fid,1,'int8');
    e=fread(fid,1,'short');
    Header.Hardware_size = fread(fid,1,'short');
    f=fread(fid,1,'int8');
    g=fread(fid,1,'short');
%     fseek(fid, 12, 0);
    Header.sample_rate = fread(fid,1,'short');
    Header.Trigger_mode = fread(fid,1,'short');
    Header.Trigger_source = fread(fid,1,'short');
    Header.pretrigger=fread(fid,1,'short');
    h=fseek(fid, 2, 0);
    Header.maxvoltage = fread(fid,1,'short');
%     fprintf(1,'ch%d, a:%d, b:%d, c:%d, d:%d, e:%d, f:%d, g:%d, h:%d\n', i,a,b,c,d,e,f,g,h);
%     Header
    fseek(fid, -24, 0);
    fseek(fid, Header.Size_table, 0);
end;

Header.Size_table =fread(fid,1,'short');
fread(fid,1,'uint8');
fread(fid,5,'int8');
for i=1:Header.Number_of_channels
    a=fread(fid,2,'int8');
%     fprintf(1,'ch%d, a1:%d, a2:%d\n', i,a(1),a(2));
end;

Header.Size_table = fread(fid,1,'short');
fseek(fid, Header.Size_table, 0);

Header.Size_table5 =fread(fid,1,'short');
fread(fid,1,'uint8');
fread(fid,5,'int8');
for i=1:Header.Number_of_channels
    a=fread(fid,2,'int8');
%     fprintf(1,'ch%d, a1:%d, a2:%d\n', i,a(1),a(2));
end;

% TABLE 5
for i=1:Header.Number_of_channels
    a=fread(fid,1,'short');
    b=fread(fid,1,'uint8');
    c=fread(fid,2,'int8');
%     fprintf(1,'ch%d, a:%d, b:%d, c1:%d, c2:%d\n', i,a,b,c(1),c(2));
end;

k=1;
while Header.Size_table ~= 2076
    Header.Size_table = fread(fid,1,'short');
%     a=fread(fid,Header.Size_table,'uint8');
    if k==12
%         if mod(Header.Size_table,2)==0
%             a=fread(fid,Header.Size_table/2,'short');
%             subplot(5,1,k-8);
%             plot(a)
%         else
%             
%             a=fread(fid,Header.Size_table/2,'short');
%             b=fread(fid,1,'uint8');
%             subplot(5,1,k-8);
%             plot(a)
%         end
        fread(fid,2,'uint8');
        fread(fid,1,'short');
        fread(fid,1,'short');
        for i=1:Header.Number_of_channels
            fread(fid,1,'uint8')
            fread(fid,1,'short') 
            fread(fid,1,'short') 
            fread(fid,1,'short') 
            if i==1
                delay_idx=fread(fid,1,'int64');
            elseif i==3
                delay_idx=delay_idx-fread(fid,1,'int64');
            else
                fread(fid,1,'int64');
            end
        end;  
%         subplot(5,1,k-8);
%         plot(a)
%         xlim([1,30]);
%         ylim([0,300]);
%         a(16:19)
    else
        fseek(fid, Header.Size_table, 0);
    end

    k=k+1;
    
end;

fseek(fid, -2078, 0);
Header.Length_of_header = ftell(fid);

Header.Pre_Size_table = 0;
Header.Data_cnt = 0;
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
Data_cnt = Header.Data_cnt;

