% high level SELECTion function
%
% This function is the high level universal selection function. The
% function handles multiple populations and calls the low level
% selection function for the actual selection process.
% Different size of every subpopulation is supported.
%
% Syntax:  [SelCh, SUBPOPSel, SelIx] = selection(SEL_F, Chrom, FitnV, GGAP, SUBPOP, SelOpt)
%
% Input parameters:
%    SEL_F     - Name of the selection function
%    Chrom     - Matrix containing the individuals (parents) of the current
%                population. Each row corresponds to one individual.
%    FitnV     - Column vector containing the fitness values of the
%                individuals in the population.
%    GGAP      - (optional) Rate of individuals to be selected
%                if omitted 1.0 is assumed
%    SUBPOP    - (optional) Vector/scalar containing number of individuals
%                per subpopulation/number of subpopulations
%                if omitted or NaN, 1 subpopulation is assumed
%    SelOpt    - (optional) Vector containing selection paremeters
%                SelOpt(1, ...): used in 'sellocal'
%
% Output parameters:
%    SelCh     - Matrix containing the selected individuals.
%    SUBPOPSel - Vector containing number of individuals selected per
%                subpopulation
%    SelIx     - (optional) Column vector containing the indices
%                of the selected individuals.
%
% See also: selrws, selsus, sellocal, seltrunc, reins, reinsloc, migrate, mutate, recombin

% Author:   Hartmut Pohlheim
% History:  10.05.94    file created
%           09.09.94    SelIx as output parameter
%           17.02.95    SelOpt added
%           04.08.95    multi strategy support added
%                       different parameters (SEL_F, SelOpt) per subpopulation
%                       parameter checking shortened
%           29.04.96    call of selection function with eval changed,
%                          made problem with error
%           31.07.96    new format for SUBPOP introduced, vector contains now
%                          number of individuals for every subpopulation
%                       output parameter SUBPOPSel added
%                       ordering of output parameters changed
%           07.03.97    computation of NSel changed, from round to floor
%                          thus, if GGAP is smaller than 1, NSel is definitely
%                          smaller than Nind
%           25.05.99    eval replaced by feval
%                       parameter handling enhanced


function [SelCh, SUBPOPSel, SelIx] = selection(SEL_F, Chrom, FitnV, GGAP, SUBPOP, SelOpt);

% include selection functions for compilation
%#function selsus selrws seltrunc seltour sellocal

% Define default parameters
   GGAPStandard = 1;

% Check parameter consistency
   if nargin < 3, error('Not enough input parameter'); end

   % Identify the population size (Nind)
   [NindCh,Nvar] = size(Chrom);
   [NindF,VarF] = size(FitnV);
   if NindCh ~= NindF, error('Number of entires (rows) in Chrom and FitnV disagree'); end
   if VarF ~= 1, error('FitnV must be a column vector'); end
  
   if nargin < 5, SUBPOP = []; end
   SUBPOP = compdiv('checksubpop', SUBPOP, NindCh);
   NumSUBPOP = length(SUBPOP);

   if (size(SEL_F,1) == 1 & NumSUBPOP > 1), SEL_F = repmat(SEL_F, [NumSUBPOP, 1]); end

   if nargin < 4, GGAP = []; end
   if isempty(GGAP), GGAP = NaN; end
   if any(GGAP < 0), warning('At least one generation gap was smaller than 0!'); GGAP = max(0, GGAP); end
   if any(isnan(GGAP)), IxNaN = isnan(GGAP); GGAP(IxNaN) = GGAPStandard; end
   if length(GGAP) == 1, GGAP = repmat(GGAP, [NumSUBPOP, 1]); end

   if nargin < 6, SelOpt = []; end
   if isempty(SelOpt), SelOpt = NaN; end
   if (size(SelOpt,1) == 1 & NumSUBPOP > 1), SelOpt = repmat(SelOpt, [NumSUBPOP, 1]); end


% Select individuals from population
   SelCh = []; SelIx = []; SUBPOPSel = [];
   for irun = 1:NumSUBPOP,
      % Get number of individuals in actual subpopulation
      Nind = SUBPOP(irun);

      % Copy fitness values of actual subpopulation
      FitnVSub = FitnV(sum(SUBPOP(1:irun-1))+1:sum(SUBPOP(1:irun)));

      % Compute number of new individuals (to select)
      NSel = floor(Nind * GGAP(irun));

      % Check and handle for one individual in subpopulation
      if Nind == 1,
         NSel = max(NSel, 1);
         ChrIx = ones(NSel, 1) + sum(SUBPOP(1:irun-1));
         SelCh = [SelCh; repmat(Chrom(ChrIx(1),:),[NSel, 1])];
      else
         NSel = max(NSel, 2);
         ChrIx = feval(deblank(SEL_F(irun,:)), FitnVSub, NSel, SelOpt(irun,:));
         ChrIx = ChrIx + sum(SUBPOP(1:irun-1));
         SelCh = [SelCh; Chrom(ChrIx,:)];
      end

      SelIx = [SelIx; ChrIx];
      SUBPOPSel = [SUBPOPSel; length(ChrIx)];
   end
 

% End of function
