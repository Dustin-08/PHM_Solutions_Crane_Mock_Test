function [svmStructs, avg_accuracy, fig, time] = optsvmtrain(features, classes, gird, filepath)
%% optimal train of SVM using grid search
%% %%%%% Input %%%%%
% features : feature voctors
% classes : labels of feature vectors
%% %%%%% output %%%%%
% svmStructs : Trained SVM structure
% t1=tic;
classes=classes(:);

optionss=statset('MaxIter', 1000000000);

%% 각 클래스별로 이진 분류 SVM을 학습시켜 Multiclass SVM을 학습함
for i=1:max(classes)
    label=classes==i; % i번째 클래스의 레이블정보를 추출하여 클래스 1로 정함
    label=~label+1; % 이외 클래스의 레이블정보를 추출함 클래스 2로 정함
    t2=tic;
    if strcmp(gird, '_fast')
        [C, rs,  avg_accuracy{i}]=fastgridsearch(features, label); % gridsearch를 통해 최적의 C와 sigma(rs) 파라미터를 설정함
    else
        [C, rs, avg_accuracy{i}]=gridsearch(features, label); % gridsearch를 통해 최적의 C와 sigma(rs) 파라미터를 설정함
    end
    time{i} = toc(t2);
%     et(i)=toc(t2); %gridsearch time
    
%     [C, rs, path, avg_accuracy{i}, fig{i}]=fastgridsearch(features, label); % gridsearch를 통해 최적의 C와 sigma(rs) 파라미터를 설정함
    svmStructs(i) = svmtrain(features,label, 'kernel_function','rbf', 'boxconstraint', C,'rbf_sigma',rs,'options',optionss); % svm 학습 (matlab svmtrain 함수 document 참조)
end
% fet=toc(t1); % svm time


if nargin==4
    save(filepath,'svmStructs'); % 학습된 svm 모델들을 저장함
end

