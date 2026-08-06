function [opt_signal, opt_val, opt_level, opt_idx, eval_tree]=opt_stft(signal, fs, level, method, minmax)
%% stft의 최적 부대역 신호 추출
%% input
% signal : 입력 신호
% fs : 샘플링 주파수
% level : stft 레벨
% method : 평가 방법 선택 (0: kurtosis, 1: RMS, 2: impact factor)
% minmax : 최적 부대역의 평가값이 최대치인지 최소치인지를 결정 (0: 최소치, 1:최대치)
%% output
% opt_signal : 최적 부대역 신호
% opt_val : 최적 부대역 신호의 평가값
% opt_level : 최적 부대역 신호의 레벨
% opt_idx : 최적 부대역 신호의 노드 인덱스
% eval_tree : 평가값의 트리

%% 각 부대역신호의 평가값을 추출하여 평가값 트리 생성
eval_tree=cell(level+1,1);
fsignal=cell(level+1,1);
for i=1:level+1
    eval_tree{i}=cell(i,1);
    fsignal{i}=cell(i,1);
    for j=1:i
        fsignal{i}{j}=segsig(signal,fs,i,j); % i레벨 j번째 부대역 신호 분할
        if method==0
            eval_tree{i}{j}=kurtosis(fsignal{i}{j});  %% i레벨 j번째 부대역 신호의 kurtosis 계산
        elseif method==1
            eval_tree{i}{j}=rms(fsignal{i}{j});  %% i레벨 j번째 부대역 신호의 RMS 계산
        elseif method==2
            signal=fsignal{i}{j};
            maxval = max(abs(signal));
            s=mean(abs(signal));
            impfact = maxval / s;
            eval_tree{i}{j}=impfact; %% i레벨 j번째 부대역 신호의 impact factr 계산
        end
    end
end

%% 평가값 트리에서 평가값이 가장 큰(작은) 부대역신호의 레벨과 노드 인덱스 추출
opt_val=eval_tree{1}{1};
opt_level=1;
opt_idx=1;
for i=1:level+1
    idx=length(eval_tree{i});
    for j=1:idx
        val=eval_tree{i}{j};
        if minmax==0
            if opt_val>val
                opt_val=val;
                opt_level=i;
                opt_idx=j;
            end
        elseif minmax==1
            if opt_val<val
                opt_val=val;
                opt_level=i;
                opt_idx=j;
            end
        end
    end
end
opt_signal=fsignal{opt_level}{opt_idx}; % 추출된 레벨과 노드인덱스로 최적 부대역 신호 추출