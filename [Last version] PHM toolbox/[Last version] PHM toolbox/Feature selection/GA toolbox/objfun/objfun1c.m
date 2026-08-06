% OBJective function for moved axis parallel hyper ellipsoid 1c
%
% This function implements the POHLHEIM function 1c.
%
% Syntax:  ObjVal = objfun1c(Chrom, option)
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
% See also: objfun1a, objfun1b, objfun2, objfun6, objfun7, objfun8, objfun9, objfun10, initfun1

% Author:   Hartmut Pohlheim
% History:  15.05.97    file created
%           27.01.98    small changes in definition of function (opt at 5*1:Nvar)
%                          for a better looking and distingishable visualization


function ObjVal = objfun1c(Chrom, option, P1);

% Compute population parameters
   [Nind, Nvar] = size(Chrom);

% Check size of Chrom and do the appropriate thing
   % if Chrom is [], then define size of boundary-matrix and values
   if Nind == 0
      % Default dimension of objective function
      Dim = 20;
      % return text of title for graphic output
      if option == 2
         ObjVal = ['Moved axis parallel hyper-ellipsoid 1c'];
      % return value of global minimum
      elseif option == 3
         ObjVal = 0;
      % define size of boundary-matrix and values
      else   
         % lower and upper bound, identical for all n variables        
         ObjVal = repmat([-500; 500], [1 Dim]);
      end
   % compute values of function
   else
      % function 1c, sum of (i.*(xi-5*i))^2 for i = (1:Nvar) (Nvar = 20)
      % n = Nvar, -500 <= xi <= 500
      % global minimum at (xi) = 5*(1:Nvar) ; fmin = 0
      Chrom = Chrom - 5 * repmat([1:Nvar], [Nind, 1]);
      Chrom = Chrom .* repmat([1:Nvar], [Nind, 1]);
      ObjVal = sum((Chrom .^2)')';
      % ObjVal = [sum((Chrom .^2)')', sum((Chrom)')', sum((abs(Chrom))')'];
   end   


% End of function
