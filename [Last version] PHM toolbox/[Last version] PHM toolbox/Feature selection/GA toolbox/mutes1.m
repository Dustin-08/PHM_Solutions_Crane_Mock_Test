% MUTation by Evolutionary Strategies 1, derandomized Self Adaption
%
% This function takes a matrix OldChrom containing the real
% representation of the individuals in the current population,
% mutates the individuals corresponding to OldMutMat and returns
% the offspring, NewChrom and the new mutation step matrix, NewMutMat.
%
% This function implements the derandomized ES-algorithm with
% individual step sizes.
% Ostermeier, Gawelczyk, Hansen: A Derandomized Approach to
% Self Adaption of Evolution Strategies. Technical Report TR-93-003,
% TU Berlin, 1993.
%
% Syntax:  [NewChromMut] = mutes1(ChromMut, FieldDR, MutOpt)
%
% Input parameter:
%    ChromMut  - Matrix containing the chromosomes and the mutation variables
%                of the old population. Each row corresponds to one individual.
%                First half columns contain the chromosomes, second
%                half the individual step sizes.
%    FieldDR   - Matrix describing the boundaries of each variable.
%    MutOpt    - (optional) Vector containing mutation rate and shrink value
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
%                First half columns contain the chromosomes, second
%                half the mutation variables.
%
% See also: mutes2, mutate, mutreal, mutbin, mutint

% Author:   Hartmut Pohlheim
% History:  03.02.95    file created
%           23.02.96    New parameter calling, Chromosomes and 
%                          mutation steps together in one input and
%                          output variable 
%           15.03.96    calling syntax identical to all mutation functions
%           19.03.96    reduction of mutation step size if variable outside
%                          boundaries added
%           09.05.96    default number of offpring reduced to 1, control of
%                          parent-offspring relation is done outside (by GGAP)
%           18.12.96    implementation checked, full reference included
%           22.04.97    use of range in calculation of new variables,
%                          see RangeFieldDR below
%           12.06.97    use of MutOpt(2) - MutShrink - for scaling the step
%                          sizes, useful for definition of initial step sizes
%           02.03.98    excluded setting of variables to boundaries, 
%                          when variables outside boundaries
%           03.09.98    Scaling of step sizes MutOpt(2) - MutShrink can be 
%                          larger as 1 as well
%           23.09.98    renamed to mutes1


function [NewChromMut] = mutes1(ChromMut, FieldDR, MutOpt);

% Identify the population size (Nind) and the number of variables (Nvar)
   [Nind, NVAR] = size(ChromMut);
   if (ceil(NVAR/2) ~= NVAR/2),
      error('Mutation: size of individuals and mutation matrix disagree!');
   end
   Nvar = NVAR / 2;
   
% Set standard mutation parameter
   MutOptStandard = [1/Nvar, 1, 1];      % MutRate = 1/Nvar, MutShrink = 1, NumOff = 1

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
      error('Parameter for shrinking mutation range must be larger than 0 !');
   end

   % if isnan(MutNumOff), MutNumOff = MutOptStandard(3);
   % elseif MutNumOff < 1, error('Parameter for number of offspring must be greater than 1'); end
   MutNumOff = 1;

% Self adaption mutation variables
   BETAALL = sqrt(1/Nvar);
   BETASCAL = 1/Nvar;
   BE = 0.35;
   ALPHA = 1.4;

% Copy individuals
   IndChrom = repmat(ChromMut(:, 1:Nvar), [MutNumOff 1]);
   IndMutMat = repmat(ChromMut(:, Nvar+1:2*Nvar), [MutNumOff 1]);
   IndAll = Nind * MutNumOff;
   
% Create matrices for mutation
   % Create matrix with alpha and 1/alpha with equal probability
   ZetaAllMat = rand(IndAll, 1) < 0.5;
   ZetaAllMat = ALPHA * ZetaAllMat + 1/ALPHA * (~ZetaAllMat);
   ZetaAllMat = repmat(ZetaAllMat, [1 Nvar]);

   % Create matrix with positiv normally distributed numbers
   ZetaScalMat = abs(randn(IndAll, Nvar));

   % Compute Z-matrix with -1 and +1
   ZetMat = 1 - 2 *(rand(IndAll, Nvar) < 0.5);

% Perform mutation 
% Include range of variables (IndMutMat contains only relative step sizes)
% and the shrinkage of the mutation step sizes
   RangeFieldDR = MutShrink * repmat(FieldDR(2,:)-FieldDR(1,:), [IndAll, 1]);
   NewChrom = IndChrom + IndMutMat .* ZetaAllMat .* ZetaScalMat .* ZetMat .* RangeFieldDR;
   
% Mutate mutation matrix for storing
   NewMutMat = IndMutMat .* (ZetaAllMat.^BETAALL) .* ((ZetaScalMat+BE).^BETASCAL);

% Reduce mutation step size if variable outside boundaries
   Outside = NewChrom < repmat(FieldDR(1,:),[IndAll 1]);
   Outside = Outside + (NewChrom > repmat(FieldDR(2,:), [IndAll 1]));
   % divide mutation step size by 2, if variable outside boundaries
   Outside = 0.5 * Outside + (Outside == 0);
   NewMutMat = NewMutMat .* Outside;

% Concatenate Chrom (individuals) and MutMat (mutation steps) together for output
   NewChromMut = [NewChrom NewMutMat];


% End of function
