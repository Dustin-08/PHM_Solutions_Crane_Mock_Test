% MUTation by SWAPping variables of identical type
%
% This function takes the individuals of the current
% population and mutates each indivdual by swapping variables 
% of the individual. Only variables of the same type (same 
% boundaries of domain, for instance, binary, signed and unsigned char,
% signed and unsigned integer, and real variables with the same 
% boundaries) are exchanged/swapped.
% Currently, only one exchange per individual takes place (mutation rate fixed 
% to 1/number of variables).
% Later:
% If mutation is 1/Nvar or larger, every individual is mutated ones.
% If mutation rate is > 1/Nvar, additional mutations (swap of 
% variables) are performed. That means, for some individuals
% more than one swap of variables takes place. A mutation rate
% of 2/Nvar produces (statistically) 2 swaps of variables per 
% individual.
%
% The mutation range and precision are used for all mutations.
% The resulting population is returned.
%
% This mutation operator may be used with every variable 
% representation, as long as the swap of the variables with identical 
% boundaries makes any sense. The mutation operator just exchanges/swaps 
% the variables, no change of the variable value is performed.
%
% Syntax:  NewChrom = mutswaptyp(Chrom, VLUB, MutOpt)
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
%
% Output parameter:
%    NewChrom  - Matrix containing a mutated version of Chrom.
%
% See also: mutate, mutswap, mutexch, mutreal, mutbin, mutint, initip

% Author:   Hartmut Pohlheim
% History:  15.04.99    file created


function NewChrom = mutswaptyp(Chrom, VLUB, MutOpt)

% Identify the population size (Nind) and the number of variables (Nvar)
   [Nind, Nvar] = size(Chrom);

% Set standard mutation parameter
   MutOptStandard = [1/Nvar, .2, 8];      % MutRate = 1/Nvar, MutRange = 1, MutPreci = 8

% Check parameter consistency
   if nargin < 2,  error('Not enough input parameter'); end

   [mF, nF] = size(VLUB);
   if mF ~= 2, error('VLUB must be a matrix with 2 rows'); end
   if Nvar ~= nF, error('VLUB and Chrom disagree'); end

   if nargin < 3, MutOpt = []; end
   if isnan(MutOpt), MutOpt = []; end
   if length(MutOpt) > length(MutOptStandard), error(' Too many parameter in MutOpt'); end

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

% Calculate, which variables have the same domain
   % Create matrices and compare them, first for lower bound, than for upper bound
   IDMat = repmat(VLUB(1,:), [Nvar, 1]) == repmat(VLUB(1,:)', [1, Nvar]);
   IDMat = IDMat + (repmat(VLUB(2,:), [Nvar, 1]) == repmat(VLUB(2,:)', [1, Nvar]));
   % every 2 indicates, that at least one other variable has the same domain, except main diagonale
   % that means, upper and lower bound are identical to the bounds of another variable
   IDMat = IDMat == 2;

   % Get the groups of variables with matching domains
   IndVarMember = (find(sum(IDMat) > 1))';    % eliminates elements from main diagonale
   % Get number of variables with somewhere matching domains
   NumGroupVariables = length(IndVarMember);
   % Preset some values
   igroup = 1; IxGroup = {}; LengthPerGroup = [];
   MemInGroup = zeros(Nvar, 1);
   GroupVarMember = IndVarMember;
   % Look through all variables in list
   while ~(isempty(GroupVarMember)),
      % Find members of one domain group
      ThisGroup = find(IDMat(GroupVarMember(1),:) == 1);
      % Save members of one domain group in cell array element
      IxGroup{igroup} = ThisGroup;
      MemInGroup(ThisGroup) = igroup;
      LengthPerGroup = [LengthPerGroup; length(ThisGroup)];
      igroup = igroup + 1;
      % Exclude found variables from the possible variable list
      GroupVarMember = setdiff(GroupVarMember, ThisGroup);
   end

   % Get number of groups with separate domains
   NumGroups = length(IxGroup);

   % prprintf(IxGroup), MemInGroup
   LengthPerGroup

   if NumGroups == 0, 
      warning(sprintf(['No variables with matching domains found!   ', ...
                       'This operator (%s) is not appropriate!   ', ...
                       'Please use another mutation operator ', ...
                       '(mutswap is automatically called now).'], mfilename));
      
      NewChrom = mutswap(Chrom, VLUB, MutOpt);
      return;
   end

% the variables are mutated with probability MutRate
% positions are calculated for first swap partner
% Get number of mutations and index of individuals
   [MutRows, Mut1Col] = find(rand(Nind, 1) < (MutRate * Nvar));
   NewMutRate = MutRate - 1/Nvar;
   if NewMutRate > 0, 
      [Mut2Row, Mut2Col] = find(rand(Nind, Nvar) < (NewMutRate));
      MutRows = [MutRows; Mut2Row];
   end
   NumMut = length(MutRows);


% Calculate the first swap point
   % Don't use Nvar, instead use number of variables with somewhere matching domain
   % these are the only possible mutation points
   IxPointGroup = ceil(rand(NumMut, 1) .* NumGroupVariables);
   Point1 = IndVarMember(IxPointGroup);
   
   GroupPoint1 = MemInGroup(Point1);
   RangePoint1 = LengthPerGroup(GroupPoint1)
   
% Matrix with range value maximal difference between positions
   % Get the actual range per group
   Ranges = ceil(RangePoint1 .* MutRange);
   % Ranges = Ranges .* (Steps >= 1) + 1 * (Steps < 1)

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
   Steps = round(Steps .* Ranges);
   % Ensure, that all steps < 1 are set to 1
   Steps = Steps .* (Steps >= 1) + 1 * (Steps < 1);
   % Ensure, that all steps == Ranges are set to Ranges-1
   Steps = Steps .* (Steps < Ranges) + (Ranges-1) .* (Steps == Ranges);

% Calculate the swap points
   StepRange = (RangePoint1 - Steps);     % range area available
   IxPoint1 = max(1, ceil(rand(NumMut, 1) .* StepRange));
   Point1 = IndVarMember(IxPoint1)
   Point2 = IndVarMember(IxPoint1 + Steps)

% Perform mutation 
   NewChrom = Chrom;
   variant = 1;      % 1: vectorized, 2: unvectorized
   if variant == 1,
      Index1= sub2ind(size(NewChrom), MutRows, Point1);
      Index2= sub2ind(size(NewChrom), MutRows, Point2);
      % [Index1, Index2]
      NewChrom(Index1) = Chrom(Index2);
      NewChrom(Index2) = Chrom(Index1);
      
   else
      for iind = 1:NumMut,
         NewChrom(MutRows(iind), Point1(iind)) = Chrom(MutRows(iind), Point2(iind));
         NewChrom(MutRows(iind), Point2(iind)) = Chrom(MutRows(iind), Point1(iind));
      end
   end


% End of function

% Test call
% clear all; vlub=[2 2 3 4 3 2 5 2 2; 12 12 13 14 13 12 15 12 12],Nvar=size(vlub,2);pop=initip(10,vlub);mutpop=mutswaptyp(pop,vlub,[1/Nvar,.6,4])
