function ris=get_rising(signal, feat_th, fs)
nch=size(signal,2);
th=(10^(feat_th/20))/10000;
clock=abs(signal)>th;
[sig_idx,ch_idx]=find(clock>0.5);
ris=zeros(nch,1);
for j=1:nch
    [~,max_sig_idx]=max(abs(signal(:,j)));
    ch_sig_idx=sig_idx(ch_idx==j);
    if ~isempty(ch_sig_idx)
        ris(j)=max_sig_idx-ch_sig_idx(1)+1;
    end
end
ris=ris'/fs;