% Demo for optimizing ROSENBROOK's valey (banana function) 2 using Evolution Strategy
%
% This script defines the parameters to optimize the function 
% ROSENBROOK's valey (banana function) 2.
% The used optimization algorithm is an Evolution Strategy (defined 
% in tbx3es1).
%
% Syntax:  demofun2
%
% Input parameter:
%    no input parameter
%
% Output parameter:
%    no output parameter
%
% See also: tbx3real, geamain2

% Author:   Hartmut Pohlheim
% History:  22.10.2000  file created
%           26.04.2006  help section updated

   % Get default parameters for real variables and local optimization with ES
   GeaOpt = tbx3es1;
   
   % Define special parameters
   GeaOpt = geaoptset( GeaOpt ...
                      , 'NumberSubpopulation',        1 ...        % Number of subpopulation
                      , 'NumberIndividuals',         [50] ...      % Number of individuals per subpopulation
                      , 'Output.TextInterval',        20 ...       % Text output every 20 generations
                      ...   
                      , 'Output.GrafikInterval',      50 ...       % Grafic results every 50 generations
                      , 'Output.GrafikMethod',        111111 ...   % Grafic method to use
                      , 'Output.GrafikStyle',         614144 ...   % Grafic styles for specified methods
                      ...
                      , 'Termination.Method',         [1 2] ...  % Termination method to use
                      , 'Termination.MaxGenerations', 3000 ...     % Terminate after xx generations
                      , 'Termination.MaxTime',        15 ...       % Terminate after xx minutes
                      );

   % Define special parameters for saving results
   FileNameBase = ' ';
   GeaOpt = geaoptset( GeaOpt ...
                      , 'Output.SaveTextInterval',     0 ...                    % Text to File every xx generations
                      , 'Output.SaveTextFilename',    [FileNameBase '.txt'] ... % Filename of result file, absolut or relative path may be included
                      , 'Output.SaveBinDataInterval',  0 ...                    % Binary Data to File every xx generations
                      , 'Output.SaveBinDataFilename', [FileNameBase '.mat'] ... % Filename of binary file, absolut or relative path may be included
                      );

   % Define objective function to use
   objfun = 'objfun2';

   % Get variable boundaries from objective function
   VLUB = geaobjpara(objfun, [1 5]);

   % Do a mesh plot of objective function
   % plotmesh(objfun, [-0.5,-0.5;1.5,1.5]);

   [xnew, GeaOpt] = geamain2(objfun, GeaOpt, VLUB);


% End of script

