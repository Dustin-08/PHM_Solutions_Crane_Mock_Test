% OBJective function for ONEmax function 1
%
% This function implements the ONEMAX function 1.
%
% Syntax:  [ObjVal, Nind, Nvar] = objone1(Chrom, option)
%
% Input parameters:
%    Chrom     - Matrix containing the chromosomes of the current
%                population. Each row corresponds to one individual's
%                string representation.
%                if Chrom == [], then special values will be returned
%    option    - if Chrom == [] and
%                option == 1 (or []) return boundaries
%                option == 2 return title
%                option == 3 return value of global minimum
%
% Output parameters:
%    ObjVal    - Column vector containing the objective values of the
%                individuals in the current population.
%                if called with Chrom == [], then ObjVal contains
%                option == 1, matrix with the boundaries of the function
%                option == 2, text for the title of the graphic output
%                option == 3, value of global minimum
%                
% See also: objfun1

% Author:   Hartmut Pohlheim
% History:  23.05.95    file created


function ObjVal = objone1(Chrom, option);

% Compute population parameters
   [Nind, Nvar] = size(Chrom);

% Check size of Chrom and do the appropriate thing
   % if Chrom is [], then define size of boundary-matrix and values
   if Nind == 0
      % Default dimension of objective function
      Dim = 100;
      % return text of title for graphic output
      if option == 2
         ObjVal = ['ONEMAX function 1'];
      % return value of global minimum
      elseif option == 3
         ObjVal = -Dim;
      % define size of boundary-matrix and values
      else   
         % lower and upper bound, identical for all n variables        
         ObjVal = repmat([0; 1], [1 Dim]);
      end
   % compute values of function
   else
      % function ONEMAX 1, sum of xi == 1 for i = 1:Nvar (Nvar = 100)
      % n = Nvar, xi in [0, 1] (binary)
      % global minimum at (xi) = (1) ; fmin = Nvar
      ObjVal = -sum((Chrom)')';
   end   


% End of function

