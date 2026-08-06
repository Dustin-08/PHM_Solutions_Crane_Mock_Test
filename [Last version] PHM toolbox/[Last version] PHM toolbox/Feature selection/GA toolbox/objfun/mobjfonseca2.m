% Multi-OBJective function: FONSECA's MO-function 2
%
% This function implements FONSECA's multiobjective function 2.
% Fonseca, Carlos and Fleming, Peter: Multiobjective Genetic Algorithms
% Made Easy: Selection, Sharing, and Mating Restriction." Proceedings of 
% the 1st International Conference on Genetic Algorithms in Engineering 
% Systems: Innovations and Applications GALESIA'95, pp. 45-52, IEEE, 1995.
%
% Pareto Properties:
% Ptrue connected, PFtrue connected and concave, analytical solution known
%
% Syntax:  ObjVal = mobjfonseca2(Chrom)
% 
% For Input and Output parameters see objfun1.
%                
% See also: objfun1, objfunoptset, mobjfonseca1

% Author:   Hartmut Pohlheim
% History:  05.05.2002  file created


function ObjVal = mobjfonseca2(Chrom);

   if nargin < 1, Chrom = []; end
   if isnan(Chrom), Chrom = []; end
   if isempty(Chrom), Chrom = [NaN, NaN, 1]; end
   ObjVal = [];
   
   % Create option-structure
   if isnan(Chrom(1,1)), 
      if isnan(Chrom(1,2)),
         if Chrom(1,3) <= 10,
           ObjVal = objfunoptset( 'FunctionName', 'FONSECAs MO-Function 2' ...
                                , 'VarBoundMin', -4, 'VarBoundMax', 4 ...
                                , 'NumVarDefault', 2, 'NumVarMin', 2, 'NumVarMax', Inf ...
                                , 'NumObjDefault', 2, 'NumObjMin', 2, 'NumObjMax', 2 ...
                                );
         end
      end

   % Calculate objective values
   else
      % FONSECA function 2, objv1 = 1-exp(-sum((xi-1/(sqrt(Dim)).^2)));
      %                     objv2 = 1-exp(-sum((xi+1/(sqrt(Dim)).^2)));
      %                     for i = 1:Nvar (Nvar = n), -2 <= xi <= 2
      ObjVal = [1 - exp(-(sum((Chrom - 1/(sqrt(size(Chrom, 2)))).^2, 2))), ...
                1 - exp(-(sum((Chrom + 1/(sqrt(size(Chrom, 2)))).^2, 2)))];
   end


% End of function