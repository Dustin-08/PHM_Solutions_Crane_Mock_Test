function weights=somtrain(features, maprows, mapcols, lrate, nepoch, sigmaz)

% sigmaz=5;
% niter=7200;
% lrate=0.1;

tt=nepoch/log(sigmaz);

weights=zeros(length(features),maprows,mapcols);
dist=zeros(maprows,mapcols);
nodedist=zeros(maprows,mapcols);

ndata=size(features,1);

shuffidx=randperm(ndata);
shuffled_features=features(shuffidx,:);

ki=0;    
for n=1:nepoch
    avgloss=0;
    for di=1:ndata
        ki=ki+1;
        feature=shuffled_features(di,:)';
        for i=1:maprows
            for j=1:mapcols
                dist(i,j)=norm(feature-weights(:,i,j));
            end
        end
        [~,idx1]=(min(dist));
        [mval,idx2]=min(min(dist));
        idx1=idx1(idx2);
        for i=1:maprows
            for j=1:mapcols
                sigma=sigmaz*exp(-1/tt);
                nodedist(i,j)=exp(-((i-idx1).^2+(j-idx2).^2)/(2*sigma));
            end
        end

        for i=1:maprows
            for j=1:mapcols
                L=lrate*exp(-ki/tt);
                weights(:,i,j)=weights(:,i,j)+nodedist(i,j)*L*(feature-weights(:,i,j));
            end
        end
        avgloss=avgloss+mval;
    end
    avgloss=avgloss/ndata;
    fprintf(1,'epoch : %d, loss : %f\n',n, avgloss);
end