% MUTation by MOVEing variables
%
% This function takes the individuals of the current
% population, mutates each indivdual by moving variables 
% with given probability and returns the resulting 
% population.
%
% For more information please consult the help for mutcomb.
%
% Syntax:  NewChrom = mutmove(Chrom, VLUB, MutOpt)
%
% Input parameters:
%    Chrom     - A matrix containing the chromosomes of the
%                current population. Each row corresponds to
%                an individuals string representation.
%    VLUB      - Matrix containing the boundaries of each variable.
%                not used here, necessary for compatibility with
%                real valued mutation
%    MutOpt    - (optional) Vector containing mutation options
%                MutOpt(1): MutRate - number containing the mutation rate -
%                           probability for mutation of a variable
%                           if omitted or NaN, MutRate = 1/variables per
%                           individual is assumed
%                MutOpt(2): MutRange - (optional) number for shrinking the
%                           mutation range in the range [0 1], possibility to
%                           shrink the range of the mutation depending on,
%                           for instance actual generation.
%                           if omitted or NaN, MutRange = .2 is assumed
%                MutOpt(3): MutPreci - (optional) precision of mutation steps
%                           if omitted or NaN, MutPreci = 8 is assumed
%
% Output parameter:
%    NewChrom  - Matrix containing a mutated version of Chrom.
%
% See also: mutcomb, mutate, mutswaptyp, mutreal, mutbin, mutint, initip

% Author:   Hartmut Pohlheim
% History:  20.07.99    file created


function NewChrom = mutmove(Chrom, VLUB, MutOpt)

% Identify the population size (Nind) and the number of variables (Nvar)
   [Nind, Nvar] = size(Chrom);

% Check parameter consistency
   if nargin < 2, VLUB = []; end
   if nargin < 3, MutOpt = []; end

% Call low level mutation function
   MutType = 1;
   NewChrom = mutcomb(Chrom, VLUB, MutOpt, MutType);


% End of function
