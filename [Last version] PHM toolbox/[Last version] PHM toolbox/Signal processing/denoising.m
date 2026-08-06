function x=denoising(signal, thlevel, t_type)
%% 노이즈 제거 함수
%% input
% signal : 입력신호
% thlevel : 노이즈 임계치
% t_type : 노이즈 제거 방법 (0 : soft thresholding, 1: hard thresholding)
%% output
% x : 노이즈가 제거된 신호

if t_type == 0
    x=wthresh(signal,'s', thlevel); % soft thresholding
elseif t_type == 1
    x=wthresh(signal,'h', thlevel); % hard threshoding
end