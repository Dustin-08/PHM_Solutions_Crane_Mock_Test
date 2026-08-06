% MUTation for BINary representation
%
% This function takes the binary representation of the current
% population, mutates each element with given probability and 
% returns the resulting population.
%
% Syntax:  NewChrom = mutbin(Chrom, VLUB, MutRate)
%
% Input parameters:
%    Chrom     - A matrix containing the chromosomes of the
%                current population. Each row corresponds to
%                an individuals string representation.
%    VLUB      - Matrix containing the boundaries of each variable.
%                not used here, necessary for compatibility with
%                real valued mutation
%    MutRate   - Scalar containing the mutation rate / probability.
%                if omitted or NaN MutRate = 0.7/size(Chrom,2) is
%                assumed.
%
% Output parameter:
%    NewChrom  - Matrix containing a mutated version of Chrom.
%
% See also: mutate, mutint, mutreal, mutbmc, initbp

% Author:   Hartmut Pohlheim
% History:  21.10.96    file created
%                       same calling syntax then real valued mutation
%                          (VLUB is second parameter and ignored)
%           17.10.97    name changed to mutbin


function NewChrom = mutbin(Chrom, VLUB, MutRate)

% get population size (Nind) and chromosome length (VarLength)
   [Nind, VarLength] = size(Chrom);

% Check input parameters
   if nargin < 3, MutRate = []; end
   if isnan(MutRate), MutRate = []; end
   if isempty(MutRate), MutRate = 0.7/VarLength; end
   MutRate = MutRate(1);

% Perform mutation of individuals
   % add mutation mask to Chrom
   NewChrom = Chrom + (rand(Nind, VarLength) < MutRate);

   % Change all 2 to 0 by performing reminder of 2
   NewChrom = rem(NewChrom, 2);


% End of function
