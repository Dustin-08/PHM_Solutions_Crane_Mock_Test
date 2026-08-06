function [tval,tfreq]=getspec(signal, fs, fsol, en_pw, normfact)
%% Get spectrum
%% INPUT
% signal : input signal
% fs : sampling frequency
% fsol : signal length (1/frequency resolution)
% en_pw : enable power spectrum (0: autospectrum, 1: power spectrum)
% normfact : normalization factor (from windowing function)
%% OUTPUT
% tval : The amplitude of spectrum
% tfreq : The frequency bins of spectrum
%% REMARKS
% Copyright (C) Embedded System Lab., University of Ulsan - All Rights Reserved
% Unauthorized copying of this file, via any medium is strictly prohibited
% Proprietary and confidential

% Implemented by Jaeyoung Kim., 20-Feb-2017.
%%
if nargin<5
    normfact=1;
end
if nargin<4
    en_pw=0;
    normfact=1;
end
L=floor(fs*fsol);
fmag=fft(signal,L); %Fourier transform

fmag=abs(fmag/double(L)); %Scaling
fmag=fmag(1:L/2+1);
fmag(2:end-1)=2*fmag(2:end-1);
tfreq=fs*(0:(L/2))/L; %frequency sequence
fmax = fs/2;
fdelta = 1/fsol;
tfreq = (0:fdelta:fmax);

tval = abs(fmag(1:length(tfreq)))*normfact; % Amplitude sequence
if en_pw==1
    tval = tval.^2; % power spectrum
end
