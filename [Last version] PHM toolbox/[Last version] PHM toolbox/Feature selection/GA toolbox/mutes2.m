% MUTation by Evolutionary Strategies 2, derandomized self adaption
%
% This function takes a matrix ChromMut containing the real
% representation of the individuals in the current population and the 
% mutation step sizes, mutates the individuals and returns
% the offspring and the new mutation step matrix in NewChromMut.
%
% This function implements the ES algorithm with derandomized mutative
% step-size control using accumulated information
% Ostermeier, Gawelczyk, Hansen: Step-Size Adaptation Based on Non-Local
% Use of Selection Information. PPSN3, pp. 189-198, 1994.
%
% Syntax:  [NewChromMut] = mutes2(ChromMut, FieldDR, MutOpt)
%
% Input parameter:
%    ChromMut  - Matrix containing the chromosomes and the mutation variables
%                of the old population. Each row corresponds to one individual.
%                First third columns contain the chromosomes, second
%                third the individual step sizes and the third the accumulated
%                information
%                ChromMut = [Chrom, MutSteps, AccuInfo]
%    FieldDR   - Matrix describing the boundaries of each variable.
%    MutOpt    - (optional) Vector containing mutation rate and shrink value
%                not used here
%                MutOpt(1): MutRate - number containing the mutation rate -
%                           probability for mutation of a variable
%                           not used here
%                MutOpt(2): MutShrink - (optional) number for shrinking the
%                           mutation range in the range [0 ???], possibility to
%                           shrink the range of the mutation.
%                           (used for shrinking the starting step sizes)
%                           if omitted or NaN, MutShrink = 1 is assumed
%                MutOpt(3): MutNumOff - (optional) Number of offspring to be
%                           produced per parent
%                           if omitted or NaN, MutNumOff = 1 is assumed
%                           at the moment not used, MutNumOff = 1 all the time
%
% Output parameter:
%    NewChromMut-Matrix containing the chromosomes and the mutation variables
%                of the new population after mutation, ready to be evaluated,
%                in the same format as ChromMut. 
%
% See also: mutes1, mutate, mutreal, mutbin, mutint

% Author:   Hartmut Pohlheim
% History:  12.12.96    file created
%           17.12.96    implementation checked against PPSN3, S.191
%           18.12.96    check for variable boundaries added, if outside
%                          the boundaries, individual step size for
%                          this variable is divided by 2
%           22.04.97    use of range in calculation of new variables,
%                          see RangeFieldDR below
%           12.06.97    use of MutOpt(2) - MutShrink - for scaling the step
%                          sizes, useful for definition of initial step sizes
%           02.03.98    excluded setting of variables to boundaries, 
%                          when variables outside boundaries
%           03.09.98    Scaling of step sizes MutOpt(2) - MutShrink can be 
%                          larger as 1 as well
%           23.09.98    renamed to mutes2


function [NewChromMut] = mutes2(ChromMut, FieldDR, MutOpt);

% Identify the population size (Nind) and the number of variables (Nvar)
   [Nind,NVAR] = size(ChromMut);
   if (ceil(NVAR/3) ~= NVAR/3),
      error('Mutation: size of individuals and mutation matrix disagree!');
   end
   Nvar = NVAR / 3;
   
% Set standard mutation parameter
   MutOptStandard = [1/Nvar, 1, 1];      % MutRate = 1/Nvar, MutShrink = 1, MutNumOff = 1

% Check parameter consistency
   if nargin < 2,  error('Not enough input parameter'); end

   [mF, nF] = size(FieldDR);
   if mF ~= 2, error('FieldDR must be a matrix with 2 rows'); end
   if Nvar ~= nF, error('FieldDR and OldChrom disagree'); end

   if nargin < 3, MutOpt = []; end
   if isnan(MutOpt), MutOpt = []; end
   if length(MutOpt) > length(MutOptStandard), error(' Too many parameter in MutOpt'); end

   MutOptIntern = MutOptStandard; MutOptIntern(1:length(MutOpt)) = MutOpt;
   MutRate = MutOptIntern(1); MutShrink = MutOptIntern(2); MutNumOff = MutOptIntern(3);

   if isnan(MutRate), MutRate = MutOptStandard(1);
   elseif (MutRate < 0 | MutRate > 1), error('Parameter for mutation rate must be a scalar in [0, 1]'); end

   if isnan(MutShrink), MutShrink = MutOptStandard(2);
   elseif (MutShrink < 0), 
      error('Parameter for scaling mutation steps must be larger than 0 !');
   end

   % if isnan(MutNumOff), MutNumOff = MutOptStandard(3);
   % elseif MutNumOff < 1, error('Parameter for number of offspring must be greater than 1'); end
   MutNumOff = 1;

% Copy individuals
   IndChrom = repmat(ChromMut(:, 1:Nvar), [MutNumOff 1]);
   IndMutMat = repmat(ChromMut(:, Nvar+1:2*Nvar), [MutNumOff 1]);
   IndZetMat = repmat(ChromMut(:, 2*Nvar+1:3*Nvar), [MutNumOff 1]);
   IndAll = Nind * MutNumOff;

% Self adaption mutation variables
   BETA_ALL = sqrt(1/Nvar);
   BETA_ONE = 1/Nvar;
   BE = 0.35;
   CE = sqrt(1/Nvar);

% Create random values and accumulation of mutations
   NewZetOff = randn(IndAll, Nvar);
   NewZetMat = (1 - CE) * IndZetMat + CE * NewZetOff;

% Mutate mutation matrix
   NormZet = sqrt(diag(NewZetMat * NewZetMat'));
   % for irun = 1:IndAll, NormZet(irun) = norm(NewZetMat(irun,:)); end
   ALL = exp(NormZet./ (sqrt(CE/(2-CE)) * sqrt(Nvar)) - 1 + 1/(5*Nvar)) .^ BETA_ALL;
   ALL = repmat(ALL, [1, Nvar]);
   ONE = (abs(NewZetMat) ./ sqrt(CE/(2-CE)) + BE) .^ BETA_ONE;
  
% Calculate mutation matrix for storing
   NewMutMat = IndMutMat .* ALL .* ONE;

% Create offspring
% Include range of variables (IndMutMat contains only relative step sizes)
% and the shrinkage of the mutation step sizes
   RangeFieldDR = MutShrink * repmat(FieldDR(2,:)-FieldDR(1,:), [IndAll, 1]);
   NewChrom = IndChrom + IndMutMat .* NewZetOff .* RangeFieldDR;

% Reduce mutation step size if variable outside boundaries
   Outside = NewChrom < repmat(FieldDR(1,:),[IndAll 1]);
   Outside = Outside + (NewChrom > repmat(FieldDR(2,:), [IndAll 1]));
   % divide mutation step size by 2, if variable outside boundaries
   Outside = 0.5 * Outside + (Outside == 0);
   NewMutMat = NewMutMat .* Outside;

% Concatenate output matrix
   NewChromMut = [NewChrom, NewMutMat, NewZetMat];


% End of function
