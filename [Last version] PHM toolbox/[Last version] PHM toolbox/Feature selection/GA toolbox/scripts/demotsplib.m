% DEMO for optimizing 'TSP Library' examples
%
% This script provides an example for defining non-default parameters
% for an optimization. Here is the highest level entry point into the
% GEA Toolbox.
% This demo uses the geaoptions structure for option definition.
%
% Syntax:  demotsplib
%
% Input parameter:
%    no input parameter
%
% Output parameter:
%    no output parameter
%
% See also: tbx3real, tbx3comp, objtsplib, geaoptset, geamain2

% Author:   Hartmut Pohlheim
% History:  20.07.99    file created


   % Get default parameters for real variables and competition
   GeaOpt = geaoptset(tbx3perm);
   
   % Define special parameters
   GeaOpt = geaoptset( GeaOpt ...
                      , 'NumberSubpopulation',        6 ...        % Number of subpopulation
                      , 'NumberIndividuals',         [50] ...      % Number of individuals per subpopulation
                      , 'Output.TextInterval',        5 ...        % Text output every 5 generations
                      ...
                      , 'Selection.GenerationGap',    0.95  ...
                      ...   
                      , 'Output.GrafikInterval',      10 ...       % Grafic results every 10 generations
                      , 'Output.GrafikMethod',        [111111] ...   % Grafic method to use
                      , 'Output.GrafikStyle',         [514143] ...   % Grafic styles for specified methods
                      ...
                      , 'Output.StatePlotInterval',  10          ...
                      , 'Output.StatePlotFunction', 'plottsplib' ...
                      ...
                      , 'Termination.Method',         [1] ...    % Termination method to use
                      , 'Termination.MaxGen',         400 ...        % Terminate after xx generations
                      );

   % Define special parameters for saving results
   FileNameBase = 'test_tsplib';
   GeaOpt = geaoptset( GeaOpt ...
                      , 'Output.SaveTextInterval',     0 ...                    % Text to File every xx generations
                      , 'Output.SaveTextFilename',    [FileNameBase '.txt'] ... % Filename of result file, absolut or relative path may be included
                      , 'Output.SaveBinDataInterval',  0 ...                    % Binary Data to File every xx generations
                      , 'Output.SaveBinDataFilename', [FileNameBase '.mat'] ... % Filename of binary file, absolut or relative path may be included
                      );


   % Define objective function to use
   GeaOpt = geaoptset( GeaOpt , 'System.ObjFunFilename', 'objtsplib'); objfun = [];

   % Define global variables
   global TSPLIB_FILENAME;
   global TSPLIB_NAME;

   % Define the TSPLIB example to solve/Reset some variables
   TSPLIB_FILENAME = ''; TSPLIB_NAME = '';
   tsp_readlib(TSPLIB_FILENAME);

   % Set additional parameter
   GeaOpt = geaoptset( GeaOpt , 'System.ObjFunAddPara', {TSPLIB_NAME});

   % Get variable boundaries from objective function
   VLUB = geaobjpara(GeaOpt.System.ObjFunFilename, 1, GeaOpt.System.ObjFunAddPara)
   GeaOpt = geaoptset( GeaOpt , 'System.ObjFunVarBounds', VLUB); VLUB = [];

   % Call main GEA function
   [xnew, GeaOpt] = geamain2(objfun, GeaOpt, VLUB, []);


% End of script

