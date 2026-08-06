% ToolBoX function to define parameters for optimization of permutation variables
%
% This function defines parameters for the optimization of permutation 
% variables inside the individuals.
%
% Syntax:  GEAOPT = tbx3perm
%
% Input parameter:
%    no input parameters
%
% Output parameter:
%    GEAOPT    - Structure with newly defined options
%
% See also: geamain2, geaoptset

% Author:   Hartmut Pohlheim
% History:  20.07.99    file created


function GEAOPT = tbx3perm


% Set function specific parameters
   GEAOPT = geaoptset(  'VariableFormat',      5          ...   % Use permutation variables  
                      , 'Recombination.Name',  {'recgp'} ...    % Define the recombination function
                      , 'Mutation.Name',       {'mutswap', 'mutmove', 'mutinvert'} ...   % Define the mutation functions
                      , 'Mutation.Range',      [1.0, 0.5, 0.3, 0.3, 1.0, 0.5] ...        %  Predefine some mutation ranges if using multiple subpopulation                
                      , 'Mutation.Precision',  8         ...   % Use this precision for all subpopulations
                     );


% End of function

