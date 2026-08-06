% DEMO for optimizing special Var2ObjV assignments
%
% This script provides an example for defining non-default parameters
% for an optimization. Here is the highest level entry point into the
% GEA Toolbox.
%
% Syntax:  demofunbb
%
% Input parameter:
%    no input parameter
%
% Output parameter:
%    no output parameter
%
% See also: tbx3real, tbx3comp, geamain2

% Author:   Hartmut Pohlheim
% History:  05.10.2002  file created


   % Get default parameters for real variables
   GeaOpt = tbx3real;
   
   % Define special parameters
   GeaOpt = geaoptset( GeaOpt ...
                      , 'NumberSubpopulation',        1 ...        % Number of subpopulation
                      , 'NumberIndividuals',         [30] ...      % Number of individuals per subpopulation
                      , 'Output.TextInterval',        5 ...        % Text output every 5 generations
                      ...   
                      , 'Output.GrafikInterval',      10 ...       % Grafic results every 10 generations
                      , 'Output.GrafikMethod',        111111 ...   % Grafic method to use
                      , 'Output.GrafikStyle',         614141 ...   % Grafic styles for specified methods
                      ...
                      , 'Termination.Method',         [1  ] ...    % Termination method(s) to use
                      , 'Termination.MaxGen',          30 ...      % Terminate after xx generations
                      ...
                      , 'Mutation.Range',      [0.03, 0.01, 0.003, 0.001, 0.0003] ...  %  Predefine some mutation ranges if using multiple subpopulation                
                      , 'Mutation.Precision',  20         ...   % Use this precision for all subpopulations  
                      ...
                      ... % , 'Competition.DivisionPressure', 1.5 ...
                      ... % , 'Competition.Rate',           .4 ...
                      ...  % Switch on the multi-objective ranking and the plotmop visualization (para is > 10)
                      , 'Selection.RankingMultiobj', 12 ...
                      , 'System.ObjFunGoals',  [125, 425] ...
                     );
                      
   % Define special parameters for saving results
   % FileNameBase = straddtime('Data_objfun168_abc_NoKomplXO');   % _NoKomplXO
   FileNameBase = straddtime('Data_objfun168_abc');
   GeaOpt = geaoptset( GeaOpt ...
                      , 'Output.SaveTextInterval',     1 ...                    % Text to File every xx generations
                      , 'Output.SaveTextFilename',    [FileNameBase '.txt'] ... % Filename of result file, absolut or relative path may be included
                      , 'Output.SaveBinDataInterval',  1 ...                    % Binary Data to File every xx generations
                      , 'Output.SaveBinDataFilename', [FileNameBase '.mat'] ... % Filename of binary file, absolut or relative path may be included
                      );


   % Add parameters for competition between subpopulations
   GeaOpt = geaoptset( GeaOpt , tbx3comp);
   
   % Define objective function to use
   GeaOpt = geaoptset( GeaOpt , 'System.ObjFunFilename', 'objfun168');
   objfun = []; % 'objfun168';

   % Get variable boundaries from objective function and set the Var2ObjV assignment
   VLUB = geaobjpara(GeaOpt.System.ObjFunFilename, [1 10]);
   GeaOpt = geaoptset( GeaOpt , 'System.ObjFunVarBounds', VLUB);
   
   % Set the Var2ObjV option parameter, take the respective array from the objective function
   % Here is the place to switch this experimental new feature on and off
   % just comment the line and the feature is off
   GeaOpt = geaoptset( GeaOpt , 'System.ObjFunVar2ObjV', geaobjpara(GeaOpt.System.ObjFunFilename, [21 size(VLUB,2)]));

   VLUB = [];

   % Do a mesh plot of objective function
   % plotmesh(objfun, [-100,-100;100,100]);

   % Start optimization
   [xnew, GEAOpt] = geamain2(objfun, GeaOpt, VLUB, []);
   Chrom = xnew;
   ObjV = feval(GeaOpt.System.ObjFunFilename, Chrom)
   RankOpt = [GEAOpt.Selection.Pressure; GEAOpt.Selection.RankingMethod; GEAOpt.Selection.RankingMultiobj]';
   [FitnV, RankMOV] = ranking(ObjV, RankOpt, 1, GEAOpt.System.ObjFunGoals);
   plotmop(Chrom, ObjV, RankMOV, sprintf('Result: %s (gen: %g)', GEAOpt.System.ObjFunFilename, GEAOpt.Run.Generation))
   save([FileNameBase, 'C_O_R.mat'], 'Chrom', 'ObjV', 'RankMOV');

% End of script

