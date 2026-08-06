function acc = getAccuracy(features, classes,selection, C,rs)
%% SVM의 분류 정확도 계산 함수
%% input
% features : 학습 및 분류될 특징벡터들
% classes : 학습 및 분류될 특징벡터들의 실제 클래스 정보 (참값, ground truth)
% selection : 특징벡터들을 학습과 분류로 나누기위한 정보
% C : SVM의 C 파라메터
% rs : SVM의 sigma 파라메터
%% output
% acc : 분류 정확도

nfold=3;
confmat=zeros(max(classes),max(classes),nfold);
accuracy=zeros(max(classes),nfold);
total_accuracy=zeros(nfold,1);
optionss=statset('MaxIter', 1000000000);
for n=1:nfold
    %% 특징벡터들을 학습과 분류 데이터로 나눔
    trainClasses=classes(selection.training(n), :);
    trainFeatures=features(selection.training(n), :);
    testClasses=classes(selection.test(n), :);
    testFeatures=features(selection.test(n), :);
    
    %% SVM 학습 및 분류 과정
    svmStruct = svmtrain(trainFeatures,trainClasses,'kernel_function','rbf', 'boxconstraint', C,'rbf_sigma',rs,'options',optionss); % SVM 학습
    
    [R, F]=svmclassify2(svmStruct,testFeatures); % SVM 분류
%     for j=1:max(testClasses)
%         for k=1:max(testClasses)
%             confmat(j,k,n)=size(find(R(testClasses==k)==j),1); %% Confusion matrix 생성
%         end
%     end
%     
%     %% Confusion matrix로 분류 정확도를 계산하는 과정
%     t=sum(reshape(confmat(:,:,n),max(testClasses),max(testClasses)),2);
%     d=diag(reshape(confmat(:,:,n),max(testClasses),max(testClasses)));
%     accuracy(:,n)=d./t;

%     total=sum(t);
%     sumd=sum(d);
%     total_accuracy(n)=sumd/total;
    total_accuracy(n)=mean(F(F>0))-mean(F(F<0));
end
acc=mean(total_accuracy);

