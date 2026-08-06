function alpha=estalpha(Nr, Nw, k)
%% Envelope analysis
%% Input
% Nr : the number of frequency bins considered as residual components
% Nw : the number of frequency bins considered as defect components
% k: a constant value related to the convergence of Gaussian window (0 < k <1)
%% Output
% alpha : inversely proportional to the standard deviation of Gussian random variables
%% Remarks
% Copyright (C) Embedded System Lab., University of Ulsan - All Rights Reserved
% Unauthorized copying of this file, via any medium is strictly prohibited
% Proprietary and confidential

% Implemented by Jaeyoung Kim <kjy7097@gmail.com>, 11-Jan-2015.
% Modified by Jaeyoung Kim, 14-Feb-2017.
%% References
% References : "\\203.250.77.113\Source codes\Libraries\[Last version]PHM toolbox\# References"
% "Time-varying and multiresolution envelope analysis and discriminative feature analysis for bearing fault diagnosis"

alpha=(Nr/Nw)*sqrt(-2*log(k));