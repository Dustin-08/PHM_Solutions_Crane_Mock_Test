% SELection by Roulette Wheel Selection
%
% This function performs selection with Roulette wheel selection.
% This function selects a given number of individuals Nsel from a
% population. FitnV is a column vector containing the fitness
% values of the individuals in the population.
%
% Syntax:  NewChrIx = selrws(FitnV, Nsel)
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
% See also: selection, selsus, sellocal, seltrunc, seltour

% Author:   Hartmut Pohlheim
% History:  31.05.95    file created
%           03.07.97    function reworked, selection algorithm 
%                          made quicker and easier to understand
%           03.09.98    special case of selection from just one fitness 
%                          value is handled now


function NewChromIx = selrws(FitnV, Nsel, Dummy);

% Identify the population size (Nind)
   [Nind,ans] = size(FitnV);

% Perform selection (roulette wheel selection)
% (often called Stochastic Sampling with Replacement)
   if Nind == 1,
      NewChromIx = repmat(FitnV, [Nsel, 1]);
   else
      CumFitn  = cumsum(FitnV);
      Trials = CumFitn(Nind) .* rand(1, Nsel);
      MatFitn   = repmat(CumFitn, [1, Nsel]);
      MatTrials = repmat(Trials, [Nind, 1]);
      NewChromIx = sum(MatTrials >= MatFitn)+1;
      NewChromIx = NewChromIx(:);
   end

% Shuffle selected values
   [ans, shuf] = sort(rand(Nsel, 1));
   NewChromIx = NewChromIx(shuf);


% End of function
