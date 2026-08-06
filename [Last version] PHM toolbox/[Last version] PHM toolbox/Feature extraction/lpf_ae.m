function y=lpf(signal, fs, fc)
signal=abs(signal);
RC=1/(2*pi*fc);
dt=1/fs;
alpha=dt/(RC+dt);
y=zeros(length(signal),1);
y(1)=alpha*signal(1);
for i=2:length(signal)
    y(i)=y(i-1)+alpha.*(signal(i)-y(i-1));
end
y=y.*(max(signal)/max(y));
