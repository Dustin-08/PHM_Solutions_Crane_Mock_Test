% RECombination DIScrete
%
% This function performs discrete recombination between pairs of individuals
% and returns the new individuals after mating.
%
% Syntax:  NewChrom = recdis(OldChrom, RecRate)
%
% Input parameters:
%    OldChrom  - Matrix containing the chromosomes of the old
%                population. Each row corresponds to one individual
%                (in any form, not necessarily real values).
%    RecRate   - Probability of recombination ocurring between pairs
%                of individuals. (not used, only for compatibility)
%
% Output parameter:
%    NewChrom  - Matrix containing the chromosomes of the population
%                after mating, ready to be mutated and/or evaluated,
%                in the same format as OldChrom.
%
% See also: recombin, recint, reclin, recmut, recsp, recdp, recsh

%  Author:    Hartmut Pohlheim
%  History:   23.11.94     file created
%             24.11.94     style improved
%             06.12.94     change of name of function
%             25.02.95     clean up
%             19.03.95     multipopulation support removed


function NewChrom = recdis(OldChrom, RecRate);

% Identify the population size (Nind) and the number of variables (Nvar)
   [Nind,Nvar] = size(OldChrom);

% Identify the number of matings
   Xops = floor(Nind/2);

% which parent gives the value
   Mask1 = (rand(Xops, Nvar) < 0.5);
   Mask2 = (rand(Xops, Nvar) < 0.5);

% Performs recombination
   odd = 1:2:Nind-1;
   even= 2:2:Nind;
   NewChrom(odd,:)  = (OldChrom(odd,:).* Mask1) + (OldChrom(even,:) .* (~Mask1));
   NewChrom(even,:) = (OldChrom(odd,:).* Mask2) + (OldChrom(even,:) .* (~Mask2));

% If the number of individuals is odd, the last individual cannot be mated
% but must be included in the new population
   if rem(Nind,2),  NewChrom(Nind,:) = OldChrom(Nind,:); end


% End of function
