function pcs = extpcs( features, fcoef, npc )
%%

% Principle components analysis(PCA)
% Input
% features : 특징들
% fcoef : PCA 모델 (MATLAB의 PCA 함수에 특징을 입력하여 추출할 수 있음, MATLAB pca() 함수 참조)
% npc : 주성분
% 출력
% pcs : 추출된 주성분
%%

pcs=features*fcoef; % 주성분 추출
pcs=pcs(:,1:npc); % npc 개의 주성분 추출
end