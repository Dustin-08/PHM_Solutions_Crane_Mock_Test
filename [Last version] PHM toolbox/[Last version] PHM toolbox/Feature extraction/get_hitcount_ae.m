function hitcount=get_hitcount(signal, feat_th)
th=(10^(feat_th/20))/10000;
clock=abs(signal)>th;
hitcount=sum((clock(2:end,:)-clock(1:end-1,:))>0)+1;
