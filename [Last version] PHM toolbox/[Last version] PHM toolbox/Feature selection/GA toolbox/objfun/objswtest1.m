% OBJective function for de jong's FUNction 1
%
% This function implements the DE JONG function 1.
%
% Syntax:  ObjVal = objfun1(Chrom, P1, P2)
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
% History:  26.11.93    file created
%           27.11.93    text of title and P1 added
%           30.11.93    show Dim in figure titel
%           16.12.93    P1 == 3, return value of global minimum
%           01.03.94    name changed in obj*
%           17.02.95    direct Dim removed and function cleaned
%           22.06.99    parameter returning interface changed to [NaN xxx]
%                          but still compatible with old calling


function ObjVal = objfun1(Chrom, P1, P2);

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
      Dim = 20;
      % return text of title for graphic output
      if option == 2, ObjVal = ['Software Test Flag 1'];
      % return value of global minimum
      elseif option == 3, ObjVal = 0;
      % define size of boundary-matrix and values
      else   
         % lower and upper bound, identical for all n variables        
         ObjVal = repmat([-512; 512], [1 Dim]);
      end

   % compute values of function
   else
      % function 1, sum of xi^2 for i = 1:Nvar (Nvar = 30)
      % n = Nvar, -512 <= xi <= 512
      % global minimum at (xi) = (0) ; fmin = 0
      variant = 1;
      if variant == 0,
         IxTest = find(abs(Chrom) > 0.5);
         ChromNew = zeros(size(Chrom)); ChromNew(IxTest) = 6;
         ObjVal = max(ChromNew, [], 2);
      else
         ObjVal = zeros(Nind, 1);
         Res = zeros(Nind, Nvar);
         Border1 = 3;
         for ifun1 = 1:Nind*Nvar,
            if abs(Chrom(ifun1)) <= Border1,
               Res(ifun1) =  (abs(Chrom(ifun1))./3).^2.8;
            else  
               Res(ifun1) = 1 + 2 * ((2*(abs(Chrom(ifun1))./3-1)).^0.3);
            end
         end
         ObjVal = max(Res, [], 2);
      end
   end  
   
   % exportfig(gcf, 't:\ric_sm\baresel\guiding_fct','Color','gray','Format','eps','Preview','tiff')
   % plotmesh('objswtest1', [-10;10],50);shading interp; view([-51.5 18]) 


% End of function

