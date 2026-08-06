%%%%%%%%%% Bearing Fault Signal Modeling%%%%%%%%%%%%%%%%
%%%%% MODELING OF LOW SHAFT SPEED BEARING FAULTS FOR CONDITION MONITORING
%%%%% Y.-F. Wang and P. J. Kootsookos, Mechanical Systems and Signal Processing, 1998
%%%%% Implemented by J.Y. Kim.
%% variables
    % X : Modeled signal X = XF * XQ * XB + XS + N
    % XF : Fault signal
    % XQ : Modulation effects caused by non-uniform load distribution
    % XB : Bearing induced vibration
    % XS : Random signal (Unwanted, Structured, and Predictable damped)
    % N : Gaussian white noise
%%
function X=modeling(defectname, rpm, load_harmonics, fs, length)
speed=rpm/60;

% 원래는 결함 주파수 계산해야함
defectfreq = [5.24 2.488*2 7.76, 0.4033];       %outer, roller, inner, cage

if strcmp(defectname,'outer')
    FF=defectfreq(1)*speed;
elseif strcmp(defectname,'roller')
    FF=defectfreq(2)*speed;
    FQ=defectfreq(4)*speed;
elseif strcmp(defectname,'inner')
    FF=defectfreq(3)*speed;
    FQ=speed;
end

t=(0:1/fs:length-1/fs);
XF=zeros(size(t,2),1);

for l=1:10
    XF=XF+cos(2*pi*l*FF*t)';
end

if strcmp(defectname,'outer')
    XQ=1;
else
    XQ=zeros(size(t,2),1);
    for k=1:load_harmonics
        XQ=XQ+0.01*cos(2*pi*k*FQ*t)';
    end
end

XB=zeros(size(t,2),1);

for j=1:1
    XB=XB+0.01*exp(0.01*t)'.*cos(2*pi*6752*t)';
end

X=XF.*XB.*XQ;
