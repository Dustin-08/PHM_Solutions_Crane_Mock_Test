% OBJective function for BRANin rcos function
%
% This function implements the BRANIN RCOS function.
%
% Syntax:  ObjVal = objbran(Chrom, option)
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
% See also: objeaso, objsixh, objgold, obj*

% Author:     Hartmut Pohlheim
% History:    25.11.93     file created
%             27.11.93     text of title and option added
%             16.12.93     option == 3, return value of global minimum
%             01.03.94     name changed in obj*
%             17.02.95     function cleaned

function ObjVal = objbran(Chrom, option);

% Compute population parameters
   [Nind, Nvar] = size(Chrom);

% Check size of Chrom and do the appropriate thing
   % if Chrom is []
   if Nind == 0
      % return text of title for graphic output
      if option == 2
         ObjVal = 'BRANINs RCOS function';
      % return value of global minimum
      elseif option == 3
         ObjVal = 0.397887;
      % define size of boundary-matrix and values
      else   
         %         x1 x2
         ObjVal = [-5  0;  % lower bounds
                   10 15]; % upper bounds
      end            
   % if two variables, compute values of function
   elseif Nvar == 2
      % BRANIN's RCOS function
      % -5 <= x1 <= 10 ; 0 <= x2 <= 15
      % global minimum at (x1,x2)=(-pi,12.275), (pi,2.275), and
      %                           (9.42478,2.475) ; fmin=0.397887
      x1 = Chrom(:,1);
      x2 = Chrom(:,2);
      ObjVal = 1*(x2-(5.1/(4*pi^2))*x1.^2+(5/pi)*x1-6).^2+10*(1-(1/(8*pi))).*cos(x1)+10;
   % otherwise error, wrong format of Chrom
   else
      error('size of matrix Chrom is not correct for function evaluation');
   end   


% End of function

