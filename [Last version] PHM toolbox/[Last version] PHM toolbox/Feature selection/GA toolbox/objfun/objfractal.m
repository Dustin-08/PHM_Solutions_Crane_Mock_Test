% OBJective function Fractal Mandelbrot
%
% This function implements a fractal function and its discretization.
% The Fractal function is highly multimodal and emulates noisy 
% real-world objective functions.
%
% The objective function is obtained by an approximation of the 
% simplified real part C(x) of the Weierstrass-Mandelbrot function.
% C(x) is continuous but has no derivative at any point. With the
% box-dimension BoxDim (1 < BoxDim < 2) of this function the ruggedness
% of the surface can be controlled. Higher values for BoxDim increase
% the complexity of this objective function and vice versa.
%
% The Weierstrass-Mandelbrot function is described in:
%    Mandelbrot, B.B. The fractal geometry of nature. 
%       New York: Freeman, 1983.
%
% Syntax: ObjVal = objfractal(Chrom, P1, P2)
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
%                If P1 is omitted or P1 = [] the continuos version 
%                   is used (P1 = 0).
%    P2        - (Optional) Scalar containing the box dimension BoxDim 
%                (1 < BoxDim < 2) of this objective function.
%                 If P2 is omitted, empty or out of range, then the
%                    default value BoxDim = 1.85 is used.
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
%  % continuous variant of the Fractal function with default box
%  % dimension BoxDim = 1.85
%  >> objfractal(Chrom)
%
%  % discrete variant of the Fractal function with default box
%  % dimension BoxDim = 1.85
%  >> objfractal(Chrom, 1)
%
%  % discrete variant of the Fractal function with box dimension
%  % BoxDim = 1.4.
%  >> objfractal(Chrom, 1, 1.4)

% Author:   Hartmut Pohlheim
% History:  08.11.99    file created


function ObjVal = objfractal(Chrom, P1, P2)

% Compute population parameters
   [Nind, Nvar] = size(Chrom);

% Define default values
   doDiscr = 0;      % use discrete variant
   BoxDim = 1.85;    % box dimension

% Check size of Chrom and do the appropriate thing
   % if Chrom is [], then reset to [NaN P1], P2
   if isempty(Chrom),
      if nargin < 2, P1 = []; end, if isempty(P1), P1 = 1; end
      if nargin < 3, P2 = []; end, if isempty(P2), P2 = doDiscr; end
      Chrom = [NaN, P1]; P1 = P2; P2 = BoxDim; Nind = 1;
   end

   % check the additional parameters
   if nargin < 2, P1 = []; end, if isempty(P1), P1 = doDiscr; end, if P1 == 0, doDiscr = 0; end
   % check box dimension BoxDim
   if nargin < 3, P2 = []; end, if isempty(P2), P2 = BoxDim; end
   if all([P2 > 1, P2 < 2]) BoxDim = P2; end

   % if Chrom is [NaN xxx] define size of boundary-matrix and others
   if all([Nind == 1, isnan(Chrom(1))]),
      % If only NaN is provided
      if length(Chrom) == 1, option = 1; 
      else                   option = Chrom(2); end
      % Default dimension of objective function
      Dim = 20;
      % return text of title for graphic output
      if option == 2, 
         ObjVal = ['Fractal Mandelbrot function'];
         if doDiscr == 1, ObjVal = [ObjVal, ' (discrete)']; end
      % return value of global minimum
      elseif option == 3, ObjVal = 0;
      % define size and values of variable boundary-matrix and values
      else   
         % lower and upper bound, identical for all n variables
         ObjVal = repmat([-500; 500], [1 Dim]);
      end

  % compute values of function
   else, 
      % Fractal : 
      %  f: R^n --> N, x -> f(x)
      %  let yi = round(xi); for i = 1:Nvar (Nvar = 30)  (round only for discrete variant)
      %  let C(yi) = sum of (1 - cos(yi * b^jdeep)) / b^((2-BoxDim)*jdeep) for jdeep = -100:100
      %  f = sum of round(C(yi)) for i = 1:Nvar   (round only for discrete variant) 
      %  n = Nvar, -500 <= xi <= 500
      %  global minimum at (xi) = (0) ; fmin = 0
      x = Chrom';
      if doDiscr == 1, x = round(x); end
      C = zeros(Nind, Nvar);
      b = 1.5;
      for jdeep = 1:20,
         C = C + ((1-cos((b^jdeep)*x))/b^((2-BoxDim)*jdeep))' + ...
                 ((1-cos((b^(-jdeep))*x))/b^((2-BoxDim)*(-jdeep)))';
      end
      if doDiscr == 1, C = round(C); end
      ObjVal = sum(C')';
   end


% End of function
