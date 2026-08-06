% OBJective function for INT function 4
%
% This function implements the INTTarget function 4.
% This is an example function.
% The objective is to find the target vector.
%
% Syntax:  [ObjVal] = objint4(Chrom, option)
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

% Author:     Hartmut Pohlheim
% History:    17.10.97     file created


function ObjVal = objint4(Chrom, option);

% Compute population parameters
   [Nind, Nvar] = size(Chrom);

% Define a target vector
   DefaultDim = 20;
   Target = [1:Nvar];

% Check size of Chrom and do the appropriate thing
   % if Chrom is [], then define size of boundary-matrix and values
   if Nind == 0
      % Default dimension of objective function
         Dim = DefaultDim;
      % return text of title for graphic output
      if option == 2
         ObjVal = ['INTeger Target function 4'];
      % return value of global minimum
      elseif option == 3
         ObjVal = 0;    % not correct
      % define size of boundary-matrix and values
      else   
         % lower and upper bound, identical for all n variables
         ObjVal = repmat([-10*DefaultDim; 10*DefaultDim], [1 Dim]);
         % ObjVal = [   0    1    0    0    1;
         %           1023  511 1023  255  256];
      end
   % compute values of function
   else
      % function INTTarget 4, sum of abs(x(i) - Target(i)) for i = 1:Nvar
      % global minimum at (xi) = Target;
      ObjVal = sum(abs(Chrom - repmat(Target, [Nind, 1]))')';
   end   


% End of function

