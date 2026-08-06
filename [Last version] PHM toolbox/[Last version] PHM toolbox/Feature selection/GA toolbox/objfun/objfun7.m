% OBJective function for schwefel's FUNction
%
% This function implements the SCHWEFEL function 7.
%
% Syntax:  ObjVal = objfun7(Chrom, option)
%
% Input parameters:
%    Chrom     - Matrix containing the chromosomes of the current
%                population. Each row corresponds to one individual's
%                string representation.
%                if Chrom == [], then speziell values will be returned
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
% See also: objfun1, objfun1a, objfun1b, objfun2, objfun6, objfun8, objfun9, objfun10

% Author:   Hartmut Pohlheim
% History:  27.11.1993  file created
%           30.11.1993  show Dim in figure titel
%           01.03.1994  name changed in obj*
%           17.02.1995  direct Dim removed and function cleaned
%           05.01.2004  function also works with 1 dimension (changed sum statement)


function ObjVal = objfun7(Chrom, option);

% Compute population parameters
   [Nind, Nvar] = size(Chrom);

% Check size of Chrom and do the appropriate thing
   % if Chrom is [], then define size of boundary-matrix and values
   if Nind == 0
      % Default dimension of objective function
      Dim = 10;
      % return text of title for graphic output
      if option == 2
         ObjVal = ['SCHWEFELs function 7'];
      % return value of global minimum
      elseif option == 3
         xmin = 420.9687;
         ObjVal = Dim * (-xmin * sin(sqrt(abs(xmin))));
      % define size of boundary-matrix and values
      else   
         % lower and upper bound, identical for all n variables        
         ObjVal = repmat([-500; 500], [1 Dim]);
      end
   % compute values of function
   else
      % function 7, sum of -xi * sin(sqrt(abs(xi))) for i = 1:Nvar (Nvar = 10)
      % n = Nvar, -500 <= xi <= 500
      % global minimum at (xi) = (420.9687) ; fmin = -n * 420.9687
      ObjVal = sum((-Chrom .* sin(sqrt(abs(Chrom)))), 2);
   end   


% End of function

