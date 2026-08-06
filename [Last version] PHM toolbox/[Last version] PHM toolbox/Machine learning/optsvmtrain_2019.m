function svmStructs = optsvmtrain_2019(features, classes, filepath)
%% optimal train of SVM using grid search
%% %%%%% Input %%%%%
% features : feature voctors
% classes : labels of feature vectors
%% %%%%% output %%%%%
% svmStructs : Trained SVM structure
svmStructs=cell(max(classes),1);
classes=classes(:);
for i = 1:max(classes)
    label=classes==i; % i번째 클래스의 레이블정보를 추출하여 클래스 1로 정함
    label=~label+1; % 이외 클래스의 레이블정보를 추출함 클래스 2로 정함
    
    svmStructs{i} = fitcsvm(features,label,'OptimizeHyperparameters','auto',...
        'HyperparameterOptimizationOptions',struct('AcquisitionFunctionName',...
        'expected-improvement-plus'));
end

if nargin==3
    save(filepath,'svmStructs'); % 학습된 svm 모델들을 저장함
end