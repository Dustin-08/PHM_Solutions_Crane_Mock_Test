% OBJective function for INT function 3
%
% This function implements x^2 + (y-0.4)^2, where x and y are
% discrete real variables, say x=y=(0.2,0.4,0.6,0.8).
%
% Syntax:  [ObjVal, Nind, Nvar] = objint3(Chrom, option)
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
% See also: objfun1, objone1, objint1, objint2, scrint1

% Author:     Hartmut Pohlheim
% History:    12.06.96     file created


function ObjVal = objint3(Chrom, option);

% Compute population parameters
   [Nind, Nvar] = size(Chrom);

% Check size of Chrom and do the appropriate thing
   % if Chrom is [], then define size of boundary-matrix and values
   if Nind == 0
      % Default dimension of objective function
         Dim = 2;
      % return text of title for graphic output
      if option == 2
         ObjVal = ['INTeger example function 3 (x^2 + (y-0.4)^2)'];
      % return value of global minimum
      elseif option == 3
         ObjVal = 0;
      % define size of boundary-matrix and values
      else   
         % lower and upper bound for the two variables
         % willbe multiplied with 0.2 later
         ObjVal = [ -20  -20;
                     20   20];
      end
   % compute values of function
   else
      % function INTMAX 3, (x^2 + (y-0.4)^2)
      % x and y in [0.2,0.4,0.6,0.8,...] (discrete)
      % global minimum at (xi) = (???);
      Chrom = Chrom .* 0.2;
      ObjVal = (Chrom(:,1).^2 + (Chrom(:,2)-0.4).^2);
   end   


% End of function

