% ToolBoX function to define parameters for the Steady State Genetic Algorithm (SSGA)
%
% This function defines parameters for the Steady State Genetic Algorithm (SSGA).
% The special feature of the staedy state GA is the small number of offspring per 
% generation. A large part of the population survives to the next generation unchanged.
% Often only 2 or 4 individuals are produced each generation. 
% Here 2 individuals are produced (GenerationGap is 2% of 100 individuals).
% But even a generation gap of 10-20% is still a small number.
%
% Because of the small number of new offspring each generation the number of
% generations must be proportionally larger. Here 10000 generations are used
% as termination criteria.
% 
% Recombination/Crossover uses discrete recombination and a recombination/crossover 
% probability of 1.0.
% For mutation real mutation is used. The mutation probability (default is 1) 
% is internally divided by the number of (internal) variables, thus only one value 
% per individual is mutated. (The used internal value is presented on the screen 
% at the beginning of the optimization.)
% Just one panmictic population is used.
%
% This parameter setting function is provided to show you how to define 
% very well known genetic algorithm using the GEATbx.
%
% You can combine the power of the steady state GA with the power of multiple 
% populations (just define multiple subpopulation, here 4 subpopulations with 
% 25 individuals each), the use of different strategies (just define different 
% parameters for the subpopulations, here different mutation range) and competing 
% subpopulations (just set Migration and Competition to on, load of parameters 
% from tbx3comp). However, when using 2 new offspring each generation, competition
% does not make sence (as each subpopulation still produces only 2 offspring each
% generation). Thus, competition is not switched on. 
% In this case the optimization must end after 2500 (10000 generations divided 
% by 4 subpopulation, as each subpopulation produces 2 individuals each 
% generation for a total of 8 individuals compared to 2 individuals in the 
% panmictic population case above).
% See the end of the function for the complete parameter definition. 
%
% As this "extended" EA is more powerful than the "standard" steady state GA 
% I leave the "extended" parameters settings switched on by default. If you 
% want to switch them off, just set MultiPop = 0 in the source code.
%
% Syntax:  GEAOPT = tbx3steadyga
%
% Input parameter:
%    no input parameters
%
% Output parameter:
%    GEAOPT    - Structure with newly defined options
%
% See also: geamain2, geaoptset, tbx3bin, tbx3real, tbx3comp

% Author:   Hartmut Pohlheim
% History:  23.01.2005  file created


function GEAOPT = tbx3steadyga


   % Set function specific parameters
   GEAOPT = geaoptset(  'VariableFormat',             0           ...     % Use a real representation
                      ...   
                      , 'Recombination.Name',         {'recdis'}  ...     % Define the recombination function ['recsp']
                      , 'Recombination.Rate',         1.0         ...     % Define the recombination/crossover probability [0.7]
                      ...   
                      , 'Mutation.Name',              {'mutreal'} ...     % Define the mutation function, must be binary ['mutbin']
                      , 'Mutation.Rate',              1           ...     % Define the mutation probability [1(/n)]
                      , 'Mutation.Range',             [0.01]      ...     % Predefine mutation range
                      , 'Mutation.Precision',         24          ...     % and mutation precision
                      ...   
                      , 'NumberSubpopulation',        1           ...     % Number of subpopulation, just one [1]
                      , 'NumberIndividuals',          100         ...     % Number of individuals in population [100]
                      ...   
                      , 'Selection.GenerationGap',    0.02        ...     % Define generation gap (for steady state and elitist selection)
                      ...   
                      , 'Output.TextInterval',        50          ...     % Text output every 50 generations
                      ...   
                      , 'Output.GrafikInterval',      250         ...     % Grafic results every 250 generations
                      , 'Output.GrafikMethod',        11111       ...     % Grafic methods to use
                      , 'Output.GrafikStyle',         61411       ...     % Grafic styles for specified methods
                      ...                                                
                      , 'Termination.Method',         [1  ]       ...     % Termination method(s) to use
                      , 'Termination.MaxGen',         10000       ...     % Terminate after 10000 generations
                     );

   
   % To include multiple subpopulation each with a different strategy (mutation range) and competition
   MultiPop = 1;
   if MultiPop == 1,
      GEAOPT = geaoptset(GEAOPT   ...                                     % competition not switched on, tbx3comp ...
                      , 'NumberSubpopulation',        4           ...     % Number of subpopulation [4]
                      , 'NumberIndividuals',          25          ...     % Number of individuals in subpopulation [25]
                      ...   
                      , 'Mutation.Range',  [0.03, 0.01, 0.003, 0.001] ... % Predefine mutation range (different strategies)
                      , 'Mutation.Precision',         18          ...     % and mutation precision
                      ...   
                      , 'Termination.MaxGen',         2500        ...     % Terminate after 2500 generations (10000/4)
                      ...   
                      , 'Output.GrafikMethod',        111111      ...     % Grafic methods to use
                      , 'Output.GrafikStyle',         614111      ...     % Grafic styles for specified methods
                     );
   end
   

% End of function

