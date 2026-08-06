% MUTation RANDom
%
% This function takes the current population and produces
% the same number of randomly initialized individuals. 
% The resulting (random) individuals are returned.
%
% Syntax:  NewChrom = mutrand(Chrom, VLUB, MutRate, VarFormat)
%
% Input parameters:
%    Chrom     - A matrix containing the chromosomes of the
%                current population. Each row corresponds to
%                an individuals.
%                Only the number and size of individuals is used.
%    VLUB      - Matrix containing the boundaries of each variable.
%                Used here for thge initialization boundaries.
%    MutRate   - Scalar containing the mutation rate / probability.
%                if omitted or NaN MutRate = 0.7/size(Chrom,2) is
%                assumed.
%                Not used here!
%    VarFormat - Format of variables (real, integer, binary, permutation)
%                (See description of GEATbx parameter Variable Format)
%
% Output parameter:
%    NewChrom  - Matrix containing the new (random) individuals.
%
% See also: mutate, mutreal, mutint, mutreal, initrp, initip, initbp, initpp

% Author:   Hartmut Pohlheim
% History:  14.06.99    file created


function NewChrom = mutrand(Chrom, VLUB, MutRate, VarFormat)

% get population size (Nind) and chromosome length (VarLength)
   [Nind, VarLength] = size(Chrom);

% Check input parameters
   if nargin < 3, MutRate = []; end, if isnan(MutRate), MutRate = []; end, if isempty(MutRate), MutRate = 0.7/VarLength; end
   MutRate = MutRate(1);
   
   if nargin < 4, VarFormat = []; end, if isnan(VarFormat), VarFormat = []; end, if isempty(VarFormat), VarFormat = 0; end

% Perform random initialization individuals
   switch VarFormat,
      % Real valued population
      case 0, NewChrom = initrp(Nind, VLUB);
      % Integer valued population
      case 2, NewChrom = initip(Nind, VLUB);
      % Permutation population
      case 5, NewChrom = initpp(Nind, VarLength);
      % Decode variables into binary,  [1, 3 or 4]
      otherwise, NewChrom = initbp(Nind, VarLength);
   end


% End of function
