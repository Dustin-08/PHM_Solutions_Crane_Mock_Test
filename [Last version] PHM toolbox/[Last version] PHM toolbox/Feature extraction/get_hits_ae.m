function hits=gethits(signal,thval)
    idx=find(abs(signal)>thval);
    hits=sum(diff(idx)>1);
    if(~isempty(idx))
        hits=hits+1;
    end