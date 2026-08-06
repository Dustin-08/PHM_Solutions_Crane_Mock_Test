function outclass = classification(svmStructs,sample, read_path)
%% Input
% svmStructs : 학습된 SVM 모델
% sample : 입력 특징
%% Output
% read_path : 저장된 SVM 모델을 불러오기 위한 경로

if nargin==3
    load(read_path); % 저장된 학습된 SVM 모델을 불러옴
end
decisions=zeros(length(svmStructs),size(sample,1));
for i=1:length(svmStructs)
    [~,decisions(i,:)]=svmclassify2(svmStructs(i),sample); %% SVM 모델을 이용하여 sample을 분류함
end
[~,outclass]=max(decisions); % SVM 분류 결과 결정값이 가장 높은 클래스를 분류결과로 출력함