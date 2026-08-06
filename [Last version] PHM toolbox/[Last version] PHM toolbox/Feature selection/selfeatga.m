function [selected_features, idx, hist]=selfeatga(features,classes, objfun, nfeat, ntry)
%% input
% features : 특징 벡터들
% bestsol : feature_selection 함수에서 추출된 특징선택 정보
%% output
% selected_features : 선택된 특징벡터 행렬

if nargin <= 3
    bestsol = getsol(features,classes,objfun);
    selected_features=features(:,bestsol);
    idx=find(bestsol);
elseif nargin <=4
    ntry = 100;
    hist=gethist(features,classes,objfun,ntry);
    [~,idx]=sort(hist,'descend');
    selected_features=features(:,idx(1:nfeat));
    idx=idx(1:nfeat);
else
    hist=gethist(features,classes,objfun,ntry);
    [~,idx]=sort(hist,'descend');
    selected_features=features(:,idx(1:nfeat));
    idx=idx(1:nfeat);
end
