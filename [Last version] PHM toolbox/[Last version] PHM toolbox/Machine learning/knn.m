function outclass = knn(testData, trainingData,trainingClass, k)
%% input
% testData : 분류하기 위한 특징벡터들
% trainingData : 학습하기 위한 특징벡터들
% trainingClass : 학습 특징벡터들의 클래스 정보
% k : 분류 시 사용될 이웃한 특징벡터들의 개수
%% output
% outclass : 분류결과

ntestdata = size(testData, 1); % 테스트 데이터의 개수
ntrainingdata = size(trainingData, 1); % 학습 데이터의 개수
outclass=zeros(ntestdata,1); % 테스트 데이터의 분류결과
for i=1:ntestdata
    %% Step 1: Euclidean distance 
    R = repmat(testData(i,:), ntrainingdata,1);
    eudistance = sum((R - trainingData).^2,2);
    
    %% Step 2: k nearest neighbors
    [dist, euposition] = sort(eudistance,'ascend');
    
    %% Step 3: Classification
    knn_dist=zeros(k,1);
    for j=1:k
        knn_dist(j,1) = trainingClass(euposition(j,1),1);
    end
    outclass(i,1) = mode(knn_dist);       
end