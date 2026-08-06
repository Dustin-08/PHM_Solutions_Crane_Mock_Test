% MultiObjective Function: Deb, Thiele, Zitzler, Laumanns' multiobjective function 1
%
% Kalyanmoy Deb, Eckart Zitzler, Lothar Thiele and Marco Laumanns:
% Scalable Test Problems for Evolutionary Multi-Objective Optimization.
%
% Pareto Properties:
% Ptrue connected, PFtrue convex
%
% The number of variables per individual must be at least 2 more
% than the number of objectives. Suggested is NObj = Nvar+4 and more.
%
% Syntax:  ObjVal = mobjdtlz1(Chrom);
%
% For Input and Output parameters see objfun1.
%
% See also: mobjfonseca1, objfun1, mobjdtlz2, mobjdtlz3 

% Author:   Hartmut Pohlheim
% History:  08.08.2001  file created
%           11.09.2001  update to V3.4
%           08.05.2005  formatting changed


function ObjVal = mobjdtlz1(Chrom);

   NAIN = nargin; NAOUT = nargout;

   if NAIN < 1, Chrom = []; end
   if isnan(Chrom), Chrom = []; end
   if isempty(Chrom), Chrom = [NaN, NaN, 1]; end
   persistent NOBJUSE
   
   % create structure
   if isnan(Chrom(1)),
       if all([isnan(Chrom(2)), Chrom(3) <= 10]),
           ObjVal = objfunoptset(...
               'FunctionName', 'DTLZ-MO-Function 1', ...
               'VarBoundMin',   0, 'VarBoundMax', 1, ...
               'NumVarDefault', 7, 'NumVarMin',   3, 'NumVarMax', Inf, ...
               'NumObjDefault', 3, 'NumObjMin',   3, 'NumObjMax', Inf);
       elseif Chrom(3) == 11,
           NOBJUSE = Chrom(4);
       end
   else
      if isempty(NOBJUSE),
          NOBJUSE = 3;
      end
      
      % Relation between Amount of Variables and Objectives:
      % NVar = NOBJUSE + k - 1
      % The Authors suggest k=5.
      
      % F (xi) = (f1(xi, ..., fM(xi))
      % f1(xi) = 1/2 * prod(x(1)...x(M-1)) * (1 + g(x(1)...x(M)))
      % f2(xi) = 1/2 * prod(x(1)...x(M-2)) * (1 - x(M-1)) * (1 + g(x(1)...x(M)))
      %                         :
      % fM-1(xi) = 1/2 * x(1) * (1-x(2)) (1 + g(x(1)...x(M)))
      % fM(xi) = 1/2 *(1-x(1) * (1 + g(x(1)...x(M)))
      % for i = 1:NVar
      %    g(x(1)...x(M)) = 100 * [abs(x(1)...x(M)) + sum((x(i)-0.5)^2 - cos(20*pi*(x(i)-0.5)))]
      
      % function g(Chrom) suggested by DTLZ:
      g = 100 * (5 + sum((Chrom-0.5).^2 - cos(20*pi*(Chrom-0.5)), 2));
      
      ObjVal(:, 1) = (1+g)/2 .* prod(Chrom(:, 1:NOBJUSE-1), 2);
      for i = 2:NOBJUSE-1, ObjVal(:, i) = (1+g)/2 .* prod(Chrom(:, 1:NOBJUSE-i), 2) .* (1-Chrom(:, NOBJUSE-i+1)); end
      ObjVal(:, NOBJUSE) = (1+g)/2 .* (1-Chrom(:, 1));
      
  end

  
% End of function