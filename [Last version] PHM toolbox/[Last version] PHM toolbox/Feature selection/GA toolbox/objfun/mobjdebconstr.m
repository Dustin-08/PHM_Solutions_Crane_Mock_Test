% MultiObjective Problem (constrained): DEB's constrained function
%
% This function implements DEB's multiobjective constrained function.
%   F1= x1
%   F2=(1+x2)/(x1)
%   0.1 < x1 < 1 ; 0 < x2 < 5
%   With the following constraint conditions:
%   g1:  x2+9x1 >= 6
%   g2: -x2+9x1 >= 1
%
% Deb, K. : A fast and elitest multi-objective genetic algorithm: NSGA-II.
% KanGAL Report 200001, p. 16 and 17, Table VI.
%
% MO properties: Ptrue connected and constrained, PFtrue convex
%
% Syntax:  ObjV = mobjdebconstr(Chrom)
%
% For Input and Output parameters see objfun1.
%                
% See also:  mobjfonseca1, objfun1, mobjdtlz1

% Author:   Hartmut Pohlheim
% History:  10.04.2005  file created
%           26.01.2006  added MObjGoals in function definition
%                       more clear method of constraint inclusion by goals


function ObjVal = mobjdebconstr(Chrom);

   % Compute population parameters
   [Nind, Nvar] = size(Chrom);

   if nargin < 1, Chrom = []; end
   if isnan(Chrom), Chrom = []; end
   if isempty(Chrom), Chrom = [NaN, NaN, 1]; end
   
   FunConstraints = [6, 1];
   GoalDefault = [Inf, Inf, 0, 0];

   % create objective function parameter structure
   if isnan(Chrom(1)),
      if all([isnan(Chrom(2)), Chrom(3) <= 10]),
         ObjVal = objfunoptset('FunctionName', 'DEBs constrained MO-Function', ...
                               'VarBoundMin',  [0.1, 0], 'VarBoundMax', [1, 5], ...
                               'NumVarDefault', 2,    'NumVarMin',   2, 'NumVarMax', 2, ...
                               'NumObjDefault', 4,    'NumObjMin',   4, 'NumObjMax', 4, ...
                               'MObjGoals', GoalDefault);
      end

   % compute values of function
   else
      ObjVal = repmat(Inf, [Nind, 4]); 

      % Define the two objectives
      x1 = Chrom(:,1); x2 = Chrom(:,2);
      ObjVal(:,1) = x1;
      ObjVal(:,2) = (1 + x2) ./ x1;
      
      % Define the constraints as additional objectives
      % First lets calculate the constraints
      G1 =  x2 + 9*x1;
      G2 = -x2 + 9*x1;
      GAll = [G1 G2];
      
      % Create matrix with constraint values for check of constraint violation
      BAll = repmat(FunConstraints, [Nind, 1]);
      
      % A little magic, set all constrained objectives, which are satisfied to zero
      % and all other (violated constraints) to the distance from the boundary
      % as we are maximizing (>=6, >=1) and our objectives are minimized we multiply with -1
      ObjVal(:,[3, 4]) = ((GAll-BAll) >= 0) .* 0 + ((GAll-BAll) < 0) .* (GAll-BAll) .* -1;

   end

   
% End of function