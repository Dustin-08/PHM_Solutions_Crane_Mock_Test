function ObjVal = fitfun_outlier(Chrom, option, labels, trainFeatures)
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
try
for m=1:Nind
    if Chrom(m,:)==0
        ObjVal(m)=inf;
        continue;
    end
    x1=cell(max(labels),1);
    
    for i=1:max(labels)
        x1{i}=trainFeatures(labels==i,logical(Chrom(m,:)));
    end
    C_array=zeros(max(labels),1);
    Dc=zeros(max(labels),sum(Chrom(m,:)));
    oidx=cell(max(labels),1);
    for j=1:max(labels)
        d=pdist2(x1{j},x1{j});
        L=sum(d);
        [~,midx]=min(L);
        Dc(j,:)=x1{j}(midx,:);
        sorted_d=sort(d);
        max_d=sorted_d(4,:);
        y=gaussmf(max_d, [std(max_d),mean(max_d)]);
        oidx{j}=find(y>0.25 & max_d>mean(max_d));
        edist=pdist2(Dc(j,:),x1{j}(oidx{j},:));
        C_array(j)=max(edist);
    end
    C=max(C_array);
    
    S_array=zeros(max(labels),1);
    for j=1:max(labels)
        mdotd_array=zeros(max(labels)-j,1);
        for k=(j+1):max(labels)
            ctd=pdist2(Dc(j,:),x1{k});
            otd=pdist2(x1{j}(oidx{j},:),x1{k});
            mdctd=min(ctd);
            mdotd_array(k-j)=min(min(otd));
        end
        S_array(j)=min([mdctd,min(mdotd_array)]);
    end
    S=min(S_array);
    
    ObjVal(m,1) = C/S;
end
catch
    a=1;
end
