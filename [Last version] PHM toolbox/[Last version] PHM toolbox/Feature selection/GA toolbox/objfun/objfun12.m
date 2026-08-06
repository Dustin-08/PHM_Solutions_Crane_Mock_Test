% OBJective function for michalewicz's function 12
%
% This function implements the MICHALEWICZ function 12.
%
% Syntax:  ObjVal = objfun12(Chrom, option)
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
%                if Chrom is not empty, option can optionally contain
%                the parameter m, which defines the stepness of the edges
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
%
% Examples:
%    ObjVal = objfun12(Chrom);
%    ObjVal = objfun12(Chrom, 10);
%
% Reference:
%      

% Author:     Hartmut Pohlheim
% History:    05.10.95     file created

function ObjVal = objfun12(Chrom, option);

% Compute population parameters
   [Nind, Nvar] = size(Chrom);

% Check size of Chrom and do the appropriate thing
   % if Chrom is [], then define size of boundary-matrix and values
   if Nind == 0
      % Default dimension of objective function
      Dim = 5;
      % return text of title for graphic output
      if option == 2
         ObjVal = ['MICHALEWICZs function 12'];
      % return value of global minimum
      elseif option == 3
         if Dim == 10, ObjVal = -9.66;    % for Dim = 10
         else ObjVal = -4.687; end        % for Dim = 5
      % define size of boundary-matrix and values
      else   
         % lower and upper bound, identical for all n variables        
         ObjVal = repmat([ 0; pi], [1 Dim]);
      end
   % compute values of function
   else
      % function michalewicz
      %    -sum of (sin(Chrom) * sin(i*Chrom^2/pi)^(2*m)), i = 1:Nvar
      % 0 <= xi <= pi, m = 10
      % global minimum at (xi) = (???) ; fmin = -4.687 (for Nvar = 5)
      % check input parameter and set default value
      if nargin < 2, m = []; else m = option; end
      if isempty(m), m = 10; end
      ObjVal = -sum((sin(Chrom) .* (sin(repmat(1:Nvar,[Nind,1]).*(Chrom.^2)/pi)).^(2*m))')';
   end   


% End of function

