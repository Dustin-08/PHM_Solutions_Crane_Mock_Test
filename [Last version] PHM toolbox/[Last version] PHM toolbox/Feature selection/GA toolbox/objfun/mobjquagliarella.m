% MultiObjective Problem: QUAGLIARELLA's function
%
% This function implements QUAGLIARELLAS's multiobjective function
% (also known as Multiobjective Rastrigin Function).
%
% Quagliarella, Domenico and Alessandro Vicini: "Subpopulation Policies for a 
% Parallel Multiobjective Genetic Algorithm with Applications to Wing Design."
% In DiCesare, Frank and Mohsen Jafari (ed.), Proceedings of the 1998 IEEE
% International Conference on Systems, Man and Cybernetics, pp. 3142-3147, 1998.
%
% MO properties: Ptrue disconnected, PFtrue convex
%
% Syntax:  ObjV = mobjquagliarella(Chrom)
%
% For Input and Output parameters see objfun1.
%                
% See also:  mobjfonseca1, objfun1, mobjdtlz1

% Author:   Hartmut Pohlheim
% History:  16.01.2005  file created


function ObjVal = mobjquagliarella(Chrom);

   % Compute population parameters
   [Nind, Nvar] = size(Chrom);

   if nargin < 1, Chrom = []; end
   if isnan(Chrom), Chrom = []; end
   if isempty(Chrom), Chrom = [NaN, NaN, 1]; end
   persistent NOBJUSE;
   
   % create structure
   if isnan(Chrom(1)),
      if all([isnan(Chrom(2)), Chrom(3) <= 10]),
         ObjVal = objfunoptset('FunctionName', 'QUAGLIARELLAs MO-Function', ...
                               'VarBoundMin',  -5.12, 'VarBoundMax', 5.12, ...
                               'NumVarDefault', 2,    'NumVarMin',   2, 'NumVarMax', Inf, ...
                               'NumObjDefault', 2,    'NumObjMin',   1, 'NumObjMax', Inf);
      elseif Chrom(3) == 11,
          NOBJUSE = Chrom(4);
      end
   % compute values of function
   else
      if isempty(NOBJUSE), NOBJUSE = 2; end
      Null = rand(NOBJUSE, 1) * 10;
      
      % F(X) = f1(X), f2(X), ..., fn(X),     for n >= 2,
      % f1(X) = sqrt(sum(x(i)
      
      % original Values by Quagliarella and Vicini
      Null([1, 2]) = [0 1.5];
       
      Null = repmat(Null', [size(Chrom, 1) 1 size(Chrom, 2)]);

      Chrom = repmat(Chrom', [1 1 NOBJUSE]);
      Chrom = shiftdim(Chrom, 1);

      ObjVal = sqrt(sum((Chrom-Null).^2 - 10 * cos(2*pi*(Chrom-Null)) + 10, 3) / size(Chrom, 2));
   end

   
% End of function