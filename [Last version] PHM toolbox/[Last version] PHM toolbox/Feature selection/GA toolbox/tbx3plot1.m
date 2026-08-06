% ToolBoX function to define parameters for grafical display options
%
% This function defines parameters for the display of results during 
% the optimization.
%
% Syntax:  GEAOPT = tbx3plot1
%
% Input parameter:
%    no input parameters
%
% Output parameter:
%    GEAOPT    - Structure with newly defined options
%
% See also: geamain2, geaoptset

% Author:   Hartmut Pohlheim
% History:  29.10.99    file created


function GEAOPT = tbx3plot1


% Set function specific parameters
   GEAOPT = geaoptset(  'Output.GrafikInterval',      5          ...    % Use binary variables 
                      , 'Output.GrafikMethod',    11010001 ...   % Define the recombination function
                      , 'Output.GrafikStyle',     15454413 ...    % Define the binary mutation function
                     );


% End of function

