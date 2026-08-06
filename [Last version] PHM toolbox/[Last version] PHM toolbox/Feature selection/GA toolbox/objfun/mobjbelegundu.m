% MultiObjective Function: BELEGUNDU's function (constrained)
%
% This function implements a multiobjective function from BELEGUNDU.
% 
% Belegundu, A. D., et al. "Multi-Objective Optimization of 
% Laminated Ceramic Composites using Genetic Algorithms." 
% Proceedings of the 5th AIAA/NASA/USAF/ISSMO Symposium on 
% Multidiscipinary Analysis and Optimization,
% Washington, D.C.: AIAA,  pp. 1015-1022, 1994.
%
% Pareto Properties:
% Ptrue connected, PFtrue convex
%
% Syntax:  ObjV = mobjbelegundu(Chrom)
%
% For Input and Output parameters see objfun1.
%
% See also: objfun1, mobjfonseca1

% Author:   Hartmut Pohlheim
% History:  11.05.2001  file created
%           04.07.2001  constraints included
%           11.09.2001  update to v3.4
%           08.05.2005  formatting changed
%           01.07.2006  adapted constraints to the elegant constraint
%                       handling technique employing additional goals


function ObjVal = mobjbelegundu(Chrom);

   % Compute population parameters
   [Nind, Nvar] = size(Chrom);

   NAIN = nargin; NAOUT = nargout;

   if NAIN < 1, Chrom = []; end
   if isnan(Chrom), Chrom = []; end
   if isempty(Chrom), Chrom = [NaN, NaN, 1]; end

   FunConstraints = [0, 0];
   GoalDefault = [Inf, Inf, 0, 0];

   % create structure
   if isnan(Chrom(1)),
       if all([isnan(Chrom(2)), Chrom(3) <= 10]),
           ObjVal = objfunoptset(...
                                 'FunctionName', 'BELEGUNDUs MO-Function', ...
                                 'VarBoundMin', [0, 0], 'VarBoundMax', [5, 3], ...
                                 'NumVarDefault',  2, 'NumVarMin', 2, 'NumVarMax', 2, ...
                                 'NumObjDefault',  4, 'NumObjMin', 4, 'NumObjMax', 4, ...
                                 'MObjGoals', GoalDefault);
       end
   else
      % F1(x1,x2) = -2*x1 + x2
      % F2(x1,x2) =  2*x1 + x2
      % 0 < x1 < 5 ; 0 < x2 < 3
      % subject to
      % G1 = -x1 + x2 - 1 <= 0
      % G2 =  x1 + x2 - 7 <= 0

      ObjVal = repmat(Inf, [Nind, 4]); 

      % Define the two objectives
      x1 = Chrom(:,1); x2 = Chrom(:,2);
      ObjVal(:,1) = -2*x1 + x2;
      ObjVal(:,2) =  2*x1 + x2;
       
      % Define the constraints as additional objectives
      % First lets calculate the constraints
      G1 = -x1 + x2 - 1;
      G2 =  x1 + x2 - 7;
      GAll = [G1 G2];

      % Create matrix with constraint values for check of constraint violation
      BAll = repmat(FunConstraints, [Nind, 1]);
      
      % A little magic, set all constrained objectives, which are satisfied to zero
      % and all other (violated constraints) to the distance from the boundary
      ObjVal(:,[3, 4]) = ((GAll-BAll) <= 0) .* 0 + ((GAll-BAll) > 0) .* (GAll-BAll);

   end
     
% End of function