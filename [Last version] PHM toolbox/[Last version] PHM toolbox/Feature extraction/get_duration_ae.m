function dur=get_duration(signal, feat_th, fs)
nch=size(signal,2);
th=(10^(feat_th/20))/10000;
clock=abs(signal)>th;
[sig_idx,ch_idx]=find(clock>0.5);
dur=zeros(nch,1);
for j=1:nch
    ch_sig_idx=sig_idx(ch_idx==j);
    if ~isempty(ch_sig_idx)
        dur(j)=ch_sig_idx(end)-ch_sig_idx(1)+1;
    end
end
dur=dur'/fs;