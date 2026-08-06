function [opt_C, opt_rs, avg_accuracy]=fastgridsearch(features, classes)
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

c_idx=randi([2 length(C_range)-1]);
rs_idx=randi([2 length(rs_range)-1]);

while 1
    for i=c_idx-1:c_idx+1
        for j=rs_idx-1:rs_idx+1
            if i>length(C_range) || i<1 || j>length(rs_range) || j<1 || avg_accuracy(i,j)>0
                continue;
            end
            C=2.^C_range(i);
            rs=2.^rs_range(j);
            avg_accuracy(i,j)=getAccuracy(features,classes,selection,C,rs); 
            fprintf(1, 'max_eval=%f, cc=%f, rs=%f\n', avg_accuracy(i,j), C, rs);
        end
    end
    [~,idx1]=max(avg_accuracy);
    [~,idx2]=max(max(avg_accuracy));
    
    if c_idx==idx1(idx2) && rs_idx==idx2
        break;
    end
    c_idx=idx1(idx2);
    rs_idx=idx2;
end

[X,Y]=meshgrid([1:length(rs_range)],[1:length(C_range)]);
figure, surface(X,Y,avg_accuracy);
view(3);
    
opt_C=2.^C_range(c_idx); % Optimal C 
opt_rs=2.^rs_range(rs_idx); % Optimal sigma
