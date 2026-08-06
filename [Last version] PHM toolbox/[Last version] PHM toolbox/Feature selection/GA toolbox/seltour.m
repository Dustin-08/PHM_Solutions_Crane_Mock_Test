% SELection by TOURnament
%
% This function performs SELection by TOURnament.
%
% Syntax:  NewChrIx = seltour(FitnV, Nsel)
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
% The tournament size Tour is determined from the highest
% fitness value ceil(max(FitnV)). If ranking was used, this
% means ceil(SP);
%    FitnV = [1.0; 1.1; 1.9;  0.5; 1.3]; ==> Tour = 2;
%    FitnV = [1.6; 2.1; 3.05; 1.0; 0.4]; ==> Tour = 4;
% The tournament size should be in [1, Nind]. If not, Tour is set
% to one of these values and a message is displayed.
% For Tour==1 tournament selection is identical to random selection
% (no selective pressure). 
%
% See also: selection, selsus, selrws, seltrunc, sellocal
%
% Example:
%    % define fitness vector
%       FitnV = [.1; .9; 1.6; 2.0; 0.4; 1.3; 1.7; 0.7; 0.2];
%    % selects 6 indices from FitnV, Tour = 2;
%       NewChromIx = seltour(FitnV, 6);
%    % possible result
%       NewChromIx = [4; 7; 6; 7; 6; 5];
%    % Get selected individuals from population Chrom
%       SelChrom = Chrom(NewChromIx, :)

% Author:     Hartmut Pohlheim
% History:    11.10.95     file created


function NewChromIx = seltour(FitnV, Nsel, Dummy);

% Identify the population size (Nind)
   [Nind, ans] = size(FitnV);

% Tour - tournament size in the range [1, Nind],
% computed from highest fitness value, normally ceil(SP) 
   Tour = ceil(max(FitnV));
   if (Tour < 1 | Tour > Nind),
      if Tour < 1, Tour = 1; end
      if Tour > Nind, Tour = Nind; end
      disp(sprintf('Tour in tournament selection outside range, set to %g', Tour));
   end

% Select Tour individuals uniform at random Nsel times from population
   % Create matrix with random indizes 
   Mat1 = ceil(rand(Nsel, Tour) * Nind);
   % Select fitness values for tournament
   Mat2 = reshape(FitnV(Mat1), Nsel, Tour);
   % Get best fitness value in tournament
   if Tour == 1, Ix1 = 1; else [dummy, Ix1] = max(Mat2'); end
   % Select index of winner individuals
   Ix2 = Ix1 + [0:Tour:Tour*(Nsel-1)];
   Mat1 = Mat1'; NewChromIx = Mat1(Ix2);

% Shuffle new population
   [ans, shuf] = sort(rand(Nsel, 1));
   NewChromIx = NewChromIx(shuf)';


% End of function
