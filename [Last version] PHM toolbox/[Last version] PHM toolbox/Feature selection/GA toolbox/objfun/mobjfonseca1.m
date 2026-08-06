% Multi-OBJective function: FONSECA's MO-function 1
%
% This function implements FONSECA's multiobjective function 1.
% Fonseca, Carlos and Fleming, Peter: An Overview of Evolutionary Algorithms
% in Multiobjective Optimization. Evolutionary Computation, 3(1):1-16,
% Springer-Verlag, 1995.
%
% Pareto Properties:
% Ptrue connected, PFtrue connected and concave
%
% Syntax:  ObjVal = mobjfonseca1(Chrom)
% 
% For Input and Output parameters see objfun1.
%                
% See also: objfun1, objfunoptset, mobjfonseca2

% Author:   Hartmut Pohlheim
% History:  05.05.2002  file created


function ObjVal = mobjfonseca1(Chrom);

   if nargin < 1, Chrom = []; end
   if isnan(Chrom), Chrom = []; end
   if isempty(Chrom), Chrom = [NaN, NaN, 1]; end
   ObjVal = [];
   
   % Create option-structure
   if isnan(Chrom(1,1)), 
      if isnan(Chrom(1,2)),
         if Chrom(1,3) <= 10,
           ObjVal = objfunoptset( 'FunctionName', 'FONSECAs MO-Function 1' ...
                                , 'VarBoundMin', -4, 'VarBoundMax', 4 ...
                                , 'NumVarDefault', 2, 'NumVarMin', 2, 'NumVarMax', 2 ...
                                , 'NumObjDefault', 2, 'NumObjMin', 2, 'NumObjMax', 2 ...
                                );
         end
      end

   % Calculate objective values
   else
      % FONSECA function 1, 1-exp(-((x(i)-1)^2)-((y(i)+1)^2));
      %                     1-exp(-((x(i)+1)^2)-((y(i)-1)^2));
      %                     for i = 1:Nvar (Nvar = 2), -4 <= xi <= 4
      ObjVal = [1 - exp(-((Chrom(:,1) - 1).^2) - ((Chrom(:,2) + 1).^2)), ...
                1 - exp(-((Chrom(:,1) + 1).^2) - ((Chrom(:,2) - 1).^2))];
   end


% End of function