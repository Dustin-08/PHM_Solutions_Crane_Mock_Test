% DEMO for optimizing standard objective functions
%
% This script provides an example for defining non-default parameters
% for an optimization. Here is the highest level entry point into the
% GEA Toolbox.
% This demo uses the geaoptions structure for option definition.
%
% Syntax:  demoobjfun
%
% Input parameter:
%    no input parameter
%
% Output parameter:
%    no output parameter
%
% See also: tbx3real, tbx3comp, objfun1, geaoptset, geamain2

% Author:   Hartmut Pohlheim
% History:  04.11.98    file created
%           xx.06.99    included new data calling from objfun
%           26.07.99    optimization variants included
%           14.10.99    options for innoculation added


   OptVariant = 2;

   % Get parameters
   if OptVariant == 1,
      % Get default parameters for real variables (globally oriented)
      GeaOpt = geaoptset(tbx3real, tbx3comp);    % mutation, recombination, variable format
      GeaOpt = geaoptset( GeaOpt ...
                         , 'NumberSubpopulation',        4 ...           % Number of subpopulation
                         , 'NumberIndividuals',         [25] ...         % Number of individuals per subpopulation
                         , 'Mutation.Range',            [0.1, 0.01, 0.001, 0.0001] ...    % mutation range
                         , 'Mutation.Precision',        [16] ...      % mutation precision
                        );
                         % , 'Recombination.Name',        {'recdis', 'reclinex'} ...      % recombination function

   elseif OptVariant == 2,
      % Get default parameters for real variables (globally oriented)
      GeaOpt = geaoptset(tbx3real, tbx3comp);    % mutation, recombination, variable format
      GeaOpt = geaoptset( GeaOpt ...
                         , 'NumberSubpopulation',        1 ...        % Number of subpopulation
                         , 'NumberIndividuals',         [100] ...     % Number of individuals per subpopulation
                         , 'Mutation.Range',            [1e-2] ...    % mutation range
                         , 'Mutation.Precision',        [24] ...      % mutation precision
                        );

   elseif OptVariant == 3,
      % Get default parameters for real variables (globally oriented)
      GeaOpt = geaoptset(tbx3es1);    % mutation, recombination, variable format, selection
   end

   
   % Define special parameters
   GeaOpt = geaoptset( GeaOpt ...
                      , 'Output.TextInterval',        5 ...        % Text output every 5 generations
                      ...   
                      , 'Output.GrafikInterval',      10 ...       % Grafic results every 10 generations
                      , 'Output.GrafikMethod',        [11100001] ...   % Grafic method to use
                      , 'Output.GrafikStyle',         [11414316] ...   % Grafic styles for specified methods
                      ...
                      , 'Termination.Method',         [1] ...    % Termination method to use
                      , 'Termination.MaxGen',         400 ...        % Terminate after xx generations
                      , 'Termination.MaxTime',        2 ...         % Terminate after xx minutes
                      );

   % Define objective function to use
   GeaOpt = geaoptset( GeaOpt , 'System.ObjFunFilename', 'objfun1'); objfun = [];
   % Set additional parameter
   GeaOpt = geaoptset( GeaOpt , 'System.ObjFunAddPara', {1,2});


   % Define special parameters for saving results
   FileNameBase = sprintf('res_beasv_%s_var_%d_01', GeaOpt.System.ObjFunFilename, OptVariant);
   GeaOpt = geaoptset( GeaOpt ...
                      , 'Output.SaveTextInterval',     5 ...                    % Text to File every xx generations
                      , 'Output.SaveTextFilename',    [FileNameBase '.txt'] ... % Filename of result file, absolut or relative path may be included
                      , 'Output.SaveBinDataInterval',  0 ...                    % Binary Data to File every xx generations
                      , 'Output.SaveBinDataFilename', [FileNameBase '.mat'] ... % Filename of binary file, absolut or relative path may be included
                      );

   PopInit = [];
   % Innoculation (initialization with existing individuals only useful with PopInit ~= empty
   UseDim = 5; 
   % PopInit = [1:UseDim; 100+[1:UseDim]; 50*[1:UseDim]]; 
   GeaOpt = geaoptset( GeaOpt ...
                      , 'Special.InitDo',             0    ...       % init
                      , 'Special.InitPresetKeep',     1    ...       % init
                      , 'Special.InitPresetRand',     .3   ...       % init
                      , 'Special.InitUniform',        .4   ...       % init
                      , 'Special.CollectBest.Interval',   0   ...       % Collect best individuals
                      , 'Special.CollectBest.Rate',       4   ...       % Collect best individuals
                      , 'Special.CollectBest.Compare',    1   ...       % Collect best individuals
                      , 'Special.CollectBest.WriteFile',  1   ...       % Collect best individuals
                      , 'Special.CollectBest.FileName',   [straddtime('CollectedIndividuals.txt')]   ...       % Collect best individuals
                      );

   % Get variable boundaries from objective function
   VLUB = geaobjpara(GeaOpt.System.ObjFunFilename, [1 UseDim], GeaOpt.System.ObjFunAddPara);
   GeaOpt = geaoptset( GeaOpt , 'System.ObjFunVarBounds', VLUB); VLUB = [];

   % Do a mesh plot of objective function
   % plotmesh(GeaOpt.System.ObjFunFilename, [-100,-100;100,100]);
   
   % Look at all the defined options
   % prprintf(GeaOpt)
   
   [xnew, GeaOpt] = geamain2(objfun, GeaOpt, VLUB, PopInit);


% End of script

