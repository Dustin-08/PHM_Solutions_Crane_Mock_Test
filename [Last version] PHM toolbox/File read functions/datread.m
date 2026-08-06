function [data, datainform] = datread(filepath)
fp=fopen(filepath);
fid = fread(fp,1,'int');
nch = fread(fp,1,'int');
fs = fread(fp,1,'int');
nsamp = fread(fp,1,'int');
nbit=fread(fp,1,'int');
minval=fread(fp,1,'double');
maxval=fread(fp,1,'double');
if nbit==16
    data=fread(fp,'short');
else
    data=fread(fp,'int');
end
data=reshape(data,nsamp,length(data)/nsamp);
data=data*maxval/(2^(nbit-1)-1);
datainform.fid = fid;
datainform.nch = nch;
datainform.fs=fs;
datainform.nsamp = nsamp;
datainform.nbit = nbit;
datainform.minval = minval;
datainform.maxval = maxval;
fclose all;
end




