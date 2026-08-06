% ToolBoX function to define parameters for locally oriented optimization of real variables
%
% This function defines parameters for the locally oriented 
% optimization of real valued variables inside the individuals.
% This proedure uses no recombination and mutation operators 
% from evolution strategies area.
% The locally oriented optimization only work with a small number
% of individuals which produce a lot of offspring. Only the best 
% of these are added to the population.
% In order to achieve this we have a choice of two possibilities.
% On the one hand, the population can contain few individuals 
% which each produce a lot of offspring. Only the best of these 
% offspring replace the parents and form the new population. 
% - population size: 1-5 individuals,
% - generation gap: 3-10 (number of offspring per parent),
% - selection pressure: 1 (no selection pressure).
% On the other hand, one works with a larger population size, 
% in which only the very best individuals produce offspring. 
% Here, (almost) all offspring replace the parents and form 
% the new population:
% - population size: 5-20 individuals,
% - generation gap: 1 (produce as many offspring as parents),
% - selection: truncation selection with a selection pressure 
%   of 3-10 (only the very best individuals are selected and 
%   each produce several offspring).
% The second variant has some small advantages, which have 
% particularly come to the fore during practical application.
% Thus, the second variant is used by default.
% However, the first variant is included in the comments below.
%
% Syntax:  GEAOPT = tbx3es1
%
% Input parameter:
%    no input parameters
%
% Output parameter:
%    GEAOPT    - Structure with newly defined options
%
% See also: muts1, mutes2, geamain2, geaoptset

% Author:   Hartmut Pohlheim
% History:  05.05.1999  file created
%           06.11.2005  two methods of selection options explained


function GEAOPT = tbx3es1


% Set function specific parameters
   GEAOPT = geaoptset(  'VariableFormat',       0           ...   % Use real valued variables 
                      , 'Recombination.Name',  {'recnone'}  ...   % no recombination used
                      , 'Mutation.Name',       {'mutes2'}   ...   % Define the evo. strategy real valued mutation function
                      , 'Mutation.Range',      [0.01]       ...   %  Initial mutation step size range
                     ...
                      , 'NumberSubpopulation',   1          ...   % Number of subpopulations (just one panmictic population)
                     ...
                      , 'NumberIndividuals',    12          ...   % Number of individuals per subpopulation
                      , 'Selection.Name',      {'seltrunc'} ...   % truncation selection must be used
                      , 'Selection.Pressure',        [6]    ...   % high selection pressure between parents (only best 1/6 parents are selected)
                      , 'Selection.GenerationGap',   [1]    ...   % Number of offspring per individual
                      , 'Selection.RankingMethod',    1     ...   % use non-linear ranking (necessary for the hihg selective pressure)
                     ... %  , 'NumberIndividuals',         [2]    ...  % Number of individuals per subpopulation
                     ... %  , 'Selection.Pressure',        [1]   ...   % no selection pressure between parents
                     ... %  , 'Selection.RankingMethod',    0     ...  % use linear ranking
                     ... %  , 'Selection.GenerationGap',   [6]   ...   % Number of offspring per individual
                     ...
                      , 'Selection.ReinsertionRate', [1]    ...   % replace all parent by the selected (best) offspring
                     );

% End of function