% DEMO for optimizing 'Vehicle routing problems'
%
% Vehicle routing problems VRP are a special class of ordering/
% sequenzing/permutation/... optimization problems.
% Many different optimization algorithms exist, many of 
% them quicker than evolutionary algorithms. Nevertheless,
% some of the best results for a number of benchmark problems 
% were found using evolutionary algorithms. 
% Beside the benchmark problems (quite a few of them included here)
% exist many real-world problems, which can be assessed as VRP.
%
% This demo function provides an example of parameter settings for 
% this kind of permutation problem including the problem specific 
% visualization and data loading.
%
% Syntax:  demovrp
%
% Input parameter:
%    no input parameter
%
% Output parameter:
%    no output parameter
%
% See also: objvrp, plotvrp, vrpgetdata, tbx3perm, tbx3comp

% Author:   Hartmut Pohlheim
% History:  28.05.2005  file created


   % Get default parameters for permutation problems
   GeaOpt = geaoptset(tbx3perm, tbx3comp);
   
   % Define special parameters
   GeaOpt = geaoptset( GeaOpt ...
                      , 'NumberSubpopulation',        12 ...        % Number of subpopulation
                      , 'NumberIndividuals',         [300] ...      % Number of individuals per subpopulation
                      , 'Output.TextInterval',        5 ...        % Text output every 5 generations
                      ...
                      , 'Selection.GenerationGap',    0.95  ...
                      ...   
                      , 'Recombination.Name',  {'recgp', 'recpm'} ...    % Define the recombination function
                      , 'Mutation.Name',       {'mutswap', 'mutswap', 'mutmove', 'mutmove', 'mutinvert', 'mutinvert'} ...   % Define the mutation functions
                      , 'Mutation.Range',      [  1.0 ] ...        %  Predefine some mutation ranges if using multiple subpopulation                
                      ... % ,        0.5,       0.5,       0.3,       1.0,         0.5
                      , 'Mutation.Precision',  10         ...   % Use this precision for all subpopulations
                      ...
                      , 'Competition.SubpopMinimum', 30  ...
                      ...   
                      , 'Output.GrafikInterval',      5 ...       % Grafic results every 10 generations
                      , 'Output.GrafikMethod',        [111111] ...   % Grafic method to use
                      , 'Output.GrafikStyle',         [514143] ...   % Grafic styles for specified methods
                      ...
                      , 'Output.StatePlotInterval',  1          ...
                      , 'Output.StatePlotFunction', 'plotvrp' ...
                      ...
                      , 'Termination.Method',         [1] ...    % Termination method to use
                      , 'Termination.MaxGen',         600 ...        % Terminate after xx generations
                      );


   % Define objective function to use
   GeaOpt = geaoptset( GeaOpt , 'System.ObjFunFilename', 'objvrp'); objfun = [];

   % Define the TSPLIB example to solve/Reset some variables
   % 'vrpnc1', 'sol25_r101'
   VRPFunName = 'vrpnc1';
   % VRPFunName = 'sol25_r101';

   % Get the problem specific VRP data
   VRPData = vrpgetdata(VRPFunName);

   % Define special parameters for saving results
   FileNameBase = straddtime(sprintf('vrp_%s', VRPData.FunName));
   GeaOpt = geaoptset( GeaOpt ...
                      , 'Output.SaveTextInterval',     1 ...                    % Text to File every xx generations
                      , 'Output.SaveTextFilename',    [FileNameBase '.txt'] ... % Filename of result file, absolut or relative path may be included
                      , 'Output.SaveBinDataInterval',  20 ...                    % Binary Data to File every xx generations
                      , 'Output.SaveBinDataFilename', [FileNameBase '.mat'] ... % Filename of binary file, absolut or relative path may be included
                      );

   % Set additional parameter
   GeaOpt = geaoptset( GeaOpt , 'System.ObjFunAddPara', {VRPData});

   % Get variable boundaries from objective function
   VLUB = geaobjpara(GeaOpt.System.ObjFunFilename, 1, GeaOpt.System.ObjFunAddPara{:})
   GeaOpt = geaoptset( GeaOpt , 'System.ObjFunVarBounds', VLUB); VLUB = [];

   % Call main GEA function
   [xnew, GeaOpt] = geamain2(objfun, GeaOpt, VLUB, []);


% End of script

