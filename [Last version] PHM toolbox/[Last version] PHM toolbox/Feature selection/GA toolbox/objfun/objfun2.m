% OBJective function for rosenbrock's FUNction
%
% This function implements the ROSENBROCK valley (DE JONG's Function 2).
%
% Syntax:  ObjVal = objfun2(Chrom, option)
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
% See also: objfun1, objfun1a, objfun1b, objfun6, objfun7, objfun8, objfun9, objfun10

% Author:   Hartmut Pohlheim
% History:  26.09.95    file created
%           17.02.95    direct Dim removed and function cleaned
%           08.10.96    second version of function added (from Schwefel)
%                          used version can be selected by switching internal parameter


function ObjVal = objfun2(Chrom, P1);

% Compute population parameters
   [Nind, Nvar] = size(Chrom);

% Check size of Chrom and do the appropriate thing
   % if Chrom is [], then reset to [NaN P1]
   if isempty(Chrom),
      if nargin < 2, P1 = []; end, if isempty(P1), P1 = 1; end
      Chrom = [NaN, P1]; Nind = 1;
   end
   % if Chrom is [NaN xxx] define size of boundary-matrix and others
   if all([Nind == 1, isnan(Chrom(1))]),
      % If only NaN is provided
      if length(Chrom) == 1, option = 1; else option = Chrom(2); end
      % Default dimension of objective function
      Dim = 10;
      % return text of title for graphic output
      if option == 2, ObjVal = ['ROSENBROCKs function 2'];
      % return value of global minimum
      elseif option == 3, ObjVal = 0;
      % define size of boundary-matrix and values
      else   
         % lower and upper bound, identical for all n variables        
         ObjVal = repmat([-2; 2], [1 Dim]);
      end

   % compute values of function
   else
      CommonVersion = 1;
      if CommonVersion == 1,
         % commonly used version
         % function 2, sum of 100 * (x(i+1) -xi^2)^2+(1-xi)^2 for i = 1:Nvar (Nvar = 10)
         % n = Nvar, -10 <= xi <= 10
         % global minimum at (xi) = (1) ; fmin = 0
            Mat1 = Chrom(:, 1:Nvar-1);
            Mat2 = Chrom(:, 2:Nvar);
            if Nvar == 2, ObjVal = 100 * (Mat2 - Mat1.^2).^2 + (1 - Mat1).^2;
            else     ObjVal = sum((100 * (Mat2 - Mat1.^2).^2 + (1 - Mat1).^2)')'; end   
      else
         % easier version (from Schwefel,H.-P.: Evolution and Optimum Seeking (1995, p.343)
         % function 2, sum of 100 * (x(i+1) -xi^2)^2+(1-xi)^2 for i = 1:Nvar (Nvar = 10)
         % n = Nvar, -10 <= xi <= 10
         % global minimum at (xi) = (1) ; fmin = 0
         Mat1 = Chrom(:, 2:Nvar);
         Mat2 = repmat(Chrom(:, 1), [1, Nvar-1]);
         if Nvar == 2, ObjVal = 100 * (Mat2 - Mat1.^2).^2 + (1 - Mat1).^2;
         else     ObjVal = sum((100 * (Mat2 - Mat1.^2).^2 + (1 - Mat1).^2)')';
         end   
      end
   end   


% End of function

