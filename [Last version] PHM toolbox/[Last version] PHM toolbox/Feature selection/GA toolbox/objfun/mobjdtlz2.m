% MultiObjective Function: Deb, Thiele, Zitzler, Laumanns' multiobjective function 2
%
% Kalyanmoy Deb, Eckart Zitzler, Lothar Thiele and Marco Laumanns:
% Scalable Test Problems for Evolutionary Multi-Objective Optimization.
%
% Pareto Properties:
% Ptrue connected, PFtrue convex
%
% The number of variables per individual must be at least 2 more
% than the number of objectives. Suggested is NVar = NObj + 4 and more.
%
% Syntax:  ObjVal = mobjdtlz2(Chrom)
%
% For Input and Output parameters see objfun1.
%
% See also: mobjfonseca1, objfun1, mobjdtlz1, mobjdtlz3

% Author:   Hartmut Pohlheim
% History:  08.08.2001  file created
%           11.09.2001  update to V3.4
%           08.05.2005  formatting changed


function ObjVal = mobjdtlz2(Chrom);

   NAIN = nargin; NAOUT = nargout;

   if NAIN < 1, Chrom = []; end
   if isnan(Chrom), Chrom = []; end
   if isempty(Chrom), Chrom = [NaN, NaN, 1]; end
   persistent NOBJUSE
   
   % create structure
   if isnan(Chrom(1)),
       if all([isnan(Chrom(2)), Chrom(3) <= 10]),
           ObjVal = objfunoptset(...
               'FunctionName', 'DTLZ-MO-Function 2', ...
               'VarBoundMin', 0, 'VarBoundMax', 1, ...
               'NumVarDefault', 5, 'NumVarMin', 3, 'NumVarMax', Inf, ...
               'NumObjDefault', 3, 'NumObjMin', 3, 'NumObjMax', Inf);
       elseif Chrom(3) == 11, NOBJUSE = Chrom(4); end
   else
       if isempty(NOBJUSE), NOBJUSE = 3; end
      
      % Relation between Amount of Variables and Objectives:
      % NVar = NOBJUSE + k - 1
      % The Authors suggest k=5.
      
      % F (xi) = (f1(xi), f2(xi), ..., fM(xi))
      % f1(xi) = (1 + g(x(1)...x(M))) * prod(cos((x(1)...x(M-1)) *pi/2))
      % f2(xi) = (1 + g(x(1)...x(M))) * prod(cos((x(1)...x(M-2)) *pi/2)) * sin(x(M-1) *pi/2)
      %                                    :
      %                                    :
      %                                    :
      % fM-1(xi) = (1 + g(x(1)...x(M))) * cos(x(1) *pi/2) * sin(x(2) *pi/2)
      % fM(xi) = (1 + g(x(1)...x(M))) * sin(x(1) *pi/2)
      % for i=1:NVar
      
      % g(x(1)...x(M)) = sum((x(i)-0.5)^2), i=1:M
      
      % function g(Chrom) suggested by DTLZ:
      g = sum((Chrom-0.5).^2, 2);
      
      ObjVal(:, 1) = (1+g) .* prod(cos(Chrom(:, 1:NOBJUSE-1) * pi/2), 2);
      for i = 2:NOBJUSE-1
          ObjVal(:, i) = (1+g) .* prod(cos(Chrom(:, 1:NOBJUSE-i) * pi/2), 2) .* sin(Chrom(:, NOBJUSE-i+1) * pi/2);
      end
      ObjVal(:, NOBJUSE) = (1+g) .* sin(Chrom(:, 1) * pi/2);
      
  end


% End of function