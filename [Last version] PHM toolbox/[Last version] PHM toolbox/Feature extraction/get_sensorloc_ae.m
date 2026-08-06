function [x,y]=getsensorloc(dist_array)

if length(dist_array)>3
    x=zeros(4,1);
    y=zeros(4,1);
    ch1_to_ch2=dist_array(1);
    ch1_to_ch3=dist_array(2);
    ch1_to_ch4=dist_array(3);
    ch2_to_ch3=dist_array(4);
    ch2_to_ch4=dist_array(5);
    ch3_to_ch4=dist_array(6);
else
    x=zeros(3,1);
    y=zeros(3,1);
    ch1_to_ch2=dist_array(1);
    ch1_to_ch3=dist_array(2);
    ch2_to_ch3=dist_array(3);
end

x(1)=0;
y(1)=0;
x(2)=ch1_to_ch2; 
y(2)=0;

x(3)=(x(2).^2+ch1_to_ch3.^2-ch2_to_ch3.^2)/(2*x(2));
y(3)=sqrt(ch1_to_ch3.^2-x(3).^2);
if length(dist_array)>3
    x(4)=(x(2).^2+ch1_to_ch4.^2-ch2_to_ch4.^2)/(2*x(2));
    y(4)=(x(3).^2+y(3).^2-2*x(3)*x(4)+ch1_to_ch4.^2-ch3_to_ch4.^2)/(2*y(3));
end