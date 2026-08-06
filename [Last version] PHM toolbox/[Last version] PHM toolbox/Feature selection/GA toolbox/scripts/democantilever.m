% DEMO for multiobjective optimization of cantilever beam system
%
% This function provides an example for using the GEATbx for 
% multiobjective optimization.
% The Cantilever example is optimized, an multi-objective problem
% using Goals.
% 
% Syntax:  democantilever
%
% Input parameter:
%    no input prameter
%
% Output parameter:
%    xnew, GeaOpt - output parameter from geamain2, see there
%
% See also: mobjcantilever, demomop, demodebconstr, mobjdtlz1, mobj*, geaoptset, geamain2

% Author:   Hartmut Pohlheim
% History:  19.08.2004  file created (based on demomop)
%           08.05.2005  documentation extended
%           05.11.2006  help section extended
%                       added assessment of best individuals at end


function [xnew, GeaOpt] = democantilever

   % Get default parameters for real variables (globally oriented)
   % and define special parameters
   GeaOpt = geaoptset( tbx3real ...
                      , 'NumberSubpopulation',  5   ...     % Number of subpopulation
                      , 'NumberIndividuals',    40  ...     % Number of individuals per subpopulation
                     );

   % Define objective function
   ObjFun = 'mobjcantilever';

   % Get variable boundaries from objective function
   VLUB = geaobjpara(ObjFun, [1 2]);

   % Define the output options, Switch on the multi-objective ranking and the MO visualization
   GeaOpt = geaoptset( GeaOpt, tbx3moo1 ...
                      , 'Output.TextInterval',        5        ...           % Text output every xx generations
                      , 'System.ObjFunGoals',  geaobjpara(ObjFun, [16]) ...  % Get the goals from ObjFun
                     );


   % termination criteria with their options
   GeaOpt = geaoptset( GeaOpt ...
                      , 'Termination.Method',         [1 ]  ...   % Termination method: use max gen and max time
                      , 'Termination.MaxGenerations', 100   ...   % Terminate after xx generations
                     );

   % Call main function for optimization
   [xnew, GeaOpt] = geamain2(ObjFun, GeaOpt, VLUB);

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
