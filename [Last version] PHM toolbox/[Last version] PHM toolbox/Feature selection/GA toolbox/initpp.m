% Create an INITial Permutation Population
%
% This function creates a permutation population of given size
% and structure.
% The individuals consist of a random permutation of the numbers 
% between 1 and the length of the individuals. That means, every 
% of these numbers exists exactly _onces_ per individual and 
% _every_ of these numbers exist in an individual.
%
% Syntax: [Chrom] = initpp(Nind, VarLength)
%
% Input Parameters:
%    Nind      - Scalar containing the number of individuals (of rows)
%                to create.
%    VarLength - Scalar containing the length of the individuals.
%                Feature: instead of the variable length the boundary 
%                         matrix VLUB may be used. The number of columns
%                         of this matrix will be used as VarLength
%
% Output Parameters:
%    Chrom     - A matrix containing the random valued individuals
%                one row per individual.
%
% See also: initrp, initip, initbp, initpop

% Author:   Hartmut Pohlheim
% History:  25.05.98    file created
%           20.07.98    comments updated
%           13.10.99    error/warning handling updated
%                       VLUB may be used as second parameter


function Chrom = initpp(Nind, VarLength)

% Check input parameter consistency
   if length(Nind) > 1, Nind = Nind(1); warning('Number of individuals to create (Nind) must be a scalar!'); end
   if length(VarLength) > 1,
      % If VLUB is provided in VarLength
      if size(VarLength, 1) >= 2, VarLength = size(VarLength, 2);
      % If a vector was provided, use just the first element
      else VarLength = VarLength(1);
           warning('Length of individuals to create (VarLength) must be a scalar (or use VLUB)!');
      end
   end

% Create the random permutations
   [dummy, Chrom] = sort(rand(VarLength, Nind));
   Chrom = Chrom';


% End of function