% SELection by Stochastic Universal Sampling
%
% This function performs selection with stochastic universal sampling.
% This function selects a given number of individuals Nsel from a
% population. FitnV is a column vector containing the fitness
% values of the individuals in the population.
%
% Syntax:  NewChrIx = selsus(FitnV, Nsel)
%
% Input parameters:
%    FitnV     - Column vector containing the fitness values of the
%                individuals in the population.
%    Nsel      - Number of individuals to be selected
%
% Output parameters:
%    NewChromIx- Column vector containing the indexes of the selected
%                individuals relative to the original population, shuffeld.
%                The new population, ready for mating, can be obtained
%                by calculating OldChrom(NewChromIx,:).
%
% See also: selection, selrws, sellocal, seltrunc, seltour

% Author:   Hartmut Pohlheim
% History:  12.12.94    file created
%           22.02.95    clean up, comments
%           03.07.97    function reworked, selection algorithm 
%                          made quicker and easier to understand
%           03.09.98    special case of selection from just one fitness 
%                          value is handled now


function NewChromIx = selsus(FitnV, Nsel, Dummy);

% Identify the population size (Nind)
   [Nind,ans] = size(FitnV);

% Perform stochastic universal sampling
   if Nind == 1,
      NewChromIx = repmat(FitnV, [Nsel, 1]);
   else
      CumFitn  = cumsum(FitnV);
      Trials = CumFitn(Nind) / Nsel * (rand + (0:Nsel-1));
      MatFitn   = repmat(CumFitn, [1, Nsel]);
      MatTrials = repmat(Trials, [Nind, 1]);
      NewChromIx = sum(MatTrials >= MatFitn)+1;;
      NewChromIx = NewChromIx(:);
   end

% Shuffle selected values
   [ans, shuf] = sort(rand(Nsel, 1));
   NewChromIx = NewChromIx(shuf);


% End of function
