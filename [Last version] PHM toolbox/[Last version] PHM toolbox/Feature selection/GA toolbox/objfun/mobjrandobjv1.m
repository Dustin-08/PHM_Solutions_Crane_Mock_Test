% MultiObjective Problem: Pohlheim-Bagot random-valued multi-objective function 1
%
% Produce random objective values independent of the values of the
% individuals in Chrom (Chrom is only used to define the number of 
% individuals to produce objective values for).
% If the (persistent) parameter NOBJUSE is larger than 1 multiple
% objective values per individual are returned.
% This objective function was defined to research the distribution 
% of multi-objective individuals in dominated and non-dominated 
% individuals depending on the number of variables and the number 
% of objective values per individual . 
% More info can be found in the paper:
% Bagot, B. and Pohlheim, H.: Complementary selection and variation for 
%    an efficient multiobjective optimization of complex systems.  
%    CEC’2005, 2005. http://pohlheim.com/publications.html
%
% See also: objfun168, asknondom

% Author:   Hartmut Pohlheim
% History:  15.01.2005  file created


function ObjVal = mobjrandobjv1(Chrom);

   % Compute population parameters
   [Nind, Nvar] = size(Chrom);

   NAIN = nargin; NAOUT = nargout;

   if NAIN < 1, Chrom = []; end
   if isnan(Chrom), Chrom = []; end
   if isempty(Chrom), Chrom = [NaN, NaN, 1]; end
   persistent NOBJUSE
   
   % create structure
   if isnan(Chrom(1)),
      if all([isnan(Chrom(2)), Chrom(3) <= 10]),
         ObjVal = objfunoptset('FunctionName',  'PB RandObjV-MO-Function 1', ...
                               'VarBoundMin',    0, 'VarBoundMax', 1, ...
                               'NumVarDefault', 10, 'NumVarMin',   2, 'NumVarMax', Inf, ...
                               'NumObjDefault',  2, 'NumObjMin',   2, 'NumObjMax', Inf);
      elseif Chrom(3) == 11,
         NOBJUSE = Chrom(4);
      end
   else
      if isempty(NOBJUSE), NOBJUSE = 3; end
      % Produce random objective values, as many as individuals each with the defined number of objective values
      ObjVal = initrp(Nind, repmat([0;1], [1, NOBJUSE]));
   end

  
% End of function