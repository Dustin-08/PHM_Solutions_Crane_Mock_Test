function arrival_time=getTOA(signals,t,thval)
arrival_time=zeros(4,1);
for i=1:4
    idx=find(abs(signals(:,i))>thval);
    arrival_time(i)=t(idx(1));
end