% DEMO function for multiobjective optimization including many examples
%
% This function provides an example for using the GEATbx for 
% multiobjective optimization.
% Here is the entry point for multi-objective optimization. 
% All the relevant parameters for MO problems are defined here. 
% Additionally, nearly all of the MO example functions of the GEATbx
% can be executed by this demo function including constrained
% functions and function with goals.
% At the end of the optimization the PARETO front of the found 
% best solutions is visualized (using plotmop).
% 
% Syntax:  demomop(OptVariant, FunVariant)
%
% Input parameter:
%    OptVariant - Scalar indicating the used optimization method
%                  1: globally oriented optimization with multiple subpops
%                  2: globally oriented optimization with 1 subpop (panmictic)
%                  3: locally oriented optimization
%                  if omitted or NaN, 1 is assumed
%
%    FunVariant - String indicating the used MO-function
%                  if omitted or NaN, a menu will be shown with the 
%                  possible options
%
% Output parameter:
%    no output parameter
%
% See also: geaoptset, geamain2, mobj*

% Author:   Hartmut Pohlheim
% History:  18.05.1999  file created
%           05.05.2002  options reworked
%                       inclusion of further MO functions
%                       selection of objfun from menu
%           08.01.2006  added assessment of best individuals at the end 
%                       of the optimization (objective value calculation, 
%                       fitness values, plot of PARETO front)
%           01.07.2006  added mobjbelegundu and mobjkita as examples
%           04.11.2006  use of tbx3moo1 for standard MO parameters


function [xnew, GeaOpt] = demomop(OptVariant, FunVariant)

   % Check input
   if nargin < 1, OptVariant = []; end
   if isnan(OptVariant), OptVariant = []; end

   if nargin < 2, FunVariant = []; end
   if isnan(FunVariant), FunVariant = ''; end

   % Check value of OptVariant
   if isempty(OptVariant), OptVariant = 1; end
   if ~(any(OptVariant == (1:3))), OptVariant = 1; end
   % Get parameters for different optimization variants
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
      GeaOpt = tbx3real;    % mutation, recombination, variable format
      % Define special parameters
      GeaOpt = geaoptset( GeaOpt ...
                         , 'NumberSubpopulation',        1 ...        % Number of subpopulation
                         , 'NumberIndividuals',         [200] ...     % Number of individuals per subpopulation
                         , 'Mutation.Range',            [1e-2] ...    % mutation range
                         , 'Mutation.Precision',        [24] ...      % mutation precision
                        );
   elseif OptVariant == 3,
      % Get default parameters for real variables (locally oriented)
      GeaOpt = tbx3es1;    % mutation, recombination, variable format, selection
   end


   % Define objective function to use and the respective parameters
   %#function mobjfonseca1 mobjfonseca2
   % name of objfun, number of variables, number of objectives, goals
   ObjFunStrings = { 'mobjfonseca1',     2,  NaN,  [.97, .7]   ...
                   ; 'mobjfonseca2',     3,  NaN,  [.23, .92]  ...
                   ; 'mobjdtlz1',        7,    3,  [Inf, Inf] ...
                   ; 'mobjdtlz2',        7,    3,  [Inf, Inf] ...
                   ; 'mobjdtlz3',        7,    3,  [Inf, Inf] ...
                   ; 'mobjquagliarella', 2,    2,  [Inf, Inf] ...
                   ; 'mobjsoland',       2,    2,  geaobjpara('mobjsoland',      [16]) ...
                   ; 'mobjcantilever',   2,    3,  geaobjpara('mobjcantilever',  [16]) ...
                   ; 'mobjdebconstr',    2,    4,  geaobjpara('mobjdebconstr',   [16]) ...
                   ; 'mobjbahinconstr',  2,    5,  geaobjpara('mobjbahinconstr', [16]) ...
                   ; 'mobjbelegundu',    2,    5,  geaobjpara('mobjbelegundu',   [16]) ...
                   ; 'mobjkita',         2,    5,  geaobjpara('mobjkita',        [16]) ...
                   };

   % Check for input parameter defining number of function to use, otherwise present menu
   if isempty(FunVariant),
      ObjFunNames = {};
      % Menu text of function names can be created automatically (the objective functions know their descriptive name)
      for iname = 1:size(ObjFunStrings,1),
         CurObjFunName = geaobjpara(ObjFunStrings{iname,1}, [2, ObjFunStrings{iname,2}]);
         if isnan(ObjFunStrings{iname,4}), CurGoals = ''; 
         else CurGoals = sprintf(',   goals: %s', prprintf(ObjFunStrings{iname,4})); end
         ObjFunNames = [ObjFunNames; {sprintf(' %s   (%s, %3d var%s)', CurObjFunName, ...
                                               ObjFunStrings{iname,1}, ObjFunStrings{iname,2}, CurGoals)}];
      end
      HeaderFunString = 'Please select an objective function';
      FunVariant = menutext(HeaderFunString, ObjFunNames);
   end;
   objfun = ObjFunStrings{FunVariant,1};

   % Get variable boundaries from objective function
   VLUB = geaobjpara(objfun, [1 ObjFunStrings{FunVariant,2}]);

   % Get MOO parameters from toolbox function and set some others directly
   % Switches on the multi-objective ranking and the visualization of the pareto front
   % Additionally some visualization options are set
   GeaOpt = geaoptset( GeaOpt , tbx3moo1 ...
                      , 'System.ObjFunGoals',  ObjFunStrings{FunVariant,4} ...
                      , 'Selection.GenerationGap',  0.5 ...
                      , 'Output.TextInterval',      10 ...       % Text output every xx generations
                      , 'Output.GrafikInterval',    20 ...       % Grafic results every 10 generations
                     );

   % termination criteria with their options
   GeaOpt = geaoptset( GeaOpt ...
                      , 'Termination.Method',         [1 ] ...   % Termination method: use max gen and max time
                      , 'Termination.MaxGenerations', 400  ...   % Terminate after xx generations
                     );

   % Call main function for optimization
   [xnew, GeaOpt] = geamain2(objfun, GeaOpt, VLUB);


   % Assessment of return population (best individuals)

   % To get multiple solutions at the end of the optimization, you take the 
   % return parameters of geamain2
   % xnew is an array of the size of the population with the best solutions found. 
   % xnew(1,:) is the first (and probably best) individual, xnew(2,:) 
   % the second one and so on. All non-dominated solutions are at the beginning
   % of xnew.

   % To get the (multiple) objective values of these best individuals:
   % objfun is the 'Name of the Objective function'
   ObjV = feval(objfun, xnew);

   % To get the fitness values: handle population as one panmictic population
   % (NumSubPop [3rd para] is set to 1)
   RankOpt = [GeaOpt.Selection.Pressure; GeaOpt.Selection.RankingMethod; GeaOpt.Selection.RankingMultiobj]';
   [FitnV, RankMOV] = ranking(ObjV, RankOpt, 1, GeaOpt.System.ObjFunGoals);

   % To plot the pareto front of the "best" (mostly non-dominated) individuals
   plotmop(xnew, ObjV, RankMOV, sprintf('%s (Best indiv. at end of opt.)', GeaOpt.System.ObjFunFilename));


% End of script
