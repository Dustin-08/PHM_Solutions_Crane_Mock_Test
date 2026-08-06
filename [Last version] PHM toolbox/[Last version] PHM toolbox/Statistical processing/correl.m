function c=correl(signal1,signal2)
%% 상관계수를 계산하는 함수
%% input
% signal1: 입력신호 1
% signal2 : 입력신호 2
%% output
% c : 상관계수

signal1=signal1(:);
signal2=signal2(:);
c=corr(signal1,signal2);