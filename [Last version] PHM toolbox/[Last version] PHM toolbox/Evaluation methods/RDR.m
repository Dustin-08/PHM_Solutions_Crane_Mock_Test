function peakRatio = RDR(tval, tfreq, speed, fsol, type, defect_freq)

order=2;
faultFreq = (defect_freq.*speed/60);
freqwin=[4 2 2];
% peakRatio = zeros(1,3);
% faultFreq=faultFreq.*fsol;

%% for drawing
err=0.025;
k=10^-1;
fc=0.4032*speed/60;
fr=speed/60;

% outer
Nw(1)=2*faultFreq(1)*err*fsol;
Nr(1)=faultFreq(1)/freqwin(1);

%roller
Nw(2)=(4*fc+(4*fc+2*faultFreq(2))*err)*fsol;
Nr(2)=faultFreq(2)/freqwin(2);

%inner
Nw(3)=(4*fr+(4*fr+2*faultFreq(3))*err)*fsol;
Nr(3)=faultFreq(3)/freqwin(3);

peakRatio=0;
for i = 1:order
    faultHarFreq= faultFreq(type)*i;
    range = (tfreq >= (faultHarFreq-Nr(type))) & (tfreq<= (faultHarFreq+Nr(type)));

    x = tfreq(range);
    alpha=estalpha(length(x),Nw(type),k);
    mask=gausswin(length(x),alpha);
    mask(1:end-1)=mask(2:end);

    y=tval(range).*mask;
    %         localPeak(i)=sum(y.^2);
    tval(range)=tval(range)-y;
    peakRatio=peakRatio+10*log10(sum(y.^2)/sum(tval(range).^2)+10);
    %         close all;
end
