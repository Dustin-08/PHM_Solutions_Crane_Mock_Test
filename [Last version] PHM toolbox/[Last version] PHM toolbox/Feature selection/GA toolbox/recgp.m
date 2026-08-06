% RECombination Generalized Position
%
% This function takes a matrix Chrom containing an permutation representation
% of the individuals in the current population, applies the generalized
% position crossover to consecutive pairs of individuals with probability
% RecRate and returns the resulting population.
%
% Syntax:  NewChrom = recgp(Chrom, RecRate)
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
% See also: recombin, recint, recpm

% Author:   Hartmut Pohlheim (thanks to Michael)
% History:  19.05.98    file created
%           20.07.98    comments updated


function NewChrom = recgp(Chrom, RecRate);

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

% Perform the generalized position crossover for each pair
   for pair = DoCross,

      % get the chromosome pair
      chrom1 = Chrom(odd(pair), :);
      chrom2 = Chrom(even(pair), :);

      % get the effective length of the chromosome pair
      NotEq = find(chrom1 ~= chrom2);

      % make sure the pair are not identical
      if ~isempty(NotEq),

         % construct the index arrays
         elemt1 = []; count1 = []; index1 = zeros(Nprm, 1);
         elemt2 = []; count2 = []; index2 = zeros(Nprm, 1);
         for p = NotEq,

            % check if this element has already been counted
            if isempty(elemt1),
               pos1 = [];
            else
               pos1 = find(elemt1 == chrom1(p));
            end
            if isempty(pos1),
               elemt1 = [elemt1 chrom1(p)];
               count1 = [count1 1];
               pos1 = length(elemt1);
            else
               count1(pos1) = count1(pos1) + 1;
            end
            if isempty(elemt2),
               pos2 = [];
            else
              pos2 = find(elemt2 == chrom2(p));
            end
            if isempty(pos2),
               elemt2 = [elemt2 chrom2(p)];
               count2 = [count2 1];
               pos2 = length(elemt2);
            else
               count2(pos2) = count2(pos2) + 1;
            end
            % update the index array
            index1(p) = count1(pos1);
            index2(p) = count2(pos2);

         end

         % randomly generate the crossover point
         recpt = ceil(rand(1) * (length(NotEq) - 1));
         recsct = NotEq(recpt:length(NotEq));

         % Create new individuals via generalized position crossover

         % delete the elements (with corresponding values and indices) in the
         % crossover section from the original individuals
         newchrom1 = [];
         newchrom2 = [];
         for p = NotEq,
            if ~ismember(index1(p), ...
                         index2(recsct(find(chrom2(recsct) == chrom1(p))))),
               newchrom1 = [newchrom1 chrom1(p)];
            end 
            if ~ismember(index2(p), ...
                         index1(recsct(find(chrom1(recsct) == chrom2(p))))),
               newchrom2 = [newchrom2 chrom2(p)];
            end
         end

         % append the crossover sections
         newchrom1 = [newchrom1 chrom2(recsct)];
         newchrom2 = [newchrom2 chrom1(recsct)];

         % insert the crossover into the individuals
         chrom1(NotEq) = newchrom1;
         chrom2(NotEq) = newchrom2;

      end

      % create the new individuals
      NewChrom(odd(pair), :) = chrom1;
      NewChrom(even(pair), :) = chrom2;

    end

% If the number of individuals is odd, the last individual cannot be mated
% but must be included in the new population
   if rem(Nind, 2), NewChrom(Nind, :) = Chrom(Nind, :); end


% End of function

