% OBJective function RIDGE
%
% This function implements the coninuous and discrete variant of the
% Ridge function. The global minimum is a narrow ridge along the axis
% of the first variable. 
%
% This function was defined as stepfun5 function in:
%   Jain, Clusterbasierte Abbruchkriterien fuer den Evolutionaeren Test. 
%     Diploma-thesis, Technical University of Berlin, Department of 
%     Computer Science, chapter 5.1, 1999.
% in order to investigate the behaviour of clusterbased termination 
% criteria in narrow ridges.
%
% Syntax: ObjVal = objridge(Chrom, P1, P2)
%
% Input parameters:
%    Chrom     - Matrix containing the chromosomes of the current
%                population. Each row corresponds to one individual's
%                string representation.
%                If Chrom == [NaN xxx]  or 
%                   Chrom == [NaN xxx yyy], 
%               then special values will be returned, see Output parameters
%                   xxx == 1 (or []) return boundaries
%                   xxx == 2 return title 
%                      yyy == 0 return title of continuous variant
%                      yyy == 1 return title of discrete variant
%                   xxx == 3 return value of global minimum
%    P1        - (Optional) Number indicating which variant is used,
%                if Chrom is not NaN or []. 
%                   P1 = 1  use discrete version
%                   P1 = 0  use continuous version
%                If P1 is omitted or P1 = [] the discrete version 
%                   is used (P1 = 1).
%    P2        - Additional parameter
%
% Output parameters:
%    ObjVal    - Column vector containing the objective values of the
%                individuals in the current population.
%                if called with 
%                   Chrom == [NaN xxx] or Chrom == [NaN xxx yyy], 
%                then ObjVal contains
%                   xxx == 1 (or []), matrix with the boundaries of 
%                                     the varaibles
%                   xxx == 2, text with the title of the function
%                      yyy omitted: title of continuous variant
%                      yyy = 0      title of continuous variant
%                      yyy = 1      title of discrete variant
%                   xxx == 3, value of global minimum
%
% Examples:
%
%  % continuous variant of the Four-Wings function
%  >> objridge(Chrom)
%
%  % discrete variant of the Four-Wings function
%  >> objridge(Chrom, 1)

% Author:   Hartmut Pohlheim
% History:  08.11.99    file created


function ObjVal = objridge(Chrom, P1, P2)

% Compute population parameters
   [Nind, Nvar] = size(Chrom);

% Define default values
   doDiscr = 1;      % use discrete variant

% Check size of Chrom and do the appropriate thing
   % if Chrom is [], then reset to [NaN P1], P2
   if isempty(Chrom),
      if nargin < 2, P1 = []; end, if isempty(P1), P1 = 1; end
      if nargin < 3, P2 = []; end, if isempty(P2), P2 = doDiscr; end
      Chrom = [NaN, P1]; P1 = P2; Nind = 1;
   end

   % check the additional parameters
   if nargin < 2, P1 = []; end, if isempty(P1), P1 = doDiscr; end, if P1 == 0, doDiscr = 0; end

   % if Chrom is [NaN xxx] define size of boundary-matrix and others
   if all([Nind == 1, isnan(Chrom(1))]),
      % If only NaN is provided
      if length(Chrom) == 1, option = 1; 
      else                   option = Chrom(2); end
      % Default dimension of objective function
      Dim = 10;
      % return text of title for graphic output
      if option == 2, 
         ObjVal = ['Ridge function'];
         if doDiscr == 1, ObjVal = [ObjVal, ' (discrete)']; end
      % return value of global minimum
      elseif option == 3, ObjVal = 0;
      % define size of boundary-matrix and values
      else   
         % lower and upper bound, identical for all n variables        
         ObjVal = repmat([-50; 50], [1 Dim]);
      end

  % compute values of function
   else,
      % Ridge : 
      %  f: R^n --> N, x -> f(x)
      %  let yi = ceil(|xi| + 1); for i = 1:Nvar  (ceil and +1 only for discrete variant)
      %  let zi = prod of yi; for i = 1:Nvar   
      %  f = ceil( sqrt(zi) )   (ceil only for discrete variant)
      %  n = Nvar, -500 <= xi <= 500
      %  global minimum at (0,x2,...,x_Nvar); fmin = 0
      I = find(Chrom(:,1) == 0);
      if doDiscr == 1, Chrom = ceil(abs(Chrom)+1); else Chrom = abs(Chrom); end
      ObjVal = sqrt(prod(Chrom')');
      if doDiscr == 1, ObjVal = ceil(ObjVal); end
      ObjVal(I) = 0;
   end


% End of function