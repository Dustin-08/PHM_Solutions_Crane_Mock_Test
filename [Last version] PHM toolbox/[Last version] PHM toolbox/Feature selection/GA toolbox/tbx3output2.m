% ToolBoX function to define parameters for output on screen (visualization) 2
%
% This function defines parameters for the output during an optimization 
% on the screen (text output and graphical output).
%
% A selection of graphics is switched on and the useful visualization 
% styles are selected.
% Beside this, the textual output interval is defined (every 5 generations) 
% and the info on subpopulation positioning is excluded (not necessary for 
% first optimizations).
%
% Syntax:  GEAOPT = tbx3output
%
% Input parameter:
%    no input parameters
%
% Output parameter:
%    GEAOPT    - Structure with newly defined options
%
% See also: geamain2, geaoptset, tbx3real

% Author:   Hartmut Pohlheim
% History:  05.05.2002  file created


function GEAOPT = tbx3output2


% Set function specific parameters
   GEAOPT = geaoptset( 'Output.TextInterval',        5        ...      % Text output every 5 generations
                     , 'Output.TextExcludeSub',      1        ...      % exclude info on subpopulations
                     ...   
                     , 'Output.GrafikInterval',      10       ...      % Grafic results every 10 generations
                     , 'Output.GrafikMethod',        11010001 ...      % Grafic methods to use
                     , 'Output.GrafikStyle',         15452413 ...      % Grafic styles for specified methods
                     );


% End of function

