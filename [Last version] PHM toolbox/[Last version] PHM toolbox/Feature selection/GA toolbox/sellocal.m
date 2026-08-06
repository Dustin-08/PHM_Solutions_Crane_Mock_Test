% SELection in a LOCAL neighbourhood
%
% This function performs SELection in a LOCAL neighbourhood.
% This function is the first part of the implementation of 
% the local model (population model). The second part is
% implemented in reinsloc.
%
% Syntax:  NewChromIx = sellocal(FitnV, Nsel, SelOpt)
%
% Input parameters:
%    FitnV     - Column vector containing the fitness values of the
%                individuals in the population.
%    Nsel      - Number of individuals to be selected
%    SelOpt    - (optional) Vector containing parameters for local selection
%                SelOpt(1): local dimension 
%                SelOpt(2): local structure - number indicating the structure
%                           of the neighbourhood
%                SelOpt(3): local distance
%
% Output parameters:
%    NewChromIx- Column vector containing the indexes of the selected
%                individuals relative to the original population, shuffeld.
%                The new population, ready for mating, can be obtained
%                by calculating OldChrom(NewChromIx,:).
%
% See also: selection, reinsloc, comploc, selsus, selrws, seltrunc, seltour

% Author:   Hartmut Pohlheim
% History:  11.02.97    file created
%           27.02.97    comments added, parameter check transfered to comploc


function NewChromIx = sellocal(FitnV, Nsel, SelOpt);

% Identify the population size (Nind)
   [Nind, ans] = size(FitnV);

% Check parameter consistency
   if nargin < 2,  error('Not enough input parameter'); end
   if nargin < 3,  SelOpt = []; end

   % Selection method of first parent (odd parent)
   % 0: random selection; 1: fitness based (selsus); 2: uniform local; default: 2
   SELODD = 1;

   % Selection method for second parent (even parent)
   % 0: random neighbour; 1: best neighbour; default: 1
   SELEVEN = 1;

% Selection of odd parents
   % Calculate number of mate pairs
   Npar = ceil(Nsel/2);
   
   % Select at random
   if SELODD == 0,
      Ix1 = ceil(Nind * rand(Npar, 1));

   % Use fitness values and stochastic universal sampling
   elseif SELODD == 1,    % selsus
      Ix1 = selsus(FitnV, Npar);

   % Select uniform
   else     % if SELODD == 2,
      Ix1 = sort(selsus(ones(size(FitnV)), Npar));
   end

   % Use only floor(Nsel/2) parents for selecting a second mate,
   % the probably one parent too much is used without selecting a second mate
   Ix2 = Ix1(1:floor(Nsel/2));

% Construct matrix containing neighbours of first parents,
% one row per neighbourhood, as many columns as neighbours
   MatInd2 = comploc('local_neighbourhood', Nind, Ix2, SelOpt);
   
% Select mating partner from neighbourhood
   [NumSelect, NumNeigh] = size(MatInd2);
   % random neighbour
   if SELEVEN == 0,
      SelIndIx = ceil(NumNeigh * rand(NumSelect, 1));
   % best neighbour
   else        % if SELEVEN == 1,
      Temp1 = repmat(FitnV, [1, NumNeigh]);
      [Dummy, SelIndIx] = max(Temp1(MatInd2)');
      SelIndIx = SelIndIx(:);
   end
   % SelIndIx contains number of second parent in every row
   % now this index in row must be converted to index in matrix
   SelIndIx = (SelIndIx-1) * NumSelect + [1:NumSelect]';
   Best2 = MatInd2(SelIndIx);

% Add odd and even parent, if Nsel is odd, last odd parent is added
   NewChromIx = [];
   NewChromIx(1:2:Nsel) = Ix1;
   NewChromIx(2:2:Nsel) = Best2;
   NewChromIx = NewChromIx';
   

% End of function
