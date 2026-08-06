% GEATbx  Objective functions, special plot functions
%
% Standard benchmark optimization functions (real valued parametric optimization)
% objfun1       - OBJective function for de jong's FUNction 1
% initfun1      - INITialzation function for de jong's FUNction 1
% objfun2       - OBJective function for rosenbrock's FUNction
% objfun6       - OBJective function for rastrigins FUNction 6
% objfun7       - OBJective function for schwefel's FUNction
% objfun8       - OBJective function for griewangk's FUNction
% objfun9       - OBJective function for sum of different power FUNction 9
% objfun10      - OBJective function for ackley`s path FUNction 10
% objfun11      - OBJective function for langermann's function 11
% objfun12      - OBJective function for michalewicz's function 12
% objfun1a      - OBJective function for axis parallel hyper-ellipsoid
% objfun1b      - OBJective function for rotated hyper-ellipsoid
% objfun1c      - OBJective function for moved axis parallel hyper ellipsoid 1c
% objbran       - OBJective function for BRANin rcos function
% objeaso       - OBJective function for EASom function
% objgold       - OBJective function for GOLDstein-price function
% objsixh       - OBJective function for SIX Hump camelback function
%
% Standard benchmark optimization functions (integer/binary valued parametric optimization)
% objint1       - OBJective function for INT function 1
% objint2       - OBJective function for INT function 1
% objint3       - OBJective function for INT function 3
% objint4       - OBJective function for INT function 4
% objone1       - OBJective function for ONEmax function 1
%
% Special benchmark optimization functions (real and discrete valued parametric optimization)
% obj4wings     - OBJective function FOUR-WINGS.
% objfletwell   - OBJective function after FLETcher and PoWELL
% objfractal    - OBJective function Fractal Mandelbrot
% objridge      - OBJective function RIDGE
%
% Multi-objective functions
% mobjfonseca1  - Multi-OBJective function: FONSECA's MO-function 1
% mobjfonseca2  - Multi-OBJective function: FONSECA's MO-function 2
% mobjbelegundu - MultiObjective Function: BELEGUNDU's function (constrained)
% mobjdtlz1     - MultiObjective Function: Deb, Thiele, Zitzler, Laumanns' multiobjective function 1
% mobjdtlz2     - MultiObjective Function: Deb, Thiele, Zitzler, Laumanns' multiobjective function 2
% mobjdtlz3     - MultiObjective Function: Deb, Thiele, Zitzler, Laumanns' multiobjective function 3
% mobjkita      - MultiObjective Function: KITA's function (constrained)
% mobjquagliarella - MultiObjective Problem: QUAGLIARELLA's function
% mobjcantilever - Objective function for multiobjective cantilever beam system
%
% Multi-objective functions with constraints
% mobjdebconstr - MultiObjective Problem (constrained): DEB's constrained function
% mobjsoland    - MultiOBJective function for SOLAND function (constrains as objectives)
%
% Functions to solve TSP (travelling sales person) problems
% objtsplib     - OBJective function for the traveling salesman library
% plottsplib    - PLOTing of results of TSP optimization (TSPLIB examples)
% objtsp1       - OBJective function for the traveling salesman example
% tsp_readlib   - TSP utility function, reads TSPLIB data files
% tsp_uscity    - TSP utility function, reads US City definitions
%
% Functions to solve VRP (vehicle routing) problems
% objvrp        - OBJective function for the vehicle routing problem
% plotvrp       - PLOTing of results of VRP optimization
% vrpconvind    - Conversion of individuals in routes and routes in individuals for the VRP
% vrpgetdata    - Get the data for the example vehicle routing problems 
%
% Example double integrator
% objdopi       - OBJective function for DOuble Integrator
% plotdopi      - PLOTing of DO(Ppel)uble Integration results 
% initdopi      - INITialzation function for DOuble Integrator objdopi
% simdopi1      - M-file description of the SIMULINK system named SIMDOPI1
% simdopiv      - SIMulation Modell of DOPpelIntegrator, s-function, Vectorized
%
% Example Linear quadratic / Harvest / Push cart problem (dynamic optimization)
% objlinq       - OBJective function for discrete LINear Quadratic problem
% objlinq2      - OBJective function for LINear Quadratic problem 2
% simlinq1      - M-file description of the SIMULINK system named SIMLINQ1
% simlinq2      - Modell of Linear Quadratic Problem, s-function
% objharv       - OBJective function for HARVest problem
% objpush       - OBJective function for PUSH-cart problem
%
% Example Car steering (lateral control)
% objauto2      - OBJective function for lateral AUTO controller system 2
% plotauto      - PLOTing of AUTO lateral control results 
% res_auto_good_1 - different best results from optimizations
%
% Special case objective functions
% objteststr1   - OBJective function: Structure Testing AND
% objswtest1    - OBJective function for de jong's FUNction 1
% objfun168     - OBJective function as combination of 3 standard obj. functions
% mobjrandobjv1 - MultiObjective Problem: Pohlheim-Bagot random-valued multi-objective function 1
% mobjbahinconstr - MultiObjective Problem (constrained): BAHIN's constrained function
% objsharifi1   - OBJective function for 5-x1^2-2*x2^2-x1
%
% Helper function(s) for lectures
% lectcmd1      - CoMmanDs for LECTure for live introduction of EA optimization
% objlive1      - OBJective function 1 for live introduction of EA optimization in lecture
% objlive2      - OBJective function 1 for live introduction of EA optimization in lecture
% plotobjfun    - PLOTing of OBJective FUNction data during optimization
%
















