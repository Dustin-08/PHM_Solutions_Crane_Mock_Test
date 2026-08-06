function [y, x]=probdens(signal, precision)
%% 신호의 확률밀도함수를 계산하는 함수
%% input
% signal : 입력신호
% precision : 확률밀도함수의 정밀도
%% output
% x : 확률밀도함수의 x축 sequence (값)
% y : 확률밀도함수의 y축 sequence (크기)
x=min(signal):precision:max(signal);
y=pdf('normal',x,mean(signal),std(signal));