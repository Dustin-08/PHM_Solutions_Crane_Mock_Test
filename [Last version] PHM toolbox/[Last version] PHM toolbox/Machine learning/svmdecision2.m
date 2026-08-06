function [out,f] = svmdecision2(Xnew,svm_struct)
%% matlab 함수
% 출력에 결정값 f 를 추가함

%SVMDECISION Evaluates the SVM decision function

%   Copyright 2004-2012 The MathWorks, Inc.
%   $Revision: 1.1.12.6 $  $Date: 2012/05/03 23:57:05 $

sv = svm_struct.SupportVectors;
alphaHat = svm_struct.Alpha;
bias = svm_struct.Bias;
kfun = svm_struct.KernelFunction;
kfunargs = svm_struct.KernelFunctionArgs;

f = (feval(kfun,sv,Xnew,kfunargs{:})'*alphaHat(:)) + bias;
out = sign(f);
% points on the boundary are assigned to class 1
out(out==0) = 1;