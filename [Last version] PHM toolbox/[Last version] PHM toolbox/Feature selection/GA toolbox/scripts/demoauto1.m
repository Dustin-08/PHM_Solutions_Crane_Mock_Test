% SCRipt for optimizing Lateral control auto 1
%
% This script provides an example for defining non-default parameters
% for an optimization. Here is the highest level entry point into the
% GEA Toolbox.
%
% Syntax:  demoauto1
%
% Input parameter:
%    no input parameter
%
% Output parameter:
%    no output parameter
%
% See also: objauto2

% Author:   Hartmut Pohlheim
% History:  06.05.1999  file created
%           11.01.2003  update for lecture


   % Get default parameters for real variables
   GeaOpt = tbx3real;
   
   % Define special parameters
   GeaOpt = geaoptset( GeaOpt ...
                      , 'NumberSubpopulation',        6 ...        % Number of subpopulation
                      , 'NumberIndividuals',         [50, 50, 50, 50] ...        % Number of individuals per subpopulation
                      , 'Output.TextInterval',        2 ...        % Text output every 2 generations
                      ...   
                      , 'Output.GrafikInterval',      5 ...        % Grafic results every 5 generations
                      , 'Output.GrafikMethod',        110101 ...   % Grafic method to use
                      , 'Output.GrafikStyle',         564641 ...   % Grafic styles for specified methods
                      ...
                      , 'Termination.Method',         [1] ...      % Termination method to use
                      , 'Termination.MaxGen',         100 ...      % Terminate after xx generations
                      );

   % Define objective function to use
   objfun = 'objauto2';
   GeaOpt = geaoptset( GeaOpt , 'System.ObjFunFilename', objfun);
   % Method = 12; Speed = 20; IniOff = .5; Noise = 0.002;
   Method = 12; Speed = 30; IniOff = 1.0; Noise = 0.002;

   % Define special parameters for saving results
   FileNameBase = straddtime(sprintf('res_%s_meth_%g_speed_%g_inioff_%g_03', objfun, Method, Speed, IniOff));
   GeaOpt = geaoptset( GeaOpt ...
                      , 'Output.SaveTextInterval',     1 ...                    % Text to File every xx generations
                      , 'Output.SaveTextFilename',    [FileNameBase '.txt'] ... % Filename of result file, absolut or relative path may be included
                      , 'Output.SaveBinDataInterval',  5 ...                    % Binary Data to File every xx generations
                      , 'Output.SaveBinDataFilename', [FileNameBase '.mat'] ... % Filename of binary file, absolut or relative path may be included
                      , 'Output.StatePlotInterval',    2 ...                    % state plot every xx generations
                      , 'Output.StatePlotFunction',   'plotauto' ...            % Filename of state plot function
                      );


   GeaOpt = geaoptset( GeaOpt , tbx3comp);
   
   % Get variable boundaries from objective function
   VLUB = geaobjpara(GeaOpt.System.ObjFunFilename, [NaN, 1], Method);
   GeaOpt = geaoptset( GeaOpt , 'System.ObjFunVarBounds', VLUB);

   % Set additional parameter
   GeaOpt = geaoptset( GeaOpt , 'System.ObjFunAddPara', {Method, Speed, IniOff, Noise});

   [xnew, GeaOpt] = geamain2(objfun, GeaOpt, VLUB, []);


% End of script

