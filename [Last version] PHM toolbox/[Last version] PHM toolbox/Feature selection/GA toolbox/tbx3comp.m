% ToolBoX function to define parameters for COMPeting subpopulation
%
% This function defines parameters for utilizing the regional model
% with multiple subpopulation and competition between these 
% subpopulation. 
% Most parameters are taken from the default parameter set in geaoptset.
%
% Syntax:  GEAOPT = tbx3comp
%
% Input parameter:
%    no input parameters
%
% Output parameter:
%    GEAOPT    - Structure with newly defined options
%
% See also: geamain2, geaoptset

% Author:   Hartmut Pohlheim
% History:  28.10.99    file created


function GEAOPT = tbx3comp


% Set function specific parameters
   GEAOPT = geaoptset(  'Competition.Do',      1 ...     % use Competition, the other paras of Competition are taken from default
                      , 'Migration.Do',        1 ...     % use Migration, the other paras of Migration are taken from default
                     );


% End of function

