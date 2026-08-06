% Release Notes of the GEATbx
%
% Notes about changes in the source code and the documentation of the 
% Genetic and Evolutionary Algorithm Toolbox for use with Matlab.
%
% See also: documentation of the GEATbx
%
% Author:   Hartmut Pohlheim
% 
% GEATbx 3.8 - December 2006 (public version)
% -------------------------------------------------------------------------------
%  Source
%  - Renamed function for adding paths to search path (path_gea, was toolboxpath).
%      The function for extending the Matlab search path was renamed to
%      path_gea (old name was toolboxpath). Now the name is more consistent
%      with the functionality (and multiple projects can use this naming 
%      convention).
%      The actual path extension is now done using addpath (and does not use 
%      the low level function matlabpath).
%      The help inside the function was partly rewritten and extended with 
%      another example. 
%   
%  - New demo function to demonstrate the optimization of integer variables.
%      demointeger1
%  
%  - Elegant methode for the handling of constraints employing additional constraints.
%      Constraints are defined as additional objectives. If a constraint is
%      not violated, the corresponding objective is zero. If a constraint is
%      violated, die objective is identical to the violation. Additionally,
%      the goals for the "constrained objectives" must be defined as 0 (zero).
%      Thus, the "constrained objectives" are only optimized as long as the 
%      constraint is violated. If no constraint is violated, only the main
%      (functional) objectives are active.
%      This elegant and universal constraint handling method is already 
%      implemented in most of the constrained example functions.
%      DEBs constrained function (mobjdebconstr)
%      BELEGUNDUs function (mobjbelegundu)
%      KITAs function (mobjkita)
%      BAHINs function (mobjbahinconstr)
%      SOLANDs function (mobjsoland)
% 
%  - Added the definition of Goals inside multi-objective functions.
%      It is now possible to define standard values for goals inside the 
%      (multi)objective functions.
%      To get the defined goals use: geaobjpara('NameofObjFun',  [16])
%      This is similar to defining the upper and lower bounds of the 
%      variables (VLUB/'VarBoundMin'/'VarBoundMax') or the default number 
%      of variables ('NumVarDefault').
%      The respective m-files geaobjpara and objfunoptset are extended.
%      An example can be found in the demo function demomop.
%      Most of the multi-objective example functions use the new method.
% 
%  - Added further examples to demo function demomop for multi-objective optimization.
%      BELEGUNDUs function (mobjbelegundu)
%      KITAs function (mobjkita)
% 
%  - Extension of multi-objective demo function demomop.
%      Added assessment of best individuals at the end of a multi-objective 
%      optimization (objective value calculation, fitness values, plot of 
%      PARETO front).
%      Now, the PARETO front of the best solutions found during optimization 
%      is visualized. Additionally, the fitness (FitnV) and rank values (RankMOV)
%      of the best solutions are available in the calling workspace and can be used
%      for further calculations.
% 
%  - Removed a bug in colbestind, appearing with binary values.
%      Added an abs before the sum of diff calculation.
%      Examples were added for better understanding (with binary population)
%      of the functionality.
% 
% 
%  Documentation
%  - New/separate Section in Introduction to Evolutionary Algorithms about:
%      References for publications regarding multi-objective optimization.
% 
%  - New Chapter on multi-objective optimization in Introduction:
%      Moved PARETO-ranking, goal attainment, sharing and weighted sum 
%      to the new chapter.
% 
%  - New Chapter on the use of Multi-objective optimization in Tutorial:
%      Comprehensive explanation of how to switch on MO optimization, the 
%      parameters to adjust, the provided visualization and the demo function
%      demomop.
% 
%  - New Chapter on Constrained optimization in Tutorial:
%      Comprehensive explanation of how to use constraint optimization. 
%      Variable constraints and functional constraint are explained and 
%      the use demonstrated.
% 
%  - Section on Variable Representation in Tutorial considerably extended
%      The aspets of different representations are described including the 
%      conversion between binary to integer or real representation. The 
%      examples were extended and a few more added including references to 
%      the repective demo functions.
%      Added information on the handling of different representations in 
%      one optimization. Integer and binary representation can be used 
%      simultaneously today. Real and binary or integer will be available 
%      in a future version.
% 
% 
% GEATbx 3.7 - November 2005 (public version)
% -------------------------------------------------------------------------------
%  Source
%  - Removed a bug in colbestind.m, which prevented the correct collection of
%      individuals when comparing the variables (sum for diff was operating along 
%      the rows and not along the columns). Thus, for integer populations only a 
%      few individuals were collected.
%      
%  - Added VRP (vehicle routing problem) example(s)
%      Vehicle routing is a large class of ordering/permutation problems. To support 
%      the start into this optimization area I wrote a demo function (demovrp), an 
%      objective function (objvrp), a VRP specific plot function (plotvrp) and a few 
%      utility functions (vrpconvind, vrpgetdata). Two data sets (vrpnc1, vrpsolrc101)
%      are directly available and can be used for your first experiments. 
%      (The vrp example needs routines from the matlog toolbox. Please get 
%       Matlog and install it in your Matlab serach path.)
%       
%  - Help section updated for:
%      demofun1cmp: show competition during optimization
% 
%  Documentation
%  - Reworked all Contents.m files of the GEATbx
%      The files are listed in named section, which give a much better overview
%      on the available m-files. Functions belonging to one topic are grouped 
%      together.
%      In the M-Functions index of the documentation the Contents files are
%      much more useful now.
%      
%  - Inclusion of objective function example documentation
%      The inclusion of better graphics of the search space of many of the example 
%      functions provides a much better understanding of the properties of the
%      functions (all produced with plotmesh using the high level script graf_msh).
% 
%  - Index over all written documentation extended
%      One index covering all parts of the written documentation is available. It
%      covers the Introduction, the Tutorial, the Example function documentation 
%      and the Options documentation.
%      
%  - New Chapter in Introduction about:
%      Combination of Operators and Options to Produce Evolutionary Algorithms
%      Extensive discussion of the different aspects when combining operators and 
%      their options.
%  
%  
%  GEATbx 3.65 - May 2005 (internal version)
% -------------------------------------------------------------------------------
%  Source
%  - Inclusion of additional multi-objective example functions.
%      Further Deb, Thiele, Zitzler, Laumanns functions (mobjdtlz2, mobjdtlz3)
%      Kita's function (mobjkita)
%      Belegundu's function (mobjbelegundu)
% 
%  - Initialization of integer population (initip), (automatic) extension of bounds
%      The bounds (VLUB) for integer representation are (automatically) extended 
%      by (nearly) 0.5 for uniform initialization at the defined bounds.
%      Now it is ensured, that the values are created uniform at random, even at the 
%      bounds of the initialization range. Formerly, the bound values were only used 
%      half as often as the other values. 
%      See help initip for a longer description and two examples, which demonstrate 
%      this effect.
%      For integer representation you must use integer values for the bounds. Otherwise 
%      the (automatic) extension breaks your bounds and you get variable values outside
%      your defined bounds.
% 
% 
%  GEATbx 3.6 - March 2005 (internal version)
% -------------------------------------------------------------------------------
%  Source
%  - Inclusion of additional multi-objective example functions.
%      First Deb, Thiele, Zitzler, Laumanns function (mobjdtlz1)
%      Quagliarella's function (mobjquagliarella.m)
%      Fonseca's functions (mobjfonseca1 and mobjfonseca2) are already included.
% 
%  Documentation
%  - Added information on multi-objective optimization to the Introduction.
%      Multi-objective optimization is already supported by the GEATbx. However, 
%      the documentation was still lacking. Now a whole section is dedicated to 
%      the different mechanisms necessary for multi-objective ranking, including 
%      PARETO-ranking, goal attainment and sharing.
%      See Introduction, Chapter Selection, Subsection Multi-objective ranking
%      The implemented archive (CollectBestInd) will be described later.
%  
%  - Corrected an error in documentation of equation for non-linear ranking.
%      There was a (very old) error in the (sub)equation for non-linear ranking.
%      See Introduction, Chapter Selection, Subsection Rank-based fitness assignment
%      equation "X is computed as the root of the polynomial:"
%      correct: 0 = (SP - Nind) ...        wrong: 0 = (SP - 1) ...
%      The source code in ranking.m was always correct.
% 
% 
%  GEATbx 3.55 - November 2004 (internal version)
% -------------------------------------------------------------------------------
%  Source
%  - Inclusion of additional multi-objective example functions.
%      Cantilever beam problem (mobjcantilever and democantilever)
% 
%  Documentation
%  - Rewrite of the objective function examples started.
%      All parametric functions (objfun1-objfun12 and a few more) were 
%      rewritten in the GEATbx documentation format. This format allows 
%      the creation of pdf and html documents from the same source 
%      (already used for Introduction, Tutorial and Options).
% 
% 
%  GEATbx 3.5 - February 2004 (public version)
% -------------------------------------------------------------------------------
%  Source
%  - Multi-objective ranking is used wherever necessary and only when necessary.
%  
%  - Sharing (by default sharing in search space) is carried out directly after ranking. 
%      However, sharing is only carried out when needed (means before selection).
%      Sharing in solution space can be selected as well. The switch to sharing in 
%      solution space can be done at the end of ranking.m inside the source code 
%      (see ShareMethod).
% 
%  - Three different implementations of MO ranking are included in
%      ranking.m. Depending on the number of individuals and objectives (automatically)
%      the most appropriate is chosen (in such a way, that not too much memory is used).
%      The first method takes next to no time but a lot of memory and uses 3-D
%      tensors.
%      The second requires linear time and memory and can handle goals.
%      The third takes only a very small amount of memory and can handle goals as 
%      well, but employs double for loops.
%      
%      It is always tried to use the quickest algorithm, but switch back if
%      the amount of memory needed is larger than 32 MByte(or 128MByte in 2005).
%      Have a look inside ranking.m for more info.
% 
%  - geamain2 returns a whole population at the end of the population.
%      In the MO case this population contains all non-dominated solutions
%      found (but not more than individuals inside the population).
% 
%  - colbestind (CollectBest.*) handles MO individuals as well. These
%      results are included in the return population as well.
% 
%  - Possible problems when changing from version 3.3 to version 3.5 (or newer):
%      Some sub functions in compdiv/compdiv2 are now separate functions.
%      If you use any of these functions in your projects please change the calls.
%      
%      To get the parameters of the objective function (boundaries of variables, 
%      long name of function, global optimum ...) different interfaces were used 
%      during the last years. Now one function (geaobjpara.m) provides one 
%      interface to everything. Have a look at demomop and demogeatbx for an 
%      example of the application.
% 
%  - Corrected error in calculation of objective tsp lib function.
%      computing dist contained wrong reference (irout instead of i)
%      correct: for irout = 1:Nroutes, dist(irout) = sum(diag ...
%      wrong:   for irout = 1:Nroutes, dist(i)     = sum(diag ...
% 
% 
% 
% End of Release Notes GEATbx (only 2004 and newer)