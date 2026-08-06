% ToolBoX function to define parameters for the Simple Genetic Algorithm (SGA)
%
% This function defines parameters for the Simple Genetic Algorithm (SGA).
% This includes the internal use of a binary representation (the variables can 
% be real, integer or binary). 
% Recombination/Crossover uses one-point crossover and a crossover probability 
% of 0.7.
% For mutation binary mutation must be used (because of the internal binary 
% representation). The mutation probability (default is 1) is internally 
% divided by the number of (internal) variables, thus only one binary value 
% per individual is mutated. Change this value appropriate. The used internal
% value is presented on the screen at the beginning of the optimization.
% Just one panmictic population is used.
% The generation gap of selection is set to 1, thus no generation gap. Implicitly
% the recombination/crossover probability of 0.7 works as an generation gap or
% as elitist selection.
% When using this parameter function, please compare to the other (more powerful)
% parameter setting functions (tbx3real, tbx3comp, ...).
% This parameter setting function is mainly provided to show you how to define 
% even the first and most simple genetic algorithm using the GEATbx. Can be used 
% for comparison or whatever you want. But these parameters are not recommended 
% for productive use - in nearly every real-world case they are not good.
%
% Syntax:  GEAOPT = tbx3sga
%
% Input parameter:
%    no input parameters
%
% Output parameter:
%    GEAOPT    - Structure with newly defined options
%
% See also: geamain2, geaoptset, tbx3bin, tbx3real, tbx3comp

% Author:   Hartmut Pohlheim
% History:  26.06.2004  file created


function GEAOPT = tbx3sga


% Set function specific parameters
   GEAOPT = geaoptset(  'VariableFormat',      1          ...     % Use a binary representation internally
                      , 'Recombination.Name',  {'recsp'}  ...     % Define the recombination function ['recsp']
                      , 'Recombination.Rate',  0.7        ...     % Define the recombination/crossover probability [0.7]
                      , 'Mutation.Name',       {'mutbin'} ...     % Define the mutation function, must be binary ['mutbin']
                      , 'Mutation.Rate',       1          ...     % Define the mutation probability [1(/n)]
                      , 'NumberSubpopulation', 1          ...     % Number of subpopulation, just one [1]
                      , 'NumberIndividuals',   100        ...     % Number of individuals in population [100]
                      , 'Selection.GenerationGap', 1      ...     % Define generation gap (for elitist selection) [1]
                     );


% End of function

