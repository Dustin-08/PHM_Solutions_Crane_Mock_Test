% DEMO for testing the termination options
%
% This function provides an example for using some of the termination
% options in an optimization. 
% The options are defined by the structure method providing a 
% higher flexibility.
% 
% Change the variable TermVariant to one of the possible numbers and run the
% function. Different termination methods will be used. Over the run of the 
% optimization the value of the termination parameter can be checked on 
% the screen. After some runs you will get a feeling for the validity or 
% utility of the different options.
%
% Be carefull, use all the time one of the garanteed termination option
% as well (max generations and max time). Most of the other methods will 
% very often never terminate (depends on the problem and the used operator
% settings). And when the other options terminate, they very often terminate 
% too early. 
%
% However, play around with the methods and their settings, change the 
% objective function (standard is 'objfun1') or change other parameters. At
% the end you will know, which of the termination methods is suited best 
% for your problem at hand.
%
% Syntax:  demoterm(OptVariant, TermVariant)
%
% Input parameter:
%    OptVariant  - Scalar indicating the used optimization method
%                  1: globally oriented optimization
%                  2: locally oriented optimization
%                  if omitted or NaN, a menu will be shown with the 
%                  possible options
%
%    TermVariant - Scalar indicating the used termination method
%                  if omitted or NaN, a menu will be shown with the 
%                  possible options
%
% Output parameter:
%    no output parameter
%
% See also: geaoptset, geamain2, terminat

% Author:   Hartmut Pohlheim
% History:  04.05.99    file created
%           05.05.99    menu and input parameters added


function [xnew, GeaOpt] = demoterm(OptVariant, TermVariant)


   AddPara = [];

% Check input
   if nargin < 1, OptVariant = []; end
   if isnan(OptVariant), OptVariant = []; end

   if nargin < 2, TermVariant = []; end
   if isnan(TermVariant), TermVariant = []; end

% Here are multiple variants of optimization method with their 
% corrsponding parameters are defined
   if isempty(OptVariant),
      OptVariant = menutext('Please select the optimization method to use!' ...
                           , '1: Globally oriented optimization (multiple subpops)' ...
                           , '2: Locally oriented optimization'  ...
                           , '3: Globally oriented optimization with small steps (1 subpop)' ...
                           , '4: Globally oriented integer optimization' ...
                           );
   end

   % Check value of TermVariant
   if ~(any(OptVariant == (1:4))), OptVariant = 1; end
   
   % Get parameters
   if OptVariant == 1,
      % Get default parameters for real variables (globally oriented)
      GeaOpt = tbx3real;    % mutation, recombination, variable format
   
      % Define special parameters
      GeaOpt = geaoptset( GeaOpt ...
                         , 'NumberSubpopulation',        5 ...           % Number of subpopulation
                         , 'NumberIndividuals',         [50, 30, 30, 40, 50] ...     % Number of individuals per subpopulation
                        );

   elseif OptVariant == 2,
      % Get default parameters for real variables (globally oriented)
      GeaOpt = tbx3es1;    % mutation, recombination, variable format, selection


   elseif OptVariant == 3,
      % Get default parameters for real variables (globally oriented)
      GeaOpt = tbx3real;    % mutation, recombination, variable format
   
      % Define special parameters
      GeaOpt = geaoptset( GeaOpt ...
                         , 'NumberSubpopulation',        1 ...        % Number of subpopulation
                         , 'NumberIndividuals',         [100] ...     % Number of individuals per subpopulation
                         , 'Mutation.Range',            [1e-2] ...    % mutation range
                         , 'Mutation.Precision',        [24] ...      % mutation precision
                        );

   elseif OptVariant == 4,
      % Get default parameters for real variables (globally oriented)
      GeaOpt = tbx3int;    % mutation, recombination, variable format
   
      % Define special parameters
      GeaOpt = geaoptset( GeaOpt ...
                         , 'NumberSubpopulation',        2 ...        % Number of subpopulation
                         , 'NumberIndividuals',         [50] ...     % Number of individuals per subpopulation
                         , 'Mutation.Range',            [1e-1, 1e-2] ...    % mutation range
                        );

   end


% Define objective function to use and the standard mutation values
   objfun = 'objfun6';
   GeaOpt = geaoptset( GeaOpt , 'System.ObjFunFilename', objfun);


% Define the output options, path and name of result data files
   FileNameBase = ['scr2term_fun1_1'];
   GeaOpt = geaoptset( GeaOpt ...
                      , 'Output.TextInterval',        5 ...           % Text output every 5 generations
                      ...   
                      , 'Output.GrafikInterval',      20 ...          % Grafic results every 10 generations
                      , 'Output.GrafikMethod',        111111 ...      % Grafic method to use
                      , 'Output.GrafikStyle',         614144 ...      % Grafic styles for specified methods
                      ...
                      , 'Output.SaveTextInterval',     0 ...                    % Text to File every xx generations
                      , 'Output.SaveTextFilename',    [FileNameBase '.txt'] ... % Filename of result file, absolut or relative path may be included
                      , 'Output.SaveBinDataInterval',  0 ...                   % Binary Data to File every xx generations
                      , 'Output.SaveBinDataFilename', [FileNameBase '.mat'] ... % Filename of binary file, absolut or relative path may be included
                     );

% Here are multiple variants of termination criteria with their 
% corrsponding parameters are defined
   if isempty(TermVariant),
      TermVariant = menutext('Please select the termination method to use!', ...
                             'Number of generations', 'Maximal time (in minutes)', 'Difference to global optimum', ...
                             'Difference between mean of last best objv and current best objv', 'Minimal std of all current objv', ...
                             'Difference between best and worst current objv', 'Phi: difference between mean of all current objv and best objv', ...
                             'Kappa, mean distance between all current individuals', 'Cluster criteria reached' ...
                            );
   end
   
   % Check value of TermVariant
   if ~(any(TermVariant == (1:9))), TermVariant = 2; end
   
   % Terminate for max generations
   if TermVariant == 1;  
      GeaOpt = geaoptset( GeaOpt ...
                         , 'Termination.Method',         [1] ...     % Termination method to use
                         , 'Termination.MaxGenerations', 600 ...     % Terminate after xx generations
                        );
                         
   % Terminate for max generations and max time
   elseif TermVariant == 2;
      GeaOpt = geaoptset( GeaOpt ...
                         , 'Termination.Method',         [1 2] ...   % Termination method: use max gen and max time
                         , 'Termination.MaxGenerations', 500   ...   % Terminate after xx generations
                         , 'Termination.MaxTime',        2.45  ...   % Maximal time (in minutes)
                        );

   % Terminate for (max gen and) difference to global optimum
   elseif TermVariant == 3;
      GeaOpt = geaoptset( GeaOpt ...
                         , 'Termination.Method',         [1 3] ...   % Termination method to use
                         , 'Termination.MaxGenerations', 500   ...   % Terminate after xx generations
                         , 'Termination.Diff2Optimum',   1e-1  ...   % Diff to global optimum
                         ...
                         , 'System.ObjFunMinimum', feval(GeaOpt.System.ObjFunFilename, [], 3) ...   % Define global optimum
                        );

   % Terminate for (max gen and) diff between mean of last best objv and current best objv
   elseif TermVariant == 4;
      GeaOpt = geaoptset( GeaOpt ...
                         , 'Termination.Method',         [1 4] ...   % Termination method to use
                         , 'Termination.MaxGenerations', 600   ...   % Terminate after xx generations
                         , 'Termination.RunningMean',    1e-1  ...   % diff between mean of last best objv and current best objv 
                        );

   % Terminate for (max gen and) standard derivation of all current objective values
   elseif TermVariant == 5;
      GeaOpt = geaoptset( GeaOpt ...
                         , 'Termination.Method',         [1 5] ...   % Termination method to use
                         , 'Termination.MaxGenerations', 600   ...   % Terminate after xx generations
                         , 'Termination.StdObjV',        10    ...   % minimal std of all current objv
                         ...
                         ...   % , 'NumberSubpopulation',        1     ...   % Number of subpopulation
                         ...   % , 'Mutation.Range',            [1e-2] ...   % mutation range
                        );

   % Terminate for (max gen and) diff between best and worst current objv
   elseif TermVariant == 6;
      GeaOpt = geaoptset( GeaOpt ...
                         , 'Termination.Method',         [1 6] ...   % Termination method to use
                         , 'Termination.MaxGenerations', 600   ...   % Terminate after xx generations
                         , 'Termination.GoodWorstObjV',  100   ...   % diff between best and worst current objv                  
                         ...
                         ...   % , 'NumberSubpopulation',        1     ...   % Number of subpopulation
                         ...   % , 'Mutation.Range',            [1e-2] ...   % mutation range
                        );

   % Terminate for (max gen and) phi, diff between mean of all current objv and best objv
   elseif TermVariant == 7,
      GeaOpt = geaoptset( GeaOpt ...
                         , 'Termination.Method',         [1 7] ...   % Termination method to use
                         , 'Termination.MaxGenerations', 600   ...   % Terminate after xx generations
                         , 'Termination.Phi',            1e-2  ...   % phi, diff between mean of all current objv and best objv  
                         ...
                         ...   % , 'NumberSubpopulation',        1     ...   % Number of subpopulation
                         ...   % , 'Mutation.Range',            [1e-2] ...   % mutation range
                        );

   % Terminate for (max gen and) kappa, mean distance between all current individuals
   elseif TermVariant == 8,
      GeaOpt = geaoptset( GeaOpt ...
                         , 'Termination.Method',         [1 8] ...   % Termination method to use
                         , 'Termination.MaxGenerations', 400   ...   % Terminate after xx generations
                         , 'Termination.Kappa',          1e-4  ...   % kappa, mean distance between all current individuals      
                        );

   % Terminate for (max gen and) kappa, mean distance between all current individuals
   elseif TermVariant == 9,
      GeaOpt = geaoptset( GeaOpt ...
                         , 'Termination.Method',         [1 9] ...   % Termination method to use
                         , 'Termination.MaxGenerations', 400   ...   % Terminate after xx generations
                         , 'Termination.Cluster',        1e-2  ...   % cluster criteria reached
                         , 'Output.GrafikInterval',      20 ...          % Grafic results every 10 generations
                         , 'Output.GrafikMethod',        111111001 ...      % Grafic method to use
                         , 'Output.GrafikStyle',         614144003 ...      % Grafic styles for specified methods
                         ...
                         ...   % , 'NumberSubpopulation',        1     ...   % Number of subpopulation
                        );
      objfun = 'objfletwell';
      GeaOpt = geaoptset( GeaOpt , 'System.ObjFunFilename', objfun);
      AddPara = 0;

   % This is just a depot of all options
   elseif TermVariant == NaN;
      GeaOpt = geaoptset( GeaOpt ...
                         , 'Termination.Method',         [1 2] ...   % Termination method to use
                         , 'Termination.MaxGenerations', 200   ...   % Terminate after xx generations
                         , 'Termination.MaxTime',        2.45  ...   % Maximal time (in minutes)
                         , 'Termination.Diff2Optimum',   1e-3  ...   % Diff to global optimum
                         , 'Termination.RunningMean',    1e-2  ...   % diff between mean of last best objv and current best objv 
                         , 'Termination.StdObjV',        1e-2  ...   % minimal std of all current objv                           
                         , 'Termination.GoodWorstObjV',  1e-3  ...   % diff between best and worst current objv                  
                         , 'Termination.Phi',            1e-6  ...   % phi, diff between mean of all current objv and best objv  
                         , 'Termination.Kappa',          1e-6  ...   % kappa, mean distance between all current individuals      
                         , 'Termination.Cluster',        1e-1  ...   % cluster criteria reached
                        );
   end
      

% Get variable boundaries from objective function and set additional parameter
   VLUB = feval(GeaOpt.System.ObjFunFilename, [NaN 1], AddPara);
   GeaOpt = geaoptset( GeaOpt , 'System.ObjFunVarBounds', VLUB ...
                              , 'System.ObjFunAddPara', AddPara);

% Call main function for optimization
   PopInit = [];
   [xnew, GeaOpt] = geamain2(objfun, GeaOpt, VLUB, PopInit);


% End of script
