% ToolBoX function to define parameters for a silent optimization (minimal output on screen)
%
% This function defines parameters to exclude some of the textual information.
% In this way less textual output is shown during an optimization on the screen.
% This feature may be used for demonstrations, where all the details are not 
% necessary or disturb the user.
%
% The given configuration excludes all information except the essential one.
% Just the information on objective function and evolutionary options is 
% displayed at the beginning of the optimization. During the optimization
% only the generation and the objective value are displayed (and a large 
% display interval is defined here). At the end we get the usual summary 
% on the optimization results.
% If Output.TextExcludeHead is also set to 1, we only get the output during 
% optimization (generation and objective value) and the end of optimization results.
% This can be seen as the minimal output. 
% Afterwards is only no output by setting Output.TextInterval to 0 (see tbx3silent).
%
%
% Syntax:  GEAOPT = tbx3textless
%
% Input parameter:
%    no input parameters
%
% Output parameter:
%    GEAOPT    - Structure with newly defined options
%
% See also: tbx3output, tbx3silent, geamain2, geaoptset

% Author:   Hartmut Pohlheim
% History:  04.11.2006  file created


function GEAOPT = tbx3textless


% Set function specific parameters
   GEAOPT = geaoptset( 'Output.TextInterval',        100 ...    % Text output very seldom
                     ...   
                     , 'Output.TextExcludeHead',     0 ...       % Exclude header information completely
                     , 'Output.TextExcludePara',     1 ...       % Exclude output of additional parameters of objective function
                     ...   
                     , 'Output.TextExcludeInd',      1 ...       % Exclude best individual per generation
                     , 'Output.TextExcludeSub',      1 ...       % Exclude info on subpopulations
                     , 'Output.TextExcludeTerm',     1 ...       % Exclude info on termination criteria
                     , 'Output.TextExcludeTime',     1 ...       % Exclude info on calculation time
                     );


% End of function

