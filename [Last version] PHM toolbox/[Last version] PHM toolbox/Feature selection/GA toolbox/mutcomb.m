% MUTation for combinatorial problems
%
% This function takes the individuals of the current
% population, mutates each indivdual with given probability 
% and returns the resulting population.
% Mutation can be done by:
%  - swapping 2 variables of the individual
%  - moving 1 variable from one position to another (insertion)
%  - inverting all positions between two positions
% The additional input variable MutType defines this.
%
% If mutation is 1/Nvar or larger, every individual is mutated ones.
% If mutation rate is > 1/Nvar, additional mutations (swap or 
% insertion or invertion of variables) are performed. That means, 
% for some individuals more than one mutation of variables takes 
% place. A mutation rate of 2/Nvar produces (statistically) 
% 2 mutations of variables per individual.
% The mutation range and precision are used for all mutations.
%
% This mutation operator may be used with every variable 
% representation, as long as the swap of the variables makes any sense.
% The mutation operator just exchanges/swaps the variables, no change 
% of variable value is performed.
%
% Syntax:  NewChrom = mutcomb(Chrom, VLUB, MutOpt, MutType)
%
% Input parameters:
%    Chrom     - A matrix containing the chromosomes of the
%                current population. Each row corresponds to
%                an individuals string representation.
%    VLUB      - Matrix containing the boundaries of each variable.
%                not used here, necessary for compatibility with
%                real valued mutation
%    MutOpt    - (optional) Vector containing mutation options
%                MutOpt(1): MutRate - number containing the mutation rate -
%                           probability for mutation of a variable
%                           if omitted or NaN, MutRate = 1/variables per
%                           individual is assumed
%                MutOpt(2): MutRange - (optional) number for shrinking the
%                           mutation range in the range [0 1], possibility to
%                           shrink the range of the mutation depending on,
%                           for instance actual generation.
%                           if omitted or NaN, MutRange = .2 is assumed
%                MutOpt(3): MutPreci - (optional) precision of mutation steps
%                           if omitted or NaN, MutPreci = 8 is assumed
%   MutType    - (optional) Scalar indicating type of combinatorial mutation
%                  0: swap
%                  1: insertion / move
%                  2: inversion
%
% Output parameter:
%    NewChrom  - Matrix containing a mutated version of Chrom.
%
% See also: mutate, mutswap, mutinvert, mutinsert, mutswaptyp, mutreal, mutbin, mutint, initip

% Author:   Hartmut Pohlheim
% History:  07.04.98    file created
%           15.04.99    use of defined mutation rate (MutOpt(1))
%                       more comments to the use of mutation rate
%                          and the usage for different variable 
%                          representations
%           20.07.99    inclusion of insertion/move and invertion


function NewChrom = mutcomb(Chrom, VLUB, MutOpt, MutType)

% Identify the population size (Nind) and the number of variables (Nvar)
   [Nind, Nvar] = size(Chrom);

% Set standard mutation parameter
   MutOptStandard = [1/Nvar, .2, 8];      % MutRate = 1/Nvar, MutRange = 1, MutPreci = 8

% Check parameter consistency
   % Checking of VLUB not necessary
   % [mF, nF] = size(VLUB);
   % if mF ~= 2, error('VLUB must be a matrix with 2 rows'); end
   % if Nvar ~= nF, error('VLUB and Chrom disagree'); end

   if nargin < 3, MutOpt = []; end
   if isnan(MutOpt), MutOpt = []; end
   if length(MutOpt) > length(MutOptStandard), error(' Too many parameter in MutOpt'); end

   if nargin < 4, MutType = []; end
   if isnan(MutType), MutType = []; end
   if isempty(MutType), MutType = 0; end

   MutOptIntern = MutOptStandard; MutOptIntern(1:length(MutOpt)) = MutOpt;
   MutRate = MutOptIntern(1); MutRange = MutOptIntern(2); MutPreci = MutOptIntern(3);

   if isnan(MutRate), MutRate = MutOptStandard(1);
   elseif (MutRate < 0 | MutRate > 1), error('Parameter for mutation rate must be a scalar in [0, 1]'); end

   if isnan(MutRange), MutRange = MutOptStandard(2);
   elseif (MutRange < 0 | MutRange > 1), 
      error('Parameter for shrinking mutation range must be a scalar in [0, 1]');
   end

   if isnan(MutPreci), MutPreci = MutOptStandard(3);
   elseif MutPreci <= 1, error('Parameter for mutation precision must be >= 1!'); end

% Matrix with range value maximal difference between positions
   Range = min(Nvar, ceil(Nvar * MutRange));

% the variabels are mutated with probability MutRate
% positions are calculated and the variables at these positions are exchanged
% Get number of mutations and index of individuals
   [MutRows, Mut1Col] = find(rand(Nind, 1) < (MutRate * Nvar));
   NewMutRate = MutRate - 1/Nvar;
   if NewMutRate > 0, [Mut2Row, Mut2Col] = find(rand(Nind, Nvar) < (NewMutRate)); MutRows = [MutRows; Mut2Row]; end
   NumMut = length(MutRows);

% Calculate step size
   % Defines the steepness or Kurvigkeit of the exponential function
   % Higher values produce a less curved function
   % Good value: 2
   MutSteep = 2;
   % "Table Lookup" into the exponential function exp(-MutPreci/MutSteep)
   % Produces values between 0 and 1, most values are small,
   % only a few are large
   Steps = exp(-(MutPreci/MutSteep) * rand(NumMut, 1));
   % Convert step sizes to domain or Range area
   Steps = round(Steps .* Range);
   % Ensure, that all steps < 1 are set to 1
   Steps = Steps .* (Steps >= 1) + 1 * (Steps < 1);
   % Ensure, that all steps == Nvar are set to Nvar-1
   Steps = Steps .* (Steps < Nvar) + (Nvar-1) * (Steps == Nvar);

% zeros and ones for mutation or not of this individual
   % Steps = Steps .* (rand(Nind, 1) < (MutRate * Nvar));

% Calculate the swap points
   StepRange = (Nvar - Steps);
   Point1 = ceil(rand(NumMut, 1) .* StepRange);
   Point2 = Point1 + Steps;
   % [StepRange, Point1, Point2]

% Perform mutation
   NewChrom = Chrom;
   switch MutType,
      case 0,     % swap of variables
         % vectorized version doesn't work for all variants
         % Convert indices to onedim indices
         % Index1= sub2ind(size(NewChrom), MutRows, Point1);
         % Index2= sub2ind(size(NewChrom), MutRows, Point2);
         % % [Index1, Index2]
         % NewChrom(Index1) = Chrom(Index2);
         % NewChrom(Index2) = Chrom(Index1);
      
         for iind = 1:NumMut,
            SavePoint = NewChrom(MutRows(iind), Point1(iind));
            NewChrom(MutRows(iind), Point1(iind)) = NewChrom(MutRows(iind), Point2(iind));
            NewChrom(MutRows(iind), Point2(iind)) = SavePoint;
         end
      
      case 1,     % insertion/move of variables
         for iind = 1:NumMut,
            SavePoint = NewChrom(MutRows(iind), Point1(iind));
            NewChrom(MutRows(iind), Point1(iind)) = NewChrom(MutRows(iind), Point2(iind));
            NewChrom(MutRows(iind), Point1(iind)+1:Point2(iind)) = [SavePoint NewChrom(MutRows(iind), Point1(iind)+1:Point2(iind)-1)];
         end
      
      case 2,     % invertion of variables
         for iind = 1:NumMut,
            NewChrom(MutRows(iind), Point1(iind):Point2(iind)) = NewChrom(MutRows(iind), Point2(iind):-1:Point1(iind));
         end
   end


% End of function
