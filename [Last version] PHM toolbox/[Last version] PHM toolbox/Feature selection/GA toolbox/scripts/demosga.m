% DEMO for the Simple Genetic Algorithm
%
% This script demonstrates the implementation of the Simple Genetic
% Algorithm.
%
% Syntax:  demosga
%
% Input parameter:
%    no input parameter
%
% Output parameter:
%    no output parameter
%
% See also: demobin1, tbx3bin, tbx3steadyga, geamain2

% Author:   Hartmut Pohlheim
% History:  26.04.2006  file created


   % Get default parameters for real variables
   GeaOpt = tbx3sga;

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
                      );


   % Define objective function to use
   GeaOpt = geaoptset( GeaOpt , 'System.ObjFunFilename', 'objfun1');
   objfun = []; % 'objfun1';


   % Get variable boundaries from objective function
   VLUB = geaobjpara(GeaOpt.System.ObjFunFilename, [1 10]);
   GeaOpt = geaoptset( GeaOpt , 'System.ObjFunVarBounds', VLUB);
   VLUB = [];

   % Start optimization
   [xnew, GeaOpt] = geamain2(objfun, GeaOpt, VLUB, []);


% End of script
