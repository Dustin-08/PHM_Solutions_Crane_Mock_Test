% ToolBoX function to define parameters for optimization, test of gui
%
% This function defines parameters for the optimization of real valued 
% variables inside the individuals. This defintion is specially used 
% for testing the GUI of the GEATbx.
%
% Syntax:  GEAOPT = tbx3guifun1
%
% Input parameter:
%    no input parameters
%
% Output parameter:
%    GEAOPT    - Structure with newly defined options
%
% See also: geamain2, geaoptset

% Author:   Hartmut Pohlheim
% History:  01.12.99    file created


function GeaOpt = tbx3guifun1

   % Get default parameters for real variables
   GeaOpt = geaoptset(tbx3real, tbx3comp);
   
   % Define special parameters
   GeaOpt = geaoptset( GeaOpt ...
                      , 'NumberSubpopulation',        5 ...        % Number of subpopulation
                      , 'NumberIndividuals',         [50, 30, 20, 20, 10] ...        % Number of individuals per subpopulation
                      , 'Output.TextInterval',        1 ...        % Text output every 5 generations
                      ...   
                      , 'Output.GrafikInterval',      10 ...       % Grafic results every 10 generations
                      , 'Output.GrafikMethod',        111111 ...   % Grafic method to use
                      , 'Output.GrafikStyle',         614143 ...   % Grafic styles for specified methods
                      ...
                      , 'Termination.Method',         [1 4] ...    % Termination method to use
                      , 'Termination.MaxGen',         100 ...      % Terminate after xx generations
                      , 'Termination.MaxTime',        10 ...        % Terminate after xx minutes
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
   % Get variable boundaries from objective function
   % Set additional parameter
   GeaOpt = geaoptset( GeaOpt , 'System.ObjFunFilename', 'objfun1');
   VLUB = geaobjpara(GeaOpt.System.ObjFunFilename, [1 10]);
   GeaOpt = geaoptset( GeaOpt , 'System.ObjFunVarBounds', VLUB ...
                              , 'System.ObjFunAddPara', {[1 2]} ...
                              , 'Gui.Use', 1);

   % Make sure, all parameters are set
   GeaOpt = geaoptset(GeaOpt);

% End of function

