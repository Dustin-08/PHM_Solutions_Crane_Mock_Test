% SELection by TRUNCation
%
% This function performs SELection by TRUNCation.
%
% Syntax:  NewChromIx = seltrunc(FitnV, Nsel)
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
% For the truncation threshold the inverse of the selection
% pressure is used (Trunc = 1/SP).
% 1/SP is computed from FitnV by mean(FitnV)/max(FitnV)
%
% See also: selection, selsus, selrws, seltour, sellocal
%
% Example:
%    % define fitness vector
%       FitnV = [.1; .9; 1.6; 2.0; 0.4; 1.3; 1.7; 0.7; 0.2];
%    % selects 6 indices from FitnV, Trunc = 0.5;
%       NewChromIx = seltrunc(FitnV, 6);
%    % possible result
%       NewChromIx = [3; 4; 2; 4; 6; 7];
%    % Get selected individuals from population Chrom
%       SelChrom = Chrom(NewChromIx, :)

% Author:     Hartmut Pohlheim
% History:    17.05.94     file created
%             11.10.95     examples added


function NewChromIx = seltrunc(FitnV, Nsel, Dummy);

% Uniform at random or fitness based selection from truncated parents
   SELPAR = 0;          % 0: uniform at random, 1: fitness based

% Identify the population size (Nind)
   [Nind, ans] = size(FitnV);

% Trunc - truncation threshold in the range [0, 1],
% computed from selection pressure 1/SP
   Trunc = (sum(FitnV) / Nind) / max(FitnV);
   if (Trunc < 0 | Trunc > 1),
      disp('Trunc in truncation selection outside range, set to 0.5');
      Trunc = 0.5;
   end

% Truncate Trunc% best individuals
   [Dummy, Ix1] = sort(-FitnV);
   Ix1 = Ix1(1:floor(Nind * Trunc));

% Assign fitness values
   if SELPAR == 0,
   % Selects parents from truncated individuals uniform at random
      FitnV1 = ones(length(Ix1), 1);
   else      % if SELPAR == 1,
   % Select parents from truncated individuals fitness based
      FitnV1 = FitnV(Ix1);
   end

% Select Nsel individuals from truncated individuals
   Ix2 = selsus(FitnV1, Nsel);

% Create index as row vector
   NewChromIx = Ix1(Ix2);
   NewChromIx = NewChromIx(:); 


% End of function
