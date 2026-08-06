% ToolBoX function to define parameters for no textual and graphical output during an optimization
%
% This function defines parameters for a silent optimization. This means
% no textual or graphical output during an optimization on the screen.
%
% This feature can be used for many consecutive optimization runs, where 
% no output on screen is necessary (unsupervised optimization runs). An
% example is the comparison of different optimization algorithms or option
% settings for one or multiple objective functions.
%
% When using this feature, you must ensure the results are saved (during 
% optimization by the GEATbx or outside the provided GEATbx functions by 
% employing the return values).
%
% Syntax:  GEAOPT = tbx3silent
%
% Input parameter:
%    no input parameters
%
% Output parameter:
%    GEAOPT    - Structure with newly defined options
%
% See also: tbx3output, tbx3textless, geamain2, geaoptset

% Author:   Hartmut Pohlheim
% History:  04.11.2006  file created


function GEAOPT = tbx3silent


% Set function specific parameters
   GEAOPT = geaoptset( 'Output.TextInterval',        0 ...    % No text output
                     , 'Output.GrafikInterval',      0 ...    % No graphic results
                     );


% End of function

