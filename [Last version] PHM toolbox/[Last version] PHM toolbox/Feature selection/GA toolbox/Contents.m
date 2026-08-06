% GEATbx (Genetic and Evolutionary Algorithm Toolbox for use with Matlab)
% Version 3.80 (R11-14+, 2006+) 22-Dec-2006
% Copyright (c) 1994-2006 by Hartmut Pohlheim.
%
% Main functions of GEATbx
% geamain2      - MAIN function for Genetic and Evolutionary Algorithm toolbox for matlab
% selection     - high level SELECTion function
% recombin      - high level RECOMBINation function
% mutate        - high level MUTATion function
% reins         - high-level RE-INSertion function
% compete       - COMPETition between subpopulations
% migrate       - MIGRATion of individuals between subpopulations
% terminat      - TERMINATion function
%
% Toolbox functions (high level parameter setting)
% tbx3real      - ToolBoX function to define parameters for optimization of real variables
% tbx3int       - ToolBoX function to define parameters for optimization of integer variables
% tbx3bin       - ToolBoX function to define parameters for optimization of binary variables
% tbx3perm      - ToolBoX function to define parameters for optimization of permutation variables
% tbx3comp      - ToolBoX function to define parameters for COMPeting subpopulation
% tbx3es1       - ToolBoX function to define parameters for locally oriented optimization of real variables
% tbx3steadyga  - ToolBoX function to define parameters for the Steady State Genetic Algorithm (SSGA)
% tbx3sga       - ToolBoX function to define parameters for the Simple Genetic Algorithm (SGA)
% tbx3moo1      - ToolBoX function to define parameters for multi-objective optimization 1
% tbx3output    - ToolBoX function to define parameters for output on screen (visualization)
% tbx3output2   - ToolBoX function to define parameters for output on screen (visualization) 2
% tbx3plot1     - ToolBoX function to define parameters for grafical display options
% tbx3textless  - ToolBoX function to define parameters for a silent optimization (minimal output on screen)
% tbx3silent    - ToolBoX function to define parameters for no textual and graphical output during an optimization
% tbx3guifun1   - ToolBoX function to define parameters for optimization, test of gui
%
% Functions for fitness assignment
% rankgoal      - perform goal preference calculation between multiple objective values
% ranking       - RANK-based fitness assignment, single and multi objective, linear and nonlinear
% rankplt       - RANK two multi objective values Partially Less Than
% rankshare     - SHARing between individuals
%
% Selection functions
% sellocal      - SELection in a LOCAL neighbourhood
% selrws        - SELection by Roulette Wheel Selection
% selsus        - SELection by Stochastic Universal Sampling
% seltour       - SELection by TOURnament
% seltrunc      - SELection by TRUNCation
%
% Recombination functions
% recdis        - RECombination DIScrete
% recdp         - RECombination Double Point
% recdprs       - RECombination Double Point with Reduced Surrogate
% recgp         - RECombination Generalized Position
% recint        - RECombination extended INTermediate
% reclin        - RECombination extended LINe
% reclinex      - EXtended LINe RECombination
% recmp         - RECombination Multi-Point, low level function
% recpm         - RECombination Partial Matching
% recsh         - RECombination SHuffle
% recshrs       - RECombination SHuffle with Reduced Surrogate
% recsp         - RECombination Single Point
% recsprs       - RECombination Single Point with Reduced Surrogate
%
% Mutation functions
% mutbin        - MUTation for BINary representation
% mutbmd        - real value Mutation like Discrete Breeder genetic algorithm
% mutcomb       - MUTation for combinatorial problems
% mutes1        - MUTation by Evolutionary Strategies 1, derandomized Self Adaption
% mutes2        - MUTation by Evolutionary Strategies 2, derandomized self adaption
% mutexch       - MUTation by eXCHange
% mutint        - MUTation for INTeger representation
% mutinvert     - MUTation by INVERTing variables
% mutmove       - MUTation by MOVEing variables
% mutrand       - MUTation RANDom
% mutrandbin    - MUTation RANDom of binary variables
% mutrandint    - MUTation RANDom of integer variables
% mutrandperm   - MUTation RANDom of binary variables
% mutrandreal   - MUTation RANDom of real variables
% mutreal       - real value Mutation like Discrete Breeder genetic algorithm
% mutswap       - MUTation by SWAPping variables
% mutswaptyp    - MUTation by SWAPping variables of identical type
%
% Reinsertion functions
% reinsloc      - RE-INSertion of offspring in population replacing parents LOCal
% reinsreg      - REINSertion of offspring in REGional population model replacing parents
%
% Functions for population conversion (different representations)
% bindecod      - BINary DECODing to binary, integer or real numbers
% bin2int       - BINary string to INTeger string conversion
% bin2real      - BINary string to REAL vector conversion
%
% Functions for population initialization
% initpop       - INITialization of POPulation (including innoculation)
% initbp        - CReaTe an initial Binary Population
% initip        - CReaTe an initial (Integer value) Population
% initpp        - Create an INITial Permutation Population
% initrp        - INITialize an Real value Population
%
% Adds all GEATbx directories to the Matlab search path
% path_gea      - Set all paths for the GEA toolbox (Matlab search path)
% toolboxpath   - Set all paths for GEA toolbox (old version, obsolete, use path_gea instead)
%
% Functions for different computations
% compdiv       - COMPute DIVerse things of GEA Toolbox
% comploc       - COMPute LOCal model things of toolbox
% compplot      - COMPute PLOT things of GEA Toolbox
%
%
% AutoAdd
% GEATbxReleaseNotes - Release Notes of the GEATbx














