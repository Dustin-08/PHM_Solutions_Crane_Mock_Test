function en=get_energy(signal, feat_th, fs)
nch=size(signal,2);
th=(10^(feat_th/20))/10000;
clock=abs(signal)>th;
[sig_idx,ch_idx]=find(clock>0.5);
en=zeros(nch,1);
for j=1:nch
    ch_sig_idx=sig_idx(ch_idx==j);
    ch_sig=abs(signal(ch_sig_idx,:));
    if ~isempty(ch_sig_idx)
        diff_ch_sig_idx=ch_sig_idx(2:end)-ch_sig_idx(1:end-1)+1;
        int_ch_sig=ch_sig(1:end-1,j)+ch_sig(2:end,j); 
        if isempty(diff_ch_sig_idx)
            en(j)=ch_sig(1,j)*1/fs;
        else
            en(j)=sum((diff_ch_sig_idx/fs).*int_ch_sig/2);
        end
    end
end
en=en';