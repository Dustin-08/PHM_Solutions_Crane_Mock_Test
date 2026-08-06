function [tval, tfreq]=zoomfft(signal, fs, fsol, sfreq, efreq)
%% Zoom FFT
%% %%%%%% INPUT %%%%%%%%%
% signal : Input signal
% fs : Sampling frequency
% fsol : Signal length (1/frequency resolution)
% sfreq : Begin frequency 
% efreq : End frequency
% efreq ~ sfreq : Zoom frequency band
%% %%%%%% OUTPUT %%%%%%%%
% tval : Amplitude of spectrum
% tfreq : Frequency bins of spectrum
%%
signal=signal(:);
fc=sfreq;
t=(0:1/fs:fsol-1/fs)';
y=signal.*cos(2*pi*fc*t)-1i*signal.*sin(2*pi*fc*t);
frange=(efreq-sfreq)/(fs/2);
[n, Wn]=buttord(frange,frange+frange*0.05, 3, 40); % matlab function
if n>10
    n=10;
end
[bcoef, acoef]=butter(n, Wn); %butterworth filter (matlab function)
fsignal=filter(bcoef,acoef, y); % filtered signal (matlab function)
fsignal=decimate(fsignal,ceil(fs/2/(efreq-sfreq))); %matlab function)
fs=fs/ceil(fs/2/(efreq-sfreq));
tfreq=0:1/fsol:fs-1/fsol;
tval=abs(fft(fsignal))/(length(fsignal)/2);
