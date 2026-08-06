% OBJective function for INT function 1
%
% This function implements the INTMAX function 1.
% This is an example function. The objective is not really useful.
%
% Syntax:  [ObjVal, Nind, Nvar] = objint2(Chrom, option)
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
% See also: objfun1, objone1

% Author:     Hartmut Pohlheim
% History:    25.03.96     file created


function ObjVal = objint2(Chrom, option);

% Compute population parameters
   [Nind, Nvar] = size(Chrom);

% Check size of Chrom and do the appropriate thing
   % if Chrom is [], then define size of boundary-matrix and values
   if Nind == 0
      % Default dimension of objective function
         Dim = 5;
      % return text of title for graphic output
      if option == 2
         ObjVal = ['INTeger maximum function 2'];
      % return value of global minimum
      elseif option == 3
         ObjVal = -Dim;    % not correct
      % define size of boundary-matrix and values
      else   
         % lower and upper bound, identical for all n variables
         % ObjVal = repmat([0; 1000], [1 Dim]);
         ObjVal = [   0    1    0    0    1;
                   1023  511 1023  255  256];
      end
   % compute values of function
   else
      % function INTMAX 1, sum of xi for i = 1:Nvar
      % n = Nvar, xi in [0, ???] (integer)
      % global minimum at (xi) = (max);
      ObjVal = -sum((Chrom)')';
   end   


% End of function

