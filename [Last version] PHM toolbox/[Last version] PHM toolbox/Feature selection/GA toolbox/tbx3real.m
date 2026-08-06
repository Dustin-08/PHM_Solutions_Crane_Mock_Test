% ToolBoX function to define parameters for optimization of real variables
%
% This function defines parameters for the optimization of real valued 
% variables inside the individuals.
%
% Syntax:  GEAOPT = tbx3real
%
% Input parameter:
%    no input parameters
%
% Output parameter:
%    GEAOPT    - Structure with newly defined options
%
% See also: geamain2, geaoptset, tbx3bin, tbx3int

% Author:   Hartmut Pohlheim
% History:  29.10.1999  file created


function GEAOPT = tbx3real


% Set function specific parameters
   GEAOPT = geaoptset(  'Recombination.Name',  {'recdis', 'recdis', 'reclin'} ...   % Define the recombination function
                      , 'Mutation.Name',       {'mutreal'} ...   % Define the real valued mutation function
                      , 'Mutation.Range',      [0.1, 0.03, 0.01, 0.003, 0.001, 0.0003] ...  %  Predefine some mutation ranges if using multiple subpopulation                
                      , 'Mutation.Precision',  12         ...   % Use this precision for all subpopulations  
                      , 'VariableFormat',      0          ...   % Use real valued variables 
                     );


% End of function

