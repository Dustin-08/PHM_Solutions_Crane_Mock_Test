function c=covar(signal1,signal2)
%% covariance 계산함수
%% input
% signal1 : 입력신호 1
% signal2 : 입력신호 2
%% output
% c : covariance
C=cov(signal1,signal2);
c=C(1,2);