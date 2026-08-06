function [x,f]=convmeas(signal, fs, type)
%% 변위, 속도, 가속도 단위 변환 함수
%% input
% signal : 입력신호
% fs : 샘플링 주파수
% type : 변한할 신호의 단위
%% output
% x : 변환된 신호
L=size(signal,1);
f=fs*(0:L-1)/L;
%w=hann(length(signal));
Y=fft(signal);
Y(f<=5)=0;
Y(end-5:end)=0;
wi=2i.*pi.*f;
wi=-wi';
if strcmp(type, 'vel')       %속도 계산
    Y = 9800*Y.*wi./((wi+eps).^2);
elseif strcmp(type, 'dis')       %변위 계산
    Y = -9800000*Y.*wi./((wi+eps).^3);
end
% Y(f<=10)=0;
% Y(end-10:end)=0;
Y(abs(Y)==inf | isnan(abs(Y)))=0;
x = ifft(Y,'symmetric');
% x = real(ifft(Y));
% 
% x = abs(fft(x.*w)).^2 ./ L;

%x = Y;


% x = x./w;
% x=imag(hilbert(x));
% x=imag(hilbert(x));


% 
% 
% 
% if i_type==0
%     if c_type==1 || c_type==2
%         x= diff(signal).*fs;%%속도에서 가속도로 변환
%         if c_type==2
%             x=diff(x).*fs; %% 변위에서 가속도로 변환
%         end
%     end
% elseif i_type==1
%     if c_type==0
%         x=(1/fs)*cumtrapz(signal); %% 속도에서 변위로 변환
%     elseif c_type==2
%         x=diff(signal).*fs; % 속도에서 가속도로 변환
%     end
% elseif i_type==2
%     if c_type==1 || c_type==0
%         x=(1/fs)*cumtrapz(signal); %%가속도에서 속도로 변환
%         if c_type==0
%             x=(1/fs)*cumtrapz(x); %가속도에서 변위로 변환
%         end
%     end
% end