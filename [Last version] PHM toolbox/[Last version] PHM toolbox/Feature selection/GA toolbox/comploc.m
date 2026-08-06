% COMPute LOCal model things of toolbox
%
% This function computes diverse things for the implementation
% of the local model.
%
% Syntax:  [OP1, OP2, OP3, OP4, OP5] = comploc(WhatTask, P1, P2, P3, P4, P5, P6, P7, P8, P9, P10)
%
% Input parameters:
%    WhatTask      - String containing the name of the needed computation
%    P1 - P10  - Parameters needed for the specific computations
%
% Output parameter:
%    OP1 - OP5 - Output parameters, specific for every computation
%
% Possible functions:
%    WhatTask == 'local_neighbourhood'
%       Sort/order subpopulations according objective values, return
%          position of every subpopulation
%       P1     - Scalar containing number of individuals
%       P2     - (column) Vector containing index of center of neighbourhood
%       P3     - Scalar or vector containing local dimension of structure
%                   see WhatTask == 'local_dimension'
%       P4     - Scalar containing local structure
%                        0: ring or cross or the same in higher dimensions,
%                           only one index is different from zero
%                        1: star or the same in higher dimensions
%                           all indices are smaller than LocalDistance
%                        2: schiefer star or the same in higher dimensions
%                           the sum of all indices are smaller than LocalDistance*Dimension
%                        8: all neighbours with distance smaller than LocalDistance
%                        9: as many neighbours as defined in LocalDistance
%                    >= 10: half structure of (local structure-10)
%       P5     - Scalar containing local distance
%       OP1    - Indices of individuals, one row per neighbourhood
%
%    WhatTask == 'local_dimension'
%       Compute full values for LocalDimension and check everything
%       P1     - Scalar containing number of dimensions or
%                vector containing length of every dimension
%                if 0 or empty
%       P2     - Number of individuals in population
%       OP1    - Vector containing length of every dimension
%                   Dimension can be computed by length(LocalDim)
%
%    WhatTask == 'local_allneighbourindex'
%       Compute all indices of all possible neighbours and their
%          (squared) distance
%       P1     - Scalar or vector containing dimension of structure
%                   see 'local_dimension'
%       P2     - maximal distance to neighbours (>=1)
%       OP1    - Vector containing all possible square distances
%                   sorted in a row vector
%       OP2    - Matrix containing indices of neighbours corresponding
%                   with distances; as many rows as dimensions and as 
%                   many columns as possible neighbours
%
% See also: compdiv, sellocal, reinsloc

%  Author:  Hartmut Pohlheim
%  History: 12.02.97    file created


function [OP1, OP2, OP3, OP4, OP5] = comploc(WhatTask, P1, P2, P3, P4, P5, P6, P7, P8, P9, P10);

% Set needed global variable (old versions)
   global GLOBAL_LOCALDIM;

% Check input parameters
   if nargin < 1, WhatTask = []; end 
   if isempty(WhatTask), error('Parameter WHAT undefined! Do you know what you want?'); end


% Compute neighbours of individuals, different structures and dimensions possible
   if strcmp(lower(WhatTask), 'local_neighbourhood'),
      % P1: scalar, number of individuals
      % P2: column vector, index of center of neighbourhood
      % P3: SelOpt (local dimension of structure, selection structure, local neighbourhood)
      Nind = P1; SelectedIndividualsIx = P2(:);
      
      % Set standard local selection parameter
      SelOptStandard = [0, 0, 2];      % LocalDimension = 0, LocalStructure = 0, LocalDistance = 2
      
      if nargin < 4, SelOpt = []; else SelOpt = P3; end
      if isnan(SelOpt), SelOpt = []; end
      if length(SelOpt) > length(SelOptStandard), error(' Too many parameter in SelOpt'); end

      SelOptIntern = SelOptStandard; SelOptIntern(1:length(SelOpt)) = SelOpt;
      LocalDimension = SelOptIntern(1); LocalStructure = SelOptIntern(2); LocalDistance = SelOptIntern(3);

      % Dimension of individuals, scalar: number of dimensions; vector: length in all dimensions
      if isnan(LocalDimension), LocalDimension = SelOptStandard(1);
      elseif LocalDimension < 0, error('Parameter for local dimension must be greater than 0.'); end
      LocalDimension = comploc('local_dimension', LocalDimension, Nind);
      Dimension = length(LocalDimension);

      % Structure of neighbourhood
      if isnan(LocalStructure), LocalStructure = SelOptStandard(2);
      elseif ~(any(LocalStructure == [0:2,8:12])), error('Parameter for local selection structure must be in [0:3,8:12].'); end

      % Distance to neighbours
      if isnan(LocalDistance), LocalDistance = SelOptStandard(3);
      elseif LocalDistance < 0, error('Parameter for local neighbourhood must be greater than 0.'); end
      if LocalDistance == 0, LocalDistance = SelOptStandard(3); end

      % Calculate maximal distance for index calculation
      if rem(LocalStructure, 10) == 1, DistMax = sqrt(Dimension * LocalDistance.^2);
      elseif rem(LocalStructure, 10) == 2, DistMax = Dimension * LocalDistance;
      elseif rem(LocalStructure, 10) == 9, DistMax = LocalDistance.^(1/Dimension);
      else DistMax = LocalDistance; end
      
      % Get all neighbours including their indices and their distance
      [DistAllSquareSorted, DistIxSorted] = comploc('local_allneighbourindex', Dimension, DistMax);

      % For all half structures, use only neighbours with all indices >= 0
      if LocalStructure >= 10,
         % Exclude negativ indices 
         if Dimension == 1, [Dummy, IncludeIx] = find(DistIxSorted >= 0);
         else [Dummy, IncludeIx] = find(sum(DistIxSorted < 0) == 0); end
         DistIxSorted = DistIxSorted(:, IncludeIx);
         DistAllSquareSorted = DistAllSquareSorted(IncludeIx);
         % Reset LocalStructure to common structure
         LocalStructure = LocalStructure - 10;
      end

      % ring or cross or the same in higher dimensions,
      % only one index is different from zero
      if LocalStructure == 0,
         SmallerSelIx = find(DistAllSquareSorted <= LocalDistance.^2);
         DistIxSorted = DistIxSorted(:, SmallerSelIx);
         if Dimension == 1, RingCrossSelIx = find((DistIxSorted ~= 0) == 1);
         else               RingCrossSelIx = find(sum(DistIxSorted ~= 0) == 1); end
         NeighIx = DistIxSorted(:, RingCrossSelIx);

      % star or the same in higher dimensions
      % all indices are smaller than LocalDistance
      elseif LocalStructure == 1,
         % if DistMax is (sqrt(Dimension * LocalDistance.^2)) everything is done
         % calculation is just for to be sure
         if Dimension == 1, [Dummy, StarSelIx] = find((abs(DistIxSorted) <= LocalDistance) == Dimension);
         else               [Dummy, StarSelIx] = find(sum(abs(DistIxSorted) <= LocalDistance) == Dimension); end
         NeighIx = DistIxSorted(:, StarSelIx);
      
      % schiefer star or the same in higher dimensions
      % the sum of all indices are smaller than LocalDistance*Dimension
      elseif LocalStructure == 2,
         % if DistMax is (sqrt(Dimension * LocalDistance.^2)) everything is done
         % calculation is just for to be sure
         if Dimension == 1, [Dummy, StarSelIx] = find((abs(DistIxSorted) <= LocalDistance));
         else               [Dummy, StarSelIx] = find((sum(abs(DistIxSorted)) <= (LocalDistance*Dimension)));
         end
         NeighIx = DistIxSorted(:, StarSelIx);
      
      % All neighbours with distance smaller than LocalDistance
      elseif LocalStructure == 8,
         [Dummy, SmallerSelIx] = find(DistAllSquareSorted <= LocalDistance.^2);
         NeighIx = DistIxSorted(:, SmallerSelIx);
      
      % As many neighbours as defined in LocalDistance
      elseif LocalStructure == 9,
         NeighIx = DistIxSorted(:, 1:LocalDistance);
      end

      % Convert indizes from many dimensions to one dimension
      IndMult = [1];
      for imult = 1:Dimension-1, IndMult = [IndMult; prod(LocalDimension(1:imult))]; end
      IndAdd = NeighIx .* repmat(IndMult, [1, size(NeighIx, 2)]);
      if Dimension > 1, IndAdd = sum(IndAdd); end

      % Add relativ indizes of neighbours to absolut indizes of individuals,
      % thus calculating absolut indizes of neighbours of individuals
      FullSelIndIx = repmat(SelectedIndividualsIx, [1, length(IndAdd)]) + ...
                     repmat(IndAdd, [length(SelectedIndividualsIx), 1]);
      FullSelIndIx = rem(FullSelIndIx, Nind);
      % Correct negative indizes (negativ neighbours are at the end) 
      NegativIx = find(FullSelIndIx <= 0);
      FullSelIndIx(NegativIx) = FullSelIndIx(NegativIx) + Nind;

      % Output: Indices of individuals, one row per neighbourhood
      OP1 = FullSelIndIx;

% Compute full values for LocalDimension
   elseif strcmp(lower(WhatTask), 'local_dimension'),
      % P1: local dimensions
      % P2: number of individuals of population
      if nargin < 2, P1 = []; end
      if isnan(P1), P1 = []; end
      if isempty(P1), P1 = 0; end
      LocalDim = P1;
      if nargin < 3, P2 = []; end
      if isnan(P2), P2 = []; end
      if isempty(P2), P2 = 0; end
      Nind = P2;

      % If nothing is defined,
      if LocalDim == 0, 
         % Check for global variable containg length of dimensions
         if ~isempty(GLOBAL_LOCALDIM),
            LocalDim = GLOBAL_LOCALDIM;
         % If no global variable, compute default dimension
         % depending of number of individuals in population
         % 1-98: 1-D (linear); 99-999: 2-D; 1000-9998: 3-D 
         else 
            if Nind == 0, error('Nind (P2) must be defined for calculation of local dimension!'); end
            LocalDim = max(1, floor(log10(Nind+1)));
            LocalDim = repmat(ceil(Nind.^(1/LocalDim)), [1, LocalDim]);
        end
      else
         % If LocalDim is scalar (thus contains number of dimensions),
         % then create vector of length in every dimension
         % for instance: LocalDim = 3, Nind = 2000 ==> [13;13;13]  
         if length(LocalDim) == 1, 
            if Nind == 0, error('Nind (P2) must be defined for calculation of local dimension!'); end
            LocalDim = repmat(ceil(Nind.^(1/LocalDim)), [1, LocalDim]);
         end
      end

      % Output: vector containing length of every dimension
      % Dimension can be computed by length(LocalDim)
      OP1 = LocalDim(:);

% Compute all indices of all possible neighbours and their (squared) distance
   elseif strcmp(lower(WhatTask), 'local_allneighbourindex'),
      % P1: dimension of structure (1, 2, 3, ...)
      % P2: maximal distance to neighbours (>=1)
      if length(P1) == 1, Dim = P1; else Dim = length(P1); end
      if nargin < 3, error('Parameter P2 (DistMax) needed for computation of all indices!');
      else DistMax = P2; end
      DistMaxInd = ceil(DistMax);
      
      % Create matrix with indices of all neighbours ,
      % contains Dim rows, every column contains the indices of one neighbour
      IxAll = [-DistMaxInd:DistMaxInd];
      for irun = 1:Dim-1,
         IxAll2 = expandm(IxAll, [1, 2*DistMaxInd+1]);
         IxAll = [IxAll2; repmat([-DistMaxInd:DistMaxInd], [1, (2*DistMaxInd+1).^irun])];
      end

      % Compute the square of the distance of every neighbour
      if Dim == 1, DistAllSquare = IxAll.^2;
      else DistAllSquare = sum(IxAll.^2); end

      % Include only distances <= DistMax
      [DistAllSquareIx] = find(DistAllSquare <= (DistMax.^2));
      DistAllSquare = DistAllSquare(DistAllSquareIx);
      DistAx = IxAll(:, DistAllSquareIx);
 
      % Sort neighbours, smallest distance first
      [DistAllSquareSorted, DistAllSortedIx] = sort(DistAllSquare);
      DistAxSorted = DistAx(:, DistAllSortedIx);

      % Exclude distance of zero (first element in sorted matrix)
      DistAllSquareSorted(1) = [];  
      DistAxSorted = DistAxSorted(:, 2:size(DistAxSorted, 2));

      % Output1: possible square distances sorted in a row vector
      % Output2: indices of neighbours corresponding with distances
      OP1 = DistAllSquareSorted;
      OP2 = DistAxSorted;

% If unknown option, issue an error message
   else
      disp(sprintf('comploc.m: Unknown option for action! (%s)', WhatTask));
   end


% End of function