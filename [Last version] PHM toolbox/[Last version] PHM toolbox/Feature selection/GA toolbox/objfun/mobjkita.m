% MultiObjective Function: KITA's function (constrained)
%
% Kita, H., Yabumoto, Y., Mori, N., Nishikawa, Y.: 
% "Multi-Objective Optimization by Means of the Thermodynamical 
% Genetic Algorithm." in Voigt et al. (ed.), Parallel Problem 
% Solving from Nature - PPSN IV, pp. 504-512, 1996.
%
% Pareto Properties:
% Ptrue connected, PFtrue convex
% (original problem was maximized, here we multiply with -1)
%
% Syntax:  ObjV = mobjkita(Chrom)
%
% For Input and Output parameters see objfun1.
%
% See also: objfun1, mobjfonseca1

% Author:   Hartmut Pohlheim
% History:  11.05.2001  file created
%           04.07.2001  constraints included
%           20.09.2001  update to V3.4
%           08.05.2005  formatting changed
%           01.07.2006  adapted constraints to the elegant constraint
%                       handling technique employing additional goals


function ObjVal = mobjkita(Chrom);

   % Compute population parameters
   [Nind, Nvar] = size(Chrom);

   NAIN = nargin; NAOUT = nargout;

   if NAIN < 1, Chrom = []; end
   if isnan(Chrom), Chrom = []; end
   if isempty(Chrom), Chrom = [NaN, NaN, 1]; end

   FunConstraints = [0, 0, 0];
   GoalDefault = [Inf, Inf, 0, 0, 0];
   
   % create structure
   if isnan(Chrom(1)),
       if all([isnan(Chrom(2)), Chrom(3) <= 10]),
           ObjVal = objfunoptset(...
                                 'FunctionName', 'KITAs MO-Function', ...
                                 'VarBoundMin', 0, 'VarBoundMax',   7, ...
                                 'NumVarDefault', 2, 'NumVarMin', 2, 'NumVarMax', 2, ...
                                 'NumObjDefault', 5, 'NumObjMin', 5, 'NumObjMax', 5, ...
                                 'MObjGoals', GoalDefault);
       end
   else
      % F1 =      x1^2 - x2,
      % F2 = -0.5*x1   - x2 - 1,
      % 0 < x1 < 7 ; 0 < x2 < 7
      % subject to
      % G1 = 1/6 * x1 + x2 - 13/2 <= 0,
      % G2 = 1/2 * x1 + x2 - 15/2 <= 0,
      % G3 =   5 * x1 + x2 - 30   <= 0

      ObjVal = repmat(Inf, [Nind, 4]); 

      % Define the two objectives
      x1 = Chrom(:,1); x2 = Chrom(:,2);
      ObjVal(:,1) = x1.^2 - x2;
      ObjVal(:,2) = -0.5.*x1 - x2 -1;

      % Define the constraints as additional objectives
      % First lets calculate the constraints
      G1 = 1/6 .* x1 + x2 - 13/2;
      G2 = 1/2 .* x1 + x2 - 15/2;
      G3 =   5 .* x1 + x2 - 30;
      GAll = [G1 G2 G3];

      % Create matrix with constraint values for check of constraint violation
      BAll = repmat(FunConstraints, [Nind, 1]);
      
      % A little magic, set all constrained objectives, which are satisfied to zero
      % and all other (violated constraints) to the distance from the boundary
      ObjVal(:,[3, 4, 5]) = ((GAll-BAll) <= 0) .* 0 + ((GAll-BAll) > 0) .* (GAll-BAll);

   end


% End of function