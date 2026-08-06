% Demo for optimizing the double integrator (dynamic SL/SF system)
%
% This script provides an example for optimizing the example function double 
% integrator (objdopi). Additionally the function specific plot function is
% defined and used.
% If you want to optimize an dynamic Simulink/Stateflow system, this is 
% one example. Still simple, but it provides all parameters on the 
% optimization side.
%
% Syntax:  demodopi
%
% Input parameter:
%    no input parameter
%
% Output parameter:
%    no output parameter
%
% See also: objdopi, plotdopi, demoauto1, objauto2

% Author:   Hartmut Pohlheim
% History:  26.06.2004  file created (update from older scrdopi.m)


   % Get default parameters for real variables and add standard parameter for competing subpopulations
   GeaOpt = tbx3es1;
   % GeaOpt = geaoptset(GeaOpt, tbx3comp);
   
   % Define special parameters
   GeaOpt = geaoptset( GeaOpt ...
                      , 'NumberSubpopulation',        1 ...        % Number of subpopulation
                      , 'NumberIndividuals',          12 ...       % Number of individuals per subpopulation
                      , 'Output.TextInterval',        10 ...       % Text output every 2 generations
                      ...   
                      , 'Output.GrafikInterval',      20 ...       % Grafic results every 5 generations
                      , 'Output.GrafikMethod',        110101 ...   % Grafic method to use
                      , 'Output.GrafikStyle',         564641 ...   % Grafic styles for specified methods
                      ...
                      , 'Termination.Method',         [1] ...      % Termination method to use
                      , 'Termination.MaxGen',         800 ...      % Terminate after xx generations
                      );

   % Define objective function to use
   objfun = 'objdopi';
   GeaOpt = geaoptset(GeaOpt , 'System.ObjFunFilename', objfun);
   % Define parameters for objective function
   Method = 1;            % Simulation method inside objective function (1 and 12 are working at the moment)
   Tstart = 0; Tend = 2;   % Time boundaries of simulation

   % Define special parameters for saving results
   FileNameBase = straddtime(sprintf('res_%s_meth_%g_tstart_%g_tend_%g', objfun, Method, Tstart, Tend));
   GeaOpt = geaoptset( GeaOpt ...
                      , 'Output.SaveTextInterval',     0 ...                    % Text to File every xx generations
                      , 'Output.SaveTextFilename',    [FileNameBase '.txt'] ... % Filename of result file, absolut or relative path may be included
                      , 'Output.SaveBinDataInterval',  0 ...                    % Binary Data to File every xx generations
                      , 'Output.SaveBinDataFilename', [FileNameBase '.mat'] ... % Filename of binary file, absolut or relative path may be included
                      , 'Output.StatePlotInterval',    10 ...                    % state plot every xx generations
                      , 'Output.StatePlotFunction',   'plotdopi' ...            % Filename of state plot function
                      );

   % Get variable boundaries from objective function
   VLUB = geaobjpara(GeaOpt.System.ObjFunFilename, [NaN, 1], Method);
   GeaOpt = geaoptset(GeaOpt, 'System.ObjFunVarBounds', VLUB);

   % Set additional parameter
   GeaOpt = geaoptset(GeaOpt, 'System.ObjFunAddPara', {Method, Tstart, Tend});

   [xnew, GeaOpt] = geamain2(objfun, GeaOpt, VLUB, []);


% End of script