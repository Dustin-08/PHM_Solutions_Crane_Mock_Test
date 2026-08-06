function map=getsommap(weights, feature)

maprows=size(weights,2);
mapcols=size(weights,3);
map=zeros(maprows,mapcols);
feature=feature(:);

for i=1:maprows
    for j=1:mapcols
        map(i,j)=sum(feature.*weights(:,i,j));
    end
end