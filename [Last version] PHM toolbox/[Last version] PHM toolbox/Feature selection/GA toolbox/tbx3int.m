% ToolBoX function to define parameters for optimization of integer variables
%
% This function defines parameters for the optimization of integer 
% variables inside the individuals. 
% Some or all of the 'integer' variables can be binary variables. 
% Binary variables are integer with boundaries of 0 and 1.
% When all variables are binary, please use tbx3bin.
%
% Syntax:  GEAOPT = tbx3int
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


function GEAOPT = tbx3int


% Set function specific parameters
   GEAOPT = geaoptset(  'VariableFormat',      2          ...   % Use integer variables 
                      , 'Recombination.Name',  {'recdis'} ...   % Define the recombination function
                      , 'Mutation.Name',       {'mutint'} ...   % Define the integer mutation function
                      , 'Mutation.Range',      [0.1, 0.03, 0.01, 0.003, 0.001, 0.0003] ...  %  Predefine some mutation ranges if using multiple subpopulation                
                      , 'Mutation.Precision',  16         ...   % Use this mutation step precision for all subpopulation    
                     );


% End of function

