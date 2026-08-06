function hist=gethist(features,classes,objfun,ntry)
%% input
% objfun : 유전알고리즘의 목적 함수
% classes : 특징벡터들의 클래스 레이블 정보
% features : 특징 벡터들
% ntry : 히스토그램을 만들기 위해 특징 선택 시도 회수
%% output
% hist : 특징선택 히스토그램

bestSol=zeros(ntry, size(features,2));

for i=1:ntry
%     sel=cvpartition(classes,'k',3);
    [bestSol(i,:)]=getsol(features,classes,objfun);
    fprintf(1,'Current try : %d\n', i);
end

hist=sum(bestSol);