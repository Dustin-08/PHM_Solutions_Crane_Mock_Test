% Calculate number of subpopulations and individuals for GEATbx
%
% This function takes the problem size (using number of variables)
% and calculates the number of subpopulations and individuals 
% per subpopulation.
% These numbers constitute a robust starting value.
% The equations are suited for real-valued representations and 
% problems of low difficulty. Problems with many irregular local 
% minima and/or correlations between variables may need a larger 
% number of individuals.
%
% Syntax:  [NumSubPop, NumIndSubPop, NumIndPop] = geanumind(NumVar, Difficulty)
%
% Input parameter:
%    NumVar    - Scalar defining the number of variables of a 
%                problem (used for size of problem)
%    Difficulty- (optional) Scalar defining the difficulty of the 
%                problem (not used at the moment, but will be useful)
%
% Output parameter:
%    NumSubPop - Scalar containing the number of subpopulations
%    NumIndSubPop - Scalar containing the number of individuals 
%                   per subpopulation
%    NumIndPop - Scalar containing the number of individuals in all 
%                subpopulations (is NumSubPop x NumIndSubPop)
%
% Examples:
% % Calculate number of subpopulations and individuals for a problem with 12 variables
% >> NumVar = [12]
% >> [NumSubPop, NumIndSubPop, NumIndPop] = geanumind(NumVar)
%     NumSubPop =     3
%     NumIndSubPop = 20
%     NumIndPop =    60
%
% % Calculate number of subpopulations and individuals for common problem sizes
% >> NumVar = [5,10:10:200]
% >> [NumSubPop, NumIndSubPop, NumIndPop] = geanumind(NumVar)
% NumVar =
%   5   10   20   30   40   50   60   70   80   90  100  110  120  130  140  150  160  170  180  190  200
% NumSubPop =
%   2    3    4    5    6    7    7    8    8    9   10   10   10   11   11   12   12   13   13   13   14
% NumIndSubPop =
%  20   20   20   20   20   25   25   25   25   25   30   30   30   30   30   35   35   35   35   35   40
% NumIndPop =
%  40   60   80  100  120  175  175  200  200  225  300  300  300  330  330  420  420  455  455  455  560
%
% See also: geamain2

% Author:   Hartmut Pohlheim
% History:  14.01.2007  file created


function [NumSubPop, NumIndSubPop, NumIndPop] = geanumind(NumVar, Difficulty)

   % Set default values
   NumSubPop = 3; NumIndSubPop = 20; NumIndPop = NumSubPop * NumIndSubPop;

   % Check input parameter
   if nargin < 1, return; end

   % Calculate number of subpopulations
   NumSubPop = floor(sqrt(NumVar));

   % Calculate number of individuals per subpopulation
   NumIndSubPop = 20 + 5 * floor(NumVar./50);

   % Calculate number of individuals in whole population
   NumIndPop = NumSubPop .* NumIndSubPop;


% End of function