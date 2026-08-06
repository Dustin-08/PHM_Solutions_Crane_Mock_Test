% OBJective function for INT function 1
%
% This function implements the ONEMAX function 1.
% This is an example function. The objective is not
% really useful.
%
% Syntax:  [ObjVal, Nind, Nvar] = objint1(Chrom, option)
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


function ObjVal = objint1(Chrom, option);

% Compute population parameters
   [Nind, Nvar] = size(Chrom);

% Default dimension of objective function
   DimInt = 50;           % Number of integer variables
   PrecInt = 10;          % Precision of every integer variable: here 10 bit per integer number
   Dim = DimInt * PrecInt;    % Number of binary variables
% Lower and upper bound, identical for all n variables
   VLUB = repmat([0; 1000], [1 DimInt]);

% Check size of Chrom and do the appropriate thing
   % if Chrom is [], then define size of boundary-matrix and values
   if Nind == 0
      % return text of title for graphic output
      if option == 2
         ObjVal = ['INTeger function 1'];
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
      % Check for parameter consistency
      if Nvar ~= Dim, disp('inside error'); error('Chrom and Dim disagree!'); end

      % Create matrix for conversion of binary values to integer
      VLUBint = [repmat([PrecInt],[1, Nvar/PrecInt]); VLUB; repmat([1; 0; 1 ;1], [1, Nvar/PrecInt])];

      % Convert binary values to integer
      ChromNeu = bin2int(Chrom, VLUBint);

      % function INTMAX 1, sum of xi for i = 1:Nvar
      % n = Nvar, xi in [0, ???] (integer)
      % global minimum at (xi) = (max);
      ObjVal = -sum((ChromNeu)')'
   end   


% End of function

