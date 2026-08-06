% CReaTe an initial Binary Population
%
% This function creates a binary population of given size
% (Nind x VarLength).
%
% Syntax: [Chrom] = initbp(Nind, VarLength)
%
% Input Parameters:
%    Nind      - Scalar containing the number of individuals (of rows)
%                to create.
%    VarLength - Scalar or vector containing the length of the individuals.
%                scalar: length of the whole individual
%                vector: length of each variable of individual
%                        (length of the individual will be sum(VarLength))
%
% Output Parameters:
%    Chrom     - A matrix containing the random valued individuals 
%                one row per individual.
%
% See also: initrp, initip, initpp, initpop, bindecod, bin2real, bin2int, mutbin

% Examples:
%   % create a binary population with 4 individuals, each with
%   % 10 binary values
% >>Chrom = initbp(4, 10)
% Chrom =
%      1     1     1     1     0     1     0     0     1     0
%      0     0     0     1     1     1     0     1     0     0
%      1     1     1     1     1     1     1     1     1     0
%      1     1     1     0     0     0     1     0     0     1
%
%   % create a binary population with 6 individuals and 3 variables, the
%   % first with 5 binary variables decoded, the second with 4 binary
%   % values and the third with 3 binary values (12 binary variables
%   % at all); identical to >>initbp(6, 12)
% >>Chrom = initbp(6, [5, 4, 3])
% Chrom =
%      0     0     1     1     1     0     1     1     0     0     1     0
%      1     1     1     1     1     1     1     0     1     0     0     1
%      1     0     0     0     1     0     1     1     0     0     1     0
%      1     0     0     1     1     0     0     0     1     0     1     0
%      1     0     0     1     1     1     0     1     1     0     0     0
%      0     0     1     1     0     1     1     1     1     0     1     1

% Author:   Hartmut Pohlheim
% History:  21.10.95    file created
%           13.10.99    error/warning handling updated


function [Chrom] = initbp(Nind, VarLength)

% Check input parameter consistency
   if length(Nind) > 1, Nind = Nind(1); warning('Number of individuals to create (Nind) must be a scalar!'); end
   if min(size(VarLength)) > 1,
      if size(VarLength,1) > size(VarLength,2), VarLength = VarLength(:,1); else VarLength = VarLength(1,:); end
      warning('Length of individuals (VarLength) must be a scalar or vector (and not a matrix!)');
   end


% Create a structure of random chromosomes in row wise order, dimensions
% Nind by sum of VarLength.
   Chrom = rand(Nind, sum(VarLength)) < 0.5;


% End of function
