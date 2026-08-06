% DEMO for optimizing JSSP problem
%
% This script provides an example for defining non-default parameters
% for an optimization. Here is the highest level entry point into the
% GEA Toolbox.
%
% Syntax:  demojssp1
%
% Input parameter:
%    no input parameter
%
% Output parameter:
%    no output parameter
%
% See also: tbx3steadyga, tbx3real, tbx3comp, geamain2

% Author:   Hartmut Pohlheim
% History:  26.02.2005  file created

   % Load global parameters
   global NUMOFMC;
   ws;
   InitPop = feasible_init_pop;
   Dim = NUMOFMC.^2;

   % Set parameters for problem   % , tbx3comp
   GeaOpt = geaoptset(  tbx3perm  ...
                      , 'Recombination.Name',  {'recgp', 'recpm', 'msx'} ...    % Define the recombination function
                      , 'NumberSubpopulation',        5 ...        % Number of subpopulation
                      , 'NumberIndividuals',         [100] ...        % Number of individuals per subpopulation
                      ...
                      , 'Selection.GenerationGap',    0.5  ...
                      , 'Output.TextInterval',        2 ...        % Text output every x generations
                      ...   
                      , 'Output.GrafikInterval',      5  ...       % Grafic results every y generations
                      , 'Output.GrafikMethod',        111111 ...   % Grafic method to use
                      , 'Output.GrafikStyle',         514112 ...   % Grafic styles for specified methods
                      ...
                      , 'Termination.Method',         [1  ] ...    % Termination method(s) to use
                      , 'Termination.MaxGen',         100 ...      % Terminate after xx generations
                     );

   % Define objective function to use
   GeaOpt = geaoptset( GeaOpt , 'System.ObjFunFilename', 'cost_pop'); objfun = [];

   % Get variable boundaries from objective function
   VLUB = [ones(1, Dim); Dim * ones(1, Dim)];    % geaobjpara(GeaOpt.System.ObjFunFilename, [1 10]);
   GeaOpt = geaoptset( GeaOpt , 'System.ObjFunVarBounds', VLUB);
   VLUB = [];

   % Do a mesh plot of objective function
   % plotmesh(objfun, [-100,-100;100,100]);

   % Start optimization
   [xnew, GeaOpt] = geamain2(objfun, GeaOpt, VLUB, InitPop);


% End of script

