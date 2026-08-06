% MultiOBJective function for SOLAND function (constrains as objectives)
%
% This function implements the SOLAND test function.
% It features a convex objective function of two variables subject
% to a nonlinear equality constraint. The variables are bounded.
%
% The function is implemented with two objectives. The first 
% is the main objective, the second the equality constraint.
%
% Syntax:  ObjVal = mobjsoland(Chrom)
%
% Taken from: Floudas, C. A. and Pardalos, P. M.: "A Collection of Test
%             Problems for Constrained Global Optimization Algorithms".
%             Lecture Notes in Computer Science vol. 455, 
%             Berlin, Heidelberg: Springer-Verlag, pp. 31-32, 1990.
%             Nonlinear Programming Test Problem 7
%
% Original:   Soland, R. M.: An algorithm for separable nonconvex 
%             programming problems ii: nonconvex constraints. 
%             Manag. Sci., 17(11), pp. 759-773, 1971.
%
% Input parameters:
%    Chrom     - Matrix containing the chromosomes of the current
%                population. Each row corresponds to one individual's
%                string representation.
%
% Output parameters:
%    ObjVal    - Column vector containing the objective values of the
%                individuals in the current population.
%                if called with Chrom == [NaN, NaN, xx], than see objfun1 for options
%                
% See also: objbran, objeaso, objsixh, objgold, obj*

% Author:   Hartmut Pohlheim
% History:  09.02.1999  file created
%           28.05.2005  constraint included as second objective, 
%                        goals set to [Inf, 0.02] to enforce constraint very near 0


function ObjVal = mobjsoland(Chrom);

   NAIN = nargin; NAOUT = nargout;

   if NAIN < 1, Chrom = []; end
   if isnan(Chrom), Chrom = []; end
   if isempty(Chrom), Chrom = [NaN, NaN, 1]; end

   FunConstraints = [0.005];
   GoalDefault = [Inf, 0.05];

   % create structure
   if isnan(Chrom(1)),
      if all([isnan(Chrom(2)), Chrom(3) <= 10]),
         ObjVal = objfunoptset(...
             'FunctionName', 'SOLAND function', ...
             'VarBoundMin',   [0, 0], 'VarBoundMax', [2, 3], ...
             'NumVarDefault', 2, 'NumVarMin', 2, 'NumVarMax', 2, ...
             'NumObjDefault', 2, 'NumObjMin',   2, 'NumObjMax', 2, ...
             'MObjGoals', GoalDefault, ...
             'GlobalMinObjV', -16.73889);
      end

   else
      % SOLAND function: minimize -12x1 - 7x2 + x2^2
      % subject to: 0 <= x1 <= 2 ; 0 <= x2 <= 3 % VLUB bounds
      % equality constraint: 0 = -2x1^4 + 2 - x2
      % global minimum at (x1, x2) = (0.71751, 1.470) ; fmin = -16.73889
      x1 = Chrom(:,1);
      x2 = Chrom(:,2);
      % Compute main objective value
      ObjVal(:,1) = -12.*x1 - 7.*x2 + x2.^2;

      % Define the constraint as additional objective
      % first step: compute violation of equality constraint (difference to zero)
      G1 = abs(-2.*x1.^4 + 2 - x2);
      % Set the constrained objective, which is satisfied to zero (here not possible, 
      % as the best violation is zero, thus we compare to a realistic constraint defined 
      % in FunConstraints)
      % and all other (violated constraints) to the distance from the boundary
      ObjVal(:,2) = (G1 <= FunConstraints(1)) .* 0 + (G1 > FunConstraints(1)) .* G1;
   end   


% End of function
