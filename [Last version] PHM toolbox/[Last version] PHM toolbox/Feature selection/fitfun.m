function ObjVal = fitfun(Chrom, option, labels, trainFeatures)
%% objective function (fitness function)
%% %%%%%% input %%%%%%%
% Chrom : input chromosome set
% option : option for GA
% labels : labels of feature vectors
% trainFeatures : input feature vectors
%% %%%%%% output %%%%%%
% objval : Objective value (Fitness value)
%%
[Nind,~] = size(Chrom);
ObjVal=zeros(Nind,2);
for m=1:Nind
    if Chrom(m,:)==0
        ObjVal(m)=inf;
        continue;
    end
    x1=cell(max(labels),1);
    
    for i=1:max(labels)
        x1{i}=trainFeatures(labels==i,logical(Chrom(m,:)));
    end
    w=0;
    b=0;
    for j=1:max(labels)
        w=w+sum(sum(pdist2(x1{j},x1{j})))/(size(x1{j},1).^2);
    end
    w=w/(max(labels).^2);
    
    for j=1:max(labels)
        for k=(j+1):max(labels)
            b=b+sum(sum(pdist2(x1{j},x1{k})))/(size(x1{j},1)*size(x1{k},1));
        end
    end
    b=b/((max(labels)*(max(labels)-1))/2);
    ratio=w./b;
    
    ObjVal(m,1) = ratio;
end
