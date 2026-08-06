function [dsignal, t, dfs]=dsampling(signal, fs, r)
%% 다운샘플링 함수
%% input
% signal : 입력신호 
% fs : 샘플링 주파수
% r : 다운 샘플링 율
%% output
% dsignal : 다운샘플링된 신호
% t : 다운샘플링된 신호의 time sequence
% dfs : 다운샘플링된 신호의 샘플링 주파수


dsignal=decimate(signal,r); % decimate함수를 이용한 다운샘플링
dfs=fs/r; % 다운샘플링후 샘플링 율
dlen=length(dsignal)/dfs; % 다운샘플링 후 신호 길이
t=(0:1/dfs:dlen); % 다운샘플링 후 time sequence
t=t(1:length(dsignal));