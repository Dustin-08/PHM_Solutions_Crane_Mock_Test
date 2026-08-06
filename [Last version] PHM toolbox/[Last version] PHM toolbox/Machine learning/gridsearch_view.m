function [opt_C, opt_rs, avg_accuracy, fig]=gridsearch(features, classes)
%% Grid search
%% input
% features : training features
% classes : training classes
%% output
% opt_C : optimal C parameter
% opt_rs : optimal sigma parameter for RBF kernel
%% REMARKS
% Copyright (C) Embedded System Lab., University of Ulsan - All Rights Reserved
% Unauthorized copying of this file, via any medium is strictly prohibited
% Proprietary and confidential

% Implemented by Jaeyoung Kim <kjy7097@gmail.com>, 11-Mar-2017.

selection=cvpartition(classes,'KFold',3); % selection information for cross-validation
C_range=(-5:2:15); % Search range for C (box constraint)
rs_range=(-2:1:7); % Search range for sigma (RBF kernel)
avg_accuracy=zeros(length(C_range),length(rs_range)); %classification accuracies for each combination of C and sigma

cc=1;
for C=2.^C_range 
    rr=1;
    for rs=2.^rs_range
%         avg_accuracy(cc,rr)=getAccuracy(features,classes,selection,C,rs); 
        avg_accuracy(cc,rr)=getAccuracy(features,classes,selection,C,rs); 
        rr=rr+1;
        max_acc=max(max(avg_accuracy));
        fprintf(1, 'max_acc=%f, cc=%f, rs=%f\n', max_acc, C, rs);        
    end
    cc=cc+1;
end
[~,ind1]=max(avg_accuracy);
[~,ind2]=max(max(avg_accuracy));

opt_C=2.^C_range(ind1(ind2)); % Optimal C 
opt_rs=2.^rs_range(ind2); % Optimal sigma

fig = figure;
imagesc(avg_accuracy);
colormap('jet');
c_str=cell(1,1);
for i=1:length(C_range)
    c_str{i,1}=num2str(2.^C_range(i));
end
for i=1:length(rs_range)
    rs_str{i,1}=num2str(2.^rs_range(i));
end
yticklabels(c_str);
ylabel('C',  'FontSize',20, 'FontWeight' ,'bold', 'FontName', 'Times')
xticklabels(rs_str);
xlabel('\sigma',  'FontSize',20, 'FontWeight' ,'bold', 'FontName', 'Times')
set(gca, 'FontSize',15, 'FontWeight' ,'bold', 'FontName', 'Times');
