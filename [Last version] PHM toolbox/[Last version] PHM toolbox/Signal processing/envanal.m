function esig=envanal(signal, method)
%% Envelope analysis
%% INPUT
% signal : input signal
% method : envelope analysis method (1=hilbert transform, 2=TKEO)
%% OUTPUT
% esig : envelope signal
%% REMARKS
% Copyright (C) Embedded System Lab., University of Ulsan - All Rights Reserved
% Unauthorized copying of this file, via any medium is strictly prohibited
% Proprietary and confidential

% Implemented by Jaeyoung Kim, 30-Nov-2016.
% Edited by Jaeyoung Kim, 14-Feb-2017.
% Edited by Jaeyoung Kim, 20-Feb-2017. : added default value for method
%% References
% References : "\\203.250.77.113\Source codes\Libraries\[Last version]PHM toolbox\# References"
% Hilbert transform : "Rolling element bearing diagnostics - A tutorial"
% TKEO : "Use of the Teager-Kaiser energy operator for condition monitoring of a wind turbine gearbox"

%%
if nargin<2
    method=1;
end
if method==1 % Envelope analysis using hilbert transform
    esig = abs(hilbert(signal));
%     esig=esig-mean(esig);
%     esig=esig/2;
elseif method==2 % Envelope analysis using Teager-Kaiser energy operator (TKEO)
    esig=signal;
    for i=2:length(signal)-1
        esig(i) = signal(i).^2-signal(i-1).*signal(i+1);
    end
    esig(1)=signal(2);
    esig(end)=signal(end-1);
end
