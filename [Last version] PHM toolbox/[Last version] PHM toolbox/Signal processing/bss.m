function[y1, y2]  = bss(x1, x2, win_num)

%% Envelope analysis
%% INPUT
% x1 : observation signal1(mixed signal)
% x2 : observation signal2(mixed signal)
% win_num : window size

%% OUTPUT
% y1 : recovered source1 
% y2 : recovered source2

%% REMARKS
% Copyright (C) Embedded System Lab., University of Ulsan - All Rights Reserved
% Unauthorized copying of this file, via any medium is strictly prohibited
% Proprietary and confidential

% Implemented by Daehyun Yun, 01-Aug-2017.

%% References
% References : "\\203.250.77.113\Source codes\Libraries\[Last version]PHM toolbox\# References"
% FROM BLIND SOURCE SEPARATION TO BLIND SOURCE CANCELLATION IN THE UNDERDETERMINED CASE: A NEW APPROACH BASED ON TIME-FREQUENCY ANALYSIS
%%

if length(x1)>length(x2)
    N = length(x2);
else
    N = length(x1);
end

Nd_win_num = floor(N/win_num);
N = Nd_win_num * win_num;

x1=x1(1:N);
x2=x2(1:N);
%optimizing size of observation

alpha = x1./x2; 
alpha = reshape(alpha,[win_num,N/win_num]); 
%Reshape the alpha value to calculate variance in window units 

varience = var(alpha);
alpha_mean = mean(alpha);

[c1_var_value, c1_var_whr] = min(varience);

c1 = alpha_mean(1,c1_var_whr);

varience(1,c1_var_whr) = inf;
%calculate the thing which is the smallest and save to c1

c2_if = abs(alpha_mean(1,:) - c1(1,:));

c2_if_var = varience(c2_if>0.1);

[c2_var_value,c2_var_whr] = min(c2_if_var);

c2 = alpha_mean(1,c2_var_whr);
%save to c2 which is the secondary.

y1 = x1 - c1*x2;
y2 = x1 - c2*x2;
