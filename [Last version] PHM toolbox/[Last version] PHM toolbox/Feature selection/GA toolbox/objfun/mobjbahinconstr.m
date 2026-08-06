% MultiObjective Problem (constrained): BAHIN's constrained function
%
% This function implements BAHIN's multiobjective constrained function.
% (by email - January 2006)
%
% MO properties: Ptrue connected and constrained, PFtrue point
%
% This function has two variables, two objectives and 3 constraints.
% Each of the objectives and constraints depends on the two variables.
% The constraints are easy to satiesfy. 
% The result is not really a Pareto front, more a point in the solution space.
%
% GoalMethod = 2 may be used to check the effect, when the constraints 
% are not set to a constant value as soon as satiesfied. Then these 
% constraints are still optimized (as additional objectives). The result 
% is quite different.
% Thus, GoalMethod = 2 is only an example to see an effect (not totally 
% obvious from the beginning).
%
% Syntax:  ObjV = mobjbahinconstr(Chrom, GoalMethod)
%
% For Input and Output parameters see objfun1.
%    Additional Input:
%       GoalMethod - Scalar defining method of goal definition (and constraint calculation)
%                    1: use goals for constraints defined to zero and constraints 
%                       set to zero when satiesfied
%                    2: use goals according to the original constraint values, see above
%                    if empty, NaN or not defined 1 is used 
%
% See also: mobjdebconstr, mobjsoland, mobjfonseca1, objfun1, mobjdtlz1

% Author:   Hartmut Pohlheim
% History:  25.01.2006  file created
%           26.01.2006  added GoalMethod and Goals in function definition
%                       use of elegant constraint handling technique


function ObjVal = mobjbahinconstr(Chrom, GoalMethod);

   % Compute population parameters
   [Nind, Nvar] = size(Chrom);

   if nargin < 1, Chrom = []; end
   if isnan(Chrom), Chrom = []; end
   if isempty(Chrom), Chrom = [NaN, NaN, 1]; end
   
   GoalMethodDefault = 1;
   if nargin < 2, GoalMethod = []; end
   if isnan(GoalMethod), GoalMethod = []; end
   if isempty(GoalMethod), GoalMethod = GoalMethodDefault; end
   if ~(any(GoalMethod == [1,2])), GoalMethod = GoalMethodDefault; end
   
   FunConstraints = [5000, 500, 1100];
   GoalDefault = [Inf, Inf, 0, 0, 0];
   if GoalMethod == 2, GoalDefault = [Inf, Inf, FunConstraints]; end
   
   % create objective function parameter structure
   if isnan(Chrom(1)),
      if all([isnan(Chrom(2)), Chrom(3) <= 10]),
         ObjVal = objfunoptset('FunctionName', 'BAHINs constrained MO-Function', ...
                               'VarBoundMin',  [0.03, 0.254], 'VarBoundMax', [0.2, 0.762], ...
                               'NumVarDefault', 2,    'NumVarMin',   2, 'NumVarMax', 2, ...
                               'NumObjDefault', 5,    'NumObjMin',   5, 'NumObjMax', 5, ...
                               'MObjGoals', GoalDefault);
      end

   % compute values of function
   else
      % F1= 96.89/(x1*x2) + 12.59*x1.^3*x2.^0.16*2.54.^1.4*193.3.^-4
      % F2= 9.68/(x1*x2) + 48.44*x1.^3*x2.^0.4*2.54.^1.4*0.05
      % Variable bounds / constraints:
      % 0.03 < x1 < 0.2 ; 0.254 < x2 < 0.762
      % With the following functional constraint conditions:
      % G1: 0.0373*x1.^0.91*x2.^0.78 * 2.54.^0.75 <= 5000
      % G2: 74.96*x1.^0.4*x2.^0.2 * 2.54.^0.105 - 17.8 <= 500
      % G3: 844*x1.^-0.1013*x2.^0.725 * 2.54.^0.75 <= 1100
      
      % Preset the objective values, 1 and 2 for the objectives, 3, 4 and 5 for the constraints
      ObjVal = repmat(Inf, [Nind, 5]); 

      % Define the two objectives
      x1 = Chrom(:,1); x2 = Chrom(:,2);
      ObjVal(:,1) = (96.89./(x1.*x2)) + 12.59*x1.^3.*x2.^0.16 * 2.54.^1.4 * 193.3.^-4;
      ObjVal(:,2) = (9.68./(x1.*x2)) + 48.44*x1.^3.*x2.^0.4 * 2.54.^1.4 * 0.05;
      
      % Define the constraints as additional objectives
      % First lets calculate the constraines
      G1 = 0.0373*x1.^0.91.*x2.^0.78 * 2.54.^0.75;       % <= 5000;
      G2 = 74.96*x1.^0.4.*x2.^0.2 * 2.54.^0.105 - 17.8;  % <=  500;
      G3 = 844*x1.^-0.1013.*x2.^0.725 * 2.54.^0.75;      % <= 1100;
      GAll = [G1 G2 G3];
      
      % Create matrix with constraint values for check of constraint violation
      BAll = repmat(FunConstraints, [Nind, 1]);
      
      % A little magic, set all constrained objectives, which are satisfied to zero
      % and all other (violated constraints) to the distance from the boundary
      % Goals must be: [Inf, Inf, 0, 0, 0]
      if GoalMethod ==  1,
         ObjVal(:,[3, 4, 5]) = (GAll <= BAll) .* 0 + (GAll > BAll) .* (GAll - BAll);
      
      % Another possibility: return the constraints and optimize by goals below 
      % the constraints boundary, this produces quite different results, 
      % because the satiesfied constraints are not bounded but still optimized
      else
         ObjVal(:,[3, 4, 5]) = GAll;  % Goals must be: [Inf, Inf, 5000, 500, 1100]
      end

   end

   
% End of function