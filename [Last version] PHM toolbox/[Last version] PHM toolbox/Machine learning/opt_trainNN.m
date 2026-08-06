function [opt_net, opt_reg, nets, regs] = opt_trainNN(features, classes, trainRatio, valRatio, testRatio)

regs=(0:0.01:1);
nets=cell(length(regs),1);
c=1;
error=zeros(length(regs));
for j=0:0.01:1
    net = network( ...
        1, ...  % numInputs, number of inputs,
        1, ...  % numLayers, number of layers
        [1], ...  % biasConnect, numLayers-by-1 Boolean vector,
        [1], ...  % inputConnect, numLayers-by-numInputs Boolean matrix,
        [0], ...  % layerConnect, numLayers-by-numLayers Boolean matrix
        [1] ...  % outputConnect, 1-by-numLayers Boolean vector
        );
    net.layers{1}.transferFcn = 'tansig' ;
    net = configure(net,features', classes');       % transpose
    net.trainFcn = 'trainlm' ;
    
    net.performFcn = 'mse' ;
    net.performParam.regularization = j;
    
    net.divideFcn='dividerand';
    net.divideParam.trainRatio=trainRatio;
    net.divideParam.valRatio=valRatio;
    net.divideParam.testRatio=testRatio;
    
    nets{c} = train(net,features', classes');       % transpose
    Test_NN_Output=net(features');
    Test_NN_Output=Test_NN_Output(:);
    error(c)=sum((Test_NN_Output-classes).^2);
    c=c+1;
end
[~,result]=min(error);
opt_net=nets{result};
opt_reg=regs(result);
end