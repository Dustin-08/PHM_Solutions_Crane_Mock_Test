% RECombination Double Point with Reduced Surrogate
%
% This function performs double point 'reduced surrogate' recombination between 
% pairs of individuals and returns the current generation after mating.
%
% Syntax:  NewChrom = recdprs(OldChrom, RecRate)
%
% Input parameters:
%    OldChrom  - Matrix containing the chromosomes of the old
%                population. Each row corresponds to one individual
%                (in binary form).
%    RecRate   - Probability of recombination ocurring between pairs
%                of individuals.
%
% Output parameter:
%    NewChrom  - Matrix containing the chromosomes of the population
%                after mating, ready to be mutated and/or evaluated,
%                in the same format as OldChrom.
%
% See also: recombin, recdp, recsprs, recshrs, recmp

%  Author:    Hartmut Pohlheim
%  History:   28.03.95     file created

function NewChrom = recdprs(OldChrom, RecRate);

if nargin < 2, RecRate = NaN; end

% call low level function with appropriate parameters
   NewChrom = recmp(OldChrom, RecRate, 2, 1);


% End of function
