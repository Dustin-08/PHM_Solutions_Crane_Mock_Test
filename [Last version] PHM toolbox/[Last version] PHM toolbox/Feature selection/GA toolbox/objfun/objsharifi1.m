% OBJective function for 5-x1^2-2*x2^2-x1
%
% This function implements an example.
%
% Syntax:  ObjVal = objsharifi1(Chrom, P1, P2)
%
% Input parameters:
%    Chrom     - Matrix containing the chromosomes of the current
%                population. Each row corresponds to one individual's
%                string representation.
%                if Chrom == [NaN xxx], then special values will be returned
%                xxx == 1 (or []) return boundaries
%                xxx == 2 return title
%                xxx == 3 return value of global minimum
%    P1, P2    - Additional parameter
%
% Output parameters:
%    ObjVal    - Column vector containing the objective values of the
%                individuals in the current population.
%                if called with Chrom == [NaN xxx], then ObjVal contains
%                xxx == 1, matrix with the boundaries of the function
%                xxx == 2, text for the title of the graphic output
%                xxx == 3, value of global minimum
%                
% See also: objfun1a, objfun1b, objfun2, objfun6, objfun7, objfun8, objfun9, objfun10, initfun1

% Author:   Hartmut Pohlheim
% History:  29.07.2005  file created


function ObjVal = objsharifi1(Chrom, P1, P2);

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
      Dim = 2;
      % return text of title for graphic output
      if option == 2, ObjVal = ['SHARIFIs example 1'];
      % return value of global minimum
      elseif option == 3, ObjVal = 0;
      % define size of boundary-matrix and values
      else   
         % lower and upper bound, identical for all n variables        
         ObjVal = repmat([-25; 35], [1 Dim]);
      end

   % compute values of function
   else
      % example 1, 5-x1^2-2*x2^2-x1
      % n = Nvar, -25 <= xi <= 35
      % global minimum at (xi) = ??, fmin = ??
      x1 = Chrom(:,1);
      x2 = Chrom(:,2);
      ObjVal = 5 - x1.^2 - 2*x2.^2 - x1;
   end   


% End of function

