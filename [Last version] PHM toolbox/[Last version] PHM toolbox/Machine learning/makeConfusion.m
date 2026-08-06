function confmat=makeConfusion(results, labels)
%% confusion matrix calculation
%% %%%%% input %%%%%
% results : classification results
% labels : true labels of tested feature vectors
%% %%%%% output %%%%%
% confmat : confusion matrix
%%
results=results(:);
confmat=zeros(max(labels),max(labels));
for j=1:max(labels)
    for k=1:max(labels)
        confmat(j,k)=size(find(results(labels==k)==j),1);
    end
end