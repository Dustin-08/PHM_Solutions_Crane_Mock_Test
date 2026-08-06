% DEMO for optimizing integer variables/representation 1
%
% This script provides an example for defining parameters for the
% optimization of integer variables.
% Some of the parameters are loaded from the toolbox function
% tbx3int. Afterwards the mutation parameters are adapted.
%
% All other parameters are quite standard for a demo example:
% - visualization on screen every 20 generations
% - termination after a few hundred generations
% - use of multiple subpopulations and competition between them
% - optimization of one of the standard benchmark function: objfun6
%
% Saving of data to file (text and binary) is not switched on 
% by default (but may be easily changed below).
%
% Syntax:  demointeger1
%
% Input parameter:
%    no input parameter
%
% Output parameter:
%    no output parameter
%
% See also: demofun1, tbx3int, tbx3comp, geamain2, recdis, mutint

% Author:   Hartmut Pohlheim
% History:  16.07.2006  file created
%           31.07.2006  comments extended


   % Get default parameters for real variables
   GeaOpt = tbx3int;
   
   % Define special parameters
   GeaOpt = geaoptset( GeaOpt ...
                      , 'NumberSubpopulation',        4 ...        % Number of subpopulation
                      , 'NumberIndividuals',         [15, 25, 20, 20] ...        % Number of individuals per subpopulation
                      , 'Output.TextInterval',        5 ...        % Text output every 5 generations
                      ...   
                      , 'Output.GrafikInterval',      20 ...       % Grafic results every 10 generations
                      , 'Output.GrafikMethod',        111111 ...   % Grafic method to use
                      , 'Output.GrafikStyle',         614141 ...   % Grafic styles for specified methods
                      ...
                      , 'Termination.Method',         [1  ] ...    % Termination method(s) to use
                      , 'Termination.MaxGen',         300 ...      % Terminate after xx generations
                      ...
                      , 'Mutation.Range',  [1e-2, 1e-3, 1e-4, 1e-5] ...  %  mutation ranges if using multiple subpopulation                
                      , 'Mutation.Precision',         16 ...       % Use this mutation step precision for all subpopulation    
                      ...
                      , 'Competition.DivisionPressure', 1.5 ...
                      , 'Competition.Rate',           .4 ...
                      );

   % Define special parameters for saving results
   FileNameBase = 'Data_integer_';
   GeaOpt = geaoptset( GeaOpt ...
                      , 'Output.SaveTextInterval',     0 ...                    % Text to File every xx generations
                      , 'Output.SaveTextFilename',    [FileNameBase '.txt'] ... % Filename of result file, absolut or relative path may be included
                      , 'Output.SaveBinDataInterval',  0 ...                    % Binary Data to File every xx generations
                      , 'Output.SaveBinDataFilename', [FileNameBase '.mat'] ... % Filename of binary file, absolut or relative path may be included
                      );


   % Add parameters for competition between subpopulations
   GeaOpt = geaoptset( GeaOpt , tbx3comp);
   
   % Define objective function to use
   GeaOpt = geaoptset( GeaOpt , 'System.ObjFunFilename', 'objfun6');
   objfun = [];

   % Get variable boundaries from objective function
   VLUB = geaobjpara(GeaOpt.System.ObjFunFilename, [1 6]);
   GeaOpt = geaoptset( GeaOpt , 'System.ObjFunVarBounds', VLUB);
   VLUB = [];

   % Start optimization
   [xnew, GeaOpt] = geamain2(objfun, GeaOpt, VLUB, []);


% End of script

