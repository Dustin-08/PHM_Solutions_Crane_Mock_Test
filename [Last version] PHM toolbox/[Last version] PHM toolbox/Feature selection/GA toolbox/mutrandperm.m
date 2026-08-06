% MUTation RANDom of binary variables
%
% This function takes the current population and produces the
% same number of randomly initialized permutation valued individuals.
% This is done by calling a llow level function (mutrand)
% which calls the initialization function appropriate for 
% the variable representation.
% The resulting (random) individuals are returned.
%
% Syntax:  NewChrom = mutrandperm(Chrom, VLUB, MutRate)
%
% Input parameters:
%    Chrom     - A matrix containing the chromosomes of the
%                current population. Each row corresponds to
%                an individuals.
%    VLUB      - Matrix containing the boundaries of each variable.
%    MutRate   - Not used here!
%
% Output parameter:
%    NewChrom  - Matrix containing the new (random) individuals.
%
% See also: mutate, mutrand, initpp

% Author:   Hartmut Pohlheim
% History:  14.06.99    file created


function NewChrom = mutrandperm(Chrom, VLUB, MutRate)

% Check input parameters
if nargin < 3, MutRate = NaN; end

% call low level function with appropriate parameters
   VarFormat = 5;
   NewChrom = mutrand(Chrom, VLUB, MutRate, VarFormat);


% End of function
