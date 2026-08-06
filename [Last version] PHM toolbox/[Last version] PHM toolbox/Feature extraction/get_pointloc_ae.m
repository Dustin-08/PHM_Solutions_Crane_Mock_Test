function [cx,cy]=getpointloc(arrival_time, v, x,y)
t1=arrival_time(1);
t2=arrival_time(2);
t3=arrival_time(3);

tx=x(2);
ty=y(2);
tx2=x(3);
ty2=y(3);

v2t12=v.^2*t1.^2;
v2t22=v.^2*t2.^2;
v2t32=v.^2*t3.^2;
A=(v2t12-v2t22+tx.^2)/(2*tx);
B=2*v.^2*(t2-t1)/(2*tx);
C=(v2t12-v2t32-2*A*tx2+tx2.^2+ty2.^2)/(2*ty2);
D=(-2*v.^2*t1+2*v.^2*t3-2*B*tx2)/(2*ty2);

I=A.^2+C.^2-v2t12;
J=2*A*B+2*C*D+2*v.^2*t1;
K=B.^2+D.^2-v.^2;
% ts=roots([K,J,I]);
syms x;
if J^2-4*K*I>=0
    ts=double(vpasolve(K*x^2+J*x+I));
else
    ts=double(vpasolve(2*K*x+J));
end
if length(ts)>1
    cond1=sum((arrival_time-ts(1)>0));
    cond2=sum((arrival_time-ts(2)>0));
    if cond1>cond2
        tidx=1;
    else
        tidx=2;
    end
    ts=ts(tidx);
    if length(arrival_time) > cond1 && length(arrival_time) > cond2
        cx=[];
        cy=[];
    else
        cx=A+B*ts;
        cy=C+D*ts;
    end
else
    cond1=sum((arrival_time-ts>0));
    if length(arrival_time) > cond1
        cx=[];
        cy=[];
    else
        cx=A+B*ts;
        cy=C+D*ts;
    end
end


