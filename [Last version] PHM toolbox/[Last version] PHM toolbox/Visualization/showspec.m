function showspec(tval, tfreq, fsol, defect_freq, harmonics, colors)
%% Plotting envelope spectrum with bearing defect frequency
%% INPUT
% tval : The amplitude of spectrum
% tfreq : The freqeuncy bins of spectrum
% fsol : Signal length (1/frequency resolution)
% defect_freq : Defect frequencies
% harmonics : The number of harmonics of defect frequencies to present *
% colors : Color information for each defect frequency as cell array of string *
%% Remarks
% Copyright (C) Embedded System Lab., University of Ulsan - All Rights Reserved
% Unauthorized copying of this file, via any medium is strictly prohibited
% Proprietary and confidential

% Implemented by Jaeyoung Kim <kjy7097@gmail.com>, 31-Dec-2014.
% Edited by Jaeyoung Kim <kjy7097@gmail.com>, 20-Feb-2017. (Lisence notice is added)
% Edited by Jaeyoung Kim <kjy7097@gmail.com>, 22-Feb-2017. (Generalized, Included in BFD toolbox)
%%
Dfreq = defect_freq;
[mval, midx]=max(Dfreq);

ob_fr = uint16((mval*harmonics(midx)+mval)*fsol);
plot(tfreq(1:ob_fr), tval(1:ob_fr));
max_disp_freq = mval*harmonics(midx)+mval;
xlim([0 max_disp_freq]);
temp=tval;
ylim([0 max(temp(2*fsol:ob_fr))*1.3]);
for i=1:length(defect_freq)
    plotdefectfreq(Dfreq(i),harmonics(i),colors{i});      
end
xlabel('Frequency [Hz]')
ylabel('Amplitude')
