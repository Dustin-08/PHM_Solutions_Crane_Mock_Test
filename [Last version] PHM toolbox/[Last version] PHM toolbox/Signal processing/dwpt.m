function signal_tree=dwpt(signal,level,mfuncname)
%% %%%%% input %%%%%%
% signal : input signal
% level : level of DWPT
% mfuncname : mother function of DWPT
% opt_leve : level of output signal(sub-band)
% opt_band : The node number of output signal(sub-band)
%% %%%%% output %%%%%
% opt_signal : extracted signal
%% REMARKS
% Copyright (C) Embedded System Lab., University of Ulsan - All Rights Reserved
% Unauthorized copying of this file, via any medium is strictly prohibited
% Proprietary and confidential

% Implemented by Jaeyoung Kim, 30-Nov-2016.
% Modified by Jaeyoung Kim, 14-Feb-2017.
%%
T=wpdec(signal,level,mfuncname); %% Generating wavelet packet tree
signal_tree=cell(level+1,1); 
for i=0:level
    signal_tree{i+1}=cell(2^i,1); %Extract first sub-band signal from wavelet packet tree for each level
    for j=0:2^i-1
        signal_tree{i+1}{j+1} = wprcoef(T,[i, j]); %Extract each sub-band signal from wavelet packet tree for each level
    end
end

