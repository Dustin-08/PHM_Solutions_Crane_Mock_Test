% DEMO for optimizing a simple binary function
%
% This script provides an example for defining non-default parameters
% for an optimization. Here is the highest level entry point into the
% GEA Toolbox.
%
% Syntax:  demobin1
%
% Input parameter:
%    no input parameter
%
% Output parameter:
%    no output parameter
%
% See also: tbx3real, tbx3comp, geamain2

% Author:   Hartmut Pohlheim
% History:  26.02.2002  file created


   % Get default parameters for binary variables
   GeaOpt = tbx3bin;

   % Define special parameters
   GeaOpt = geaoptset( GeaOpt ...
                      , 'NumberSubpopulation',        1 ...        % Number of subpopulation
                      , 'NumberIndividuals',         [100] ...     % Number of individuals per subpopulation
                      , 'Output.TextInterval',        5 ...        % Text output every 5 generations
                      ...
                      , 'Output.GrafikInterval',      10 ...       % Grafic results every 10 generations
                      , 'Output.GrafikMethod',        111100 ...   % Grafic method to use 
                      , 'Output.GrafikStyle',         614143 ...   % Grafic styles for specified methods
                      ...
                      , 'Termination.Method',         [1  ] ...    % Termination method(s) to use
                      , 'Termination.MaxGen',         100 ...       % Terminate after xx generations
                      , 'Termination.MaxTime',        1 ...         % Terminate after xx minutes
                      );

   % Define special parameters for saving results
   FileNameBase = 'test_loadsave';
   GeaOpt = geaoptset( GeaOpt ...
                      , 'Output.SaveTextInterval',     0 ...                    % Text to File every xx generations
                      , 'Output.SaveTextFilename',    [FileNameBase '.txt'] ... % Filename of result file, absolut or relative path may be included
                      , 'Output.SaveBinDataInterval',  0 ...                    % Binary Data to File every xx generations
                      , 'Output.SaveBinDataFilename', [FileNameBase '.mat'] ... % Filename of binary file, absolut or relative path may be included
                      );


   % Define objective function to use
   GeaOpt = geaoptset( GeaOpt , 'System.ObjFunFilename', 'objone1');
   objfun = []; % 'objfun1';


   % Get variable boundaries from objective function
   VLUB = geaobjpara(GeaOpt.System.ObjFunFilename, [1 40]);
   GeaOpt = geaoptset( GeaOpt , 'System.ObjFunVarBounds', VLUB);
   VLUB = [];

   % Start optimization
   [xnew, GeaOpt] = geamain2(objfun, GeaOpt, VLUB, []);


% End of script
