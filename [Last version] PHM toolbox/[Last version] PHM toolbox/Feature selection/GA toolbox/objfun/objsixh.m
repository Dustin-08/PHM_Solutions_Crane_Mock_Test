% OBJective function for SIX Hump camelback function
%
% This function implements the six hump camelback function.
%
% Syntax:  ObjVal = objsixh(Chrom, option)
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
% See also: objbran, objeaso, objgold, obj*

% Author:     Hartmut Pohlheim
% History:    25.11.93     file created
%             27.11.93     text of title and option added
%             16.12.93     option == 3, return value of global minimum
%             01.03.94     name changed in obj*
%             17.02.95     function cleaned

function ObjVal = objsixh(Chrom, option);

% Compute population parameters
   [Nind, Nvar] = size(Chrom);

% Check size of Chrom and do the appropriate thing
   % if Chrom is [], then define size of boundary-matrix and values
   if Nind == 0
      % return text of title for graphic output
      if option == 2
         ObjVal = 'Six-hump camelback function';
      % return value of global minimum
      elseif option == 3
         ObjVal = -1.0316;
      % define size of boundary-matrix and values
      else   
         %         x1 x2
         ObjVal = [-3 -2;  % lower bounds
                    3  2]; % upper bounds
      end
   % if two variables, compute values of function
   elseif Nvar == 2
      % six-hump camelback function
      % -3 <= x1 <= 3 ; -2 <= x2 <= 2
      % global minimum at (x1, x2) = (-0.0898, 0.7126), (0.0898, -0.7126) ; fmin = -1.0316
      x1 = Chrom(:,1);
      x2 = Chrom(:,2);
      ObjVal = (4-2.1*x1.^2+1/3*x1.^4).*x1.^2+x1.*x2+(-4+4*x2.^2).*x2.^2;
   % otherwise error, wrong format of Chrom
   else
      error('size of matrix Chrom is not correct for function evaluation');
   end   


% End of function

