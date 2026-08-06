% OBJective function 1 for live introduction of EA optimization in lecture
%
% This function implements a polynomial function with multiple minima.
% It was implemented for the optimization introduction part in an EA
% lecture. Thus, do not interprete the results, just look at the 
% 2-dimensional plot of this function (using plotmesh)
%
% Syntax:  ObjVal = objlive2(Chrom)
%
% Input parameters:
%    see objfun1 for a full explanation
%
% Output parameters:
%    see objfun1 for a full explanation
%                
% See also: objfun1

% Author:  Hartmut Pohlheim
% History: 26.05.2002   file created


function ObjVal = objlive2(Chrom, P1);

% Compute population parameters
   [Nind, Nvar] = size(Chrom);
   if nargin < 2, P1 = []; end

% Check size of Chrom and do the appropriate thing
   % if Chrom is [], then reset to [NaN P1]
   if isempty(Chrom),
      if nargin < 2, P1 = []; end, if isempty(P1), P1 = 1; end
      Chrom = [NaN, P1]; Nind = 1; P1 = [];
   end
   
   if isempty(P1), P1 = 0; end
   
   % if Chrom is [NaN xxx] define size of boundary-matrix and others
   if all([Nind == 1, isnan(Chrom(1))]),
      % If only NaN is provided
      if length(Chrom) == 1, option = 1; else option = Chrom(2); end
      % Default dimension of objective function
      Dim = 2;
      % return text of title for graphic output
      if option == 2, 
         if P1 == 1, ObjVal = ['SW-RunTime PowerPC 600MHz'];
         else ObjVal = ['SW-RunTime PowerPC 400MHz']; end
      % return value of global minimum
      elseif option == 3, ObjVal = 0;
      % define size of boundary-matrix and values
      else   
         % lower and upper bound, identical for all n variables        
         ObjVal = repmat([-20; 40], [1 Dim]);
      end

   % compute values of function
   else
      % function taken from life :-), sum of crude things
      % n = Nvar, -20 <= xi <= 40
      % global minimum at (xi) = ??? ; fmin = ???
      if P1 == 0, ObjVAdd = 27;
      else ObjVAdd = 29.5; end
      
      variant = 0;
      Par1 = -1.32; Par2 = 0.73; Par3 = -1.84; Par4 = 4.3;
      Chrom = -Chrom .* repmat(linspace(1, (1+Nvar)/2, Nvar), [Nind, 1]);
      if variant == 0,
         ObjVal = ObjVAdd + sum((Chrom./3+Par1).^4 + (Chrom./1.12+Par2).^3 + 2.*(Chrom+Par3).^2 + Par4, 2);
      else
         ObjVal = zeros(Nind, 1);
      end
   end   


% End of function

% x1 = [-20:1:-10, -9.5:.5:30, 31:1:40]';
% x2 = [-10:1:20]';
% for ix = 1:length(x2), ox(:,ix) = objlive1([x1, repmat(x2(ix), [length(x1), 1])]); end;
% os=sprintf('%8.0f\n', x2); for ix = 1:length(x1), os=[os, sprintf('%10.1f   %s\n', x1(ix), sprintf('%8.0f', ox(ix,:)) )]; end
