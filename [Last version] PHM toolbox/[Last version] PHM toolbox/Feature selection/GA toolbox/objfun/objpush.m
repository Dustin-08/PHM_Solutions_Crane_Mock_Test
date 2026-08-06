% OBJective function for PUSH-cart problem
%
% This function implements the PUSH-CART PROBLEM.
%
% Syntax:  ObjVal = objpush(Chrom, option)
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
% See also: objdopi, objharv, objlinq

% Author:     Hartmut Pohlheim
% History:    19.02.94     file created (copy of valharv.m)
%             01.03.94     name changed in obj*
%             17.02.95     direct Dim removed and function cleaned

function ObjVal = objpush(Chrom, option);

% Dimension of objective function
   Dim = 20;

% values from MICHALEWICZ
   x0 = [0 0];
   
% Compute population parameters
   [Nind, Nvar] = size(Chrom);

% Check size of Chrom and do the appropriate thing
   % if Chrom is [], then define size of boundary-matrix and values
   if Nind == 0
      % Default dimension of objective function
      Dim = 20;
      % return text of title for graphic output
      if option == 2
         ObjVal = ['PUSH-CART PROBLEM'];
      % return value of global minimum
      elseif option == 3
         ObjVal = -(1/3 - ((3*Dim-1)/(6*Dim^2)) - (1/(2*Dim^3))*sum((1:Dim-1).^2));
      % define size of boundary-matrix and values
      else   
         % lower and upper bound, identical for all n variables        
         ObjVal = repmat([0; 5], [1 Dim]);
      end
   % if Dim variables, compute values of function
   else
      ObjVal = zeros(Nind, 1);
      X = repmat(x0, [Nind 1]);
      for irun = 1:Nvar,
         Xsave = X;
         X(:,1) = Xsave(:,2);
         X(:,2) = 2 * X(:,2) - Xsave(:,1) + (1 / Nvar^2) * Chrom(:,irun);
      end
      ObjVal = -(X(:,1) - (1 / (2 * Nvar)) * sum((Chrom.^2)')');
   end   


% End of function

