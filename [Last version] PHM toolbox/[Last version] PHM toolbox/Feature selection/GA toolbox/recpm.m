% RECombination Partial Matching
%
% This function takes a matrix Chrom containing a permutation representation
% of the individuals in the current population, applies the partial matching
% crossover to consecutive pairs of individuals with probability
% RecRate and returns the resulting population.
%
% Syntax:  NewChrom = recpm(Chrom, RecRate
%
% Input parameters:
%    Chrom     - Matrix containing the chromosomes of the old
%                population. Each row corresponds to one individual.
%    RecRate   - Probability of crossover ocurring between pairs
%                of individuals.
%
% Output parameter:
%    NewChrom  - Matrix containing the chromosomes of the population
%                after mating, ready to be mutated and/or evaluated,
%                in the same format as Chrom.
%
% See also: recombin, recint, recgp

% Author:   Hartmut Pohlheim (thanks to Michael)
% History:  25.05.98    file created
%           20.07.98    comments updated


function NewChrom = recpm(Chrom, RecRate);

% Identify the population size (Nind) and the chromosome length(Lind)
   [Nind, Nprm] = size(Chrom);

% Set default parameters
   if Nprm < 2, NewChrom = Chrom; return; end

   if nargin < 2, RecRate = []; end
   if isnan(RecRate), RecRate = []; end
   if isempty(RecRate), RecRate = 0.7; end

   Xops = floor(Nind / 2);
   DoCross = find(rand(1, Xops) < RecRate);
   odd = 1:2:Nind - 1;
   even = 2:2:Nind;

% Perform the partial matching crossover for each pair
   for pair = DoCross,

      % get the chromosome pair
      chrom1 = Chrom(odd(pair), :);
      chrom2 = Chrom(even(pair), :);

      % get the effective length of the chromosome pair
      NotEq = find(chrom1 ~= chrom2);

      % make sure the pair are not identical
      if isempty(NotEq),

         newchrom1 = chrom1;
         newchrom2 = chrom2;

      else

         % randomly generate the crossover points
         recpt1 = ceil(rand(1) * (length(NotEq) - 1));
         recpt2 = recpt1 + ceil(rand(1) * (length(NotEq) - recpt1));
         recsct = NotEq(recpt1:recpt2);

         % Create new individuals via partial matching crossover

         % create the new individuals and perform the crossover
         newchrom1 = chrom1;
         newchrom2 = chrom2;
         A = newchrom1(recsct);
         B = newchrom2(recsct);
         newchrom1(recsct) = B;
         newchrom2(recsct) = A;

         % fix any duplicated elements
         AnotB = setdiff(A, B);
         BnotA = setdiff(B, A);
         swapfrom1 = find(ismember(chrom1, BnotA));
         swapfrom2 = find(ismember(chrom2, AnotB));
         temp = newchrom1(swapfrom1);
         newchrom1(swapfrom1) = newchrom2(swapfrom2);
         newchrom2(swapfrom2) = temp;

      end

      % create the new individuals
      NewChrom(odd(pair), :) = newchrom1;
      NewChrom(even(pair), :) = newchrom2;

    end

% If the number of individuals is odd, the last individual cannot be mated
% but must be included in the new population
   if rem(Nind, 2), NewChrom(Nind, :) = Chrom(Nind, :); end


% End of function

