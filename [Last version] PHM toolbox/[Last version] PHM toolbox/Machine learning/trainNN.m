function net = trainNN(features, classes)
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
    net = train(net,features', classes');       % transpose
end
