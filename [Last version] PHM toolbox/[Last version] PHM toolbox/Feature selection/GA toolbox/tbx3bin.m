% ToolBoX function to define parameters for optimization of binary variables
%
% This function defines parameters for the optimization of binary variables 
% inside the individuals.
%
% Syntax:  GEAOPT = tbx3bin
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


function GEAOPT = tbx3bin


% Set function specific parameters
   GEAOPT = geaoptset(  'VariableFormat',      4          ...    % Use binary variables 
                      , 'Recombination.Name',  {'recdprs'} ...   % Define the recombination function
                      , 'Mutation.Name',       {'mutbin'} ...    % Define the binary mutation function
                     );


% End of function

