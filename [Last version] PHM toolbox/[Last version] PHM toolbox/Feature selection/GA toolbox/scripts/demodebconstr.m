% DEMO for testing DEB's MO function
%
% This function optimizes DEBs multiobjective constrained function.
% All the parameters are defined for a globally oriented optimization
% using multiple subpopulations.
% The constraints of the function are handled by additional objectives, 
% see the objective function for more information.
% 
% Syntax:  demodebconstr
%
% Input parameter:
%    no input parameter
%
% Output parameter:
%    no output parameter
%
% See also: democantilever, mobjcantilever, demomop, mobjdtlz1, mobj*, geaoptset, geamain2

% Author:   Hartmut Pohlheim
% History:  10.04.2005  file created
%           05.11.2006  help section extended
%                       added assessment of best individuals at end


   % Get default parameters for real variables (globally oriented)
   GeaOpt = tbx3real;    % mutation, recombination, variable format
   % Define special parameters
   GeaOpt = geaoptset( GeaOpt ...
                      , 'NumberSubpopulation',  5   ...     % Number of subpopulation
                      , 'NumberIndividuals',    40  ...     % Number of individuals per subpopulation
                     );

   % Define objective function
   ObjFun = 'mobjdebconstr';

   % Get variable boundaries from objective function
   VLUB = geaobjpara(ObjFun, 1);

   % Define the output options, Switch on the multi-objective ranking and the MO visualization
   GeaOpt = geaoptset( GeaOpt, tbx3moo1 ...
                      , 'Output.TextInterval',        5        ...           % Text output every xx generations
                      , 'System.ObjFunGoals',  geaobjpara(ObjFun, [16]) ...  % Get the goals from objfun
                     );

   % termination criteria with their options
   GeaOpt = geaoptset( GeaOpt ...
                      , 'Termination.Method',         [1 ] ...   % Termination method: use max gen and max time
                      , 'Termination.MaxGenerations', 150   ...   % Terminate after xx generations
                     );

   % Call main function for optimization
   PopInit = [];
   [xnew, GeaOpt] = geamain2(ObjFun, GeaOpt, VLUB, PopInit);

   % Assessment of return population (best individuals)

   % To get the (multiple) objective values of the best individuals:
   ObjV = feval(GeaOpt.System.ObjFunFilename, xnew);

   % To get the fitness values: handle population as one panmictic population
   % (NumSubPop [3rd para] is set to 1)
   RankOpt = [GeaOpt.Selection.Pressure; GeaOpt.Selection.RankingMethod; GeaOpt.Selection.RankingMultiobj]';
   [FitnV, RankMOV] = ranking(ObjV, RankOpt, 1, GeaOpt.System.ObjFunGoals);

   % To plot the pareto front of the "best" (mostly non-dominated) individuals
   plotmop(xnew, ObjV, RankMOV, sprintf('%s (Best indiv. at end of opt.)', GeaOpt.System.ObjFunFilename));

% End of script
