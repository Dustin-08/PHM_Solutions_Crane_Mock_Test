function bestSol = getsol(features, classes, objfun)
classes=classes(:);
%% feature selection
%% %%%%% Input %%%%%
% objfun : objective function of genetic algorithm
% classes : label information of feature vectors
% features : input feature vectors
%% %%%%% output %%%%%
% bestSol : selected features information (binary information)

%% GA 도큐먼트 참조

GeaOpt = tbx3bin; % Binary-encoded chromosome
% Define special parameters
GeaOpt = geaoptset( GeaOpt ...
    , 'NumberSubpopulation',        1 ...        % Number of subpopulation
    , 'NumberIndividuals',         [300] ...     % Number of individuals per subpopulation
    , 'Output.TextInterval',        0 ...        % Text output every 5 generations
    , 'Termination.Method',       [1,5] ...
    , 'Termination.MaxGeneration', 100 ...
    , 'Termination.StdObjV',       0.01 ...
    , 'Mutation.rate',             0 ...
    );

GeaOpt = geaoptset( GeaOpt , 'System.ObjFunFilename', objfun);

% VLUB = geaobjpara(GeaOpt.System.ObjFunFilename, [1 size(features,2)]);
VLUB = repmat([0;1], [1 size(features,2)]); 
GeaOpt = geaoptset( GeaOpt , 'System.ObjFunVarBounds', VLUB);
VLUB = [];
[xnew] = geamain2(objfun, GeaOpt, VLUB,[], 0, classes, features);
bestSol=logical(xnew(1,:));