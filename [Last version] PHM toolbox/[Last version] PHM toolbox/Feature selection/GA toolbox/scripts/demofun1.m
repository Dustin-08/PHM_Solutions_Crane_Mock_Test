% DEMO for optimizing 'De Jong's function 1
%
% This script provides an example for defining non-default parameters
% for an optimization. Here is the highest level entry point into the
% GEA Toolbox.
%
% Syntax:  demofun1
%
% Input parameter:
%    no input parameter
%
% Output parameter:
%    no output parameter
%
% See also: tbx3real, tbx3comp, geamain2

% Author:   Hartmut Pohlheim
% History:  22.10.2000  file created


   % Get default parameters for real variables
   GeaOpt = tbx3real;
   
   % Define special parameters
   GeaOpt = geaoptset( GeaOpt ...
                      , 'NumberSubpopulation',        5 ...        % Number of subpopulation
                      , 'NumberIndividuals',         [50, 30, 20, 20, 10] ...        % Number of individuals per subpopulation
                      , 'Output.TextInterval',        5 ...        % Text output every 5 generations
                      ...   
                      , 'Output.GrafikInterval',      20 ...       % Grafic results every 10 generations
                      , 'Output.GrafikMethod',        111111 ...   % Grafic method to use
                      , 'Output.GrafikStyle',         614121 ...   % Grafic styles for specified methods
                      ...
                      , 'Termination.Method',         [1  ] ...    % Termination method(s) to use
                      , 'Termination.MaxGen',         500 ...      % Terminate after xx generations
                      , 'Termination.MaxTime',        1 ...        % Terminate after xx minutes
                      ...
                      , 'Competition.DivisionPressure', 1.5 ...
                      , 'Competition.Rate',           .4 ...
                      );

   % Define special parameters for saving results
   FileNameBase = 'Data_hpt_abc'; % 'D:\home\Data_test_loadsave_hp1';
   GeaOpt = geaoptset( GeaOpt ...
                      , 'Output.SaveTextInterval',     0 ...                    % Text to File every xx generations
                      , 'Output.SaveTextFilename',    [FileNameBase '.txt'] ... % Filename of result file, absolut or relative path may be included
                      , 'Output.SaveBinDataInterval',  0 ...                    % Binary Data to File every xx generations
                      , 'Output.SaveBinDataFilename', [FileNameBase '.mat'] ... % Filename of binary file, absolut or relative path may be included
                      );


   % Add parameters for competition between subpopulations
   GeaOpt = geaoptset( GeaOpt , tbx3comp);
   
   % Define objective function to use
   GeaOpt = geaoptset( GeaOpt , 'System.ObjFunFilename', 'objfun1');
   objfun = []; % 'objfun1';

   % Get variable boundaries from objective function
   VLUB = geaobjpara(GeaOpt.System.ObjFunFilename, [1 10]);
   GeaOpt = geaoptset( GeaOpt , 'System.ObjFunVarBounds', VLUB);
   VLUB = [];

   % Do a mesh plot of objective function
   % plotmesh(objfun, [-100,-100;100,100]);
   % Define a specific plot function for objective function specific visualization during optimization
   % GeaOpt = geaoptset( GeaOpt , 'Output.StatePlotFunction', 'plotobjfun', 'Output.StatePlotInterval', 10);

   % Start optimization
   [xnew, GeaOpt] = geamain2(objfun, GeaOpt, VLUB, []);


% End of script

