% high level RECOMBINation function
%
% This function performs recombination between pairs of individuals
% and returns the new individuals after mating. The function handles
% multiple populations and calls the low level recombination function
% for the actual recombination process.
% Different size of every subpopulation is supported.
%
% Syntax:  NewChrom = recombin(REC_F, OldChrom, RecOpt, VLUB, SUBPOP)
%
% Input parameters:
%    REC_F     - String containing the name of the recombination or
%                recombination function
%    Chrom     - Matrix containing the chromosomes of the old
%                population. Each row corresponds to one individual
%    RecOpt    - (optional) Scalar containing the probability of 
%                recombination ocurring between pairs of individuals.
%                if omitted or NaN, 1 is assumed
%    VLUB      - (optional) matrix containing lower and upper
%                bounds of all variables, only for 'reclinex' needed
%    SUBPOP    - (optional) Vector/scalar containing number of individuals
%                per subpopulation/number of subpopulations
%                if omitted or NaN, 1 subpopulation is assumed
%
% Output parameter:
%    NewChrom  - Matrix containing the chromosomes of the population
%                after recombination in the same format as OldChrom.
%
% See also: recdis, recint, reclin, recmut, recsp, recdp, recsh, migrate, mutate, selection

%  Author:  Hartmut Pohlheim
%  History: 18.05.94    file created
%           07.08.95    multi strategy support added
%                          parameter checking shortened
%           13.03.96    test for recnone added
%           29.04.96    call of recombination function with eval changed,
%                          made problem with error
%           31.07.96    new format for SUBPOP introduced, vector contains now
%                          number of individuals for every subpopulation
%           12.02.97    calling syntax changed, VLUB is now 4th parameter
%                          and RecOpt is 3rd parameter,
%                       calling of reclinex (former recmut) changed, is now
%                          identical to all rec/xov functions except the
%                          additional boundaries
%           04.02.98    RecOpt can contain multiple values now, used for 
%                          different RecRate for every subpopulation
%           25.05.99    eval replaced by feval
%                       test for recnone/reclinex simpler now


function NewChrom = recombin(REC_F, Chrom, RecOpt, VLUB, SUBPOP);

% include recombination functions for compilation
%#function recdis reclin reclinex recint recgp recpm recmp recdp recdprs recsh recshrs recsp recsprs 

% Check parameter consistency
   if nargin < 2, error('Not enough input parameter'); end

   % Identify the population size
   [Nind, Nvar] = size(Chrom);
 
   if nargin < 5, SUBPOP = []; end
   SUBPOP = compdiv('checksubpop', SUBPOP, Nind);
   NumSUBPOP = length(SUBPOP);

   if nargin < 3, RecOpt = []; end
   if isnan(RecOpt), RecOpt = []; end
   if isempty(RecOpt), RecOpt = 1; end
   if any([any(RecOpt < 0), any(RecOpt > 1)]), error('RecOpt must contain values in [0, 1]'); end

   if all([size(REC_F,1)  == 1, NumSUBPOP > 1]), REC_F  = repmat(REC_F,  [NumSUBPOP, 1]); end
   if all([size(RecOpt,1) == 1, NumSUBPOP > 1]), RecOpt = repmat(RecOpt, [NumSUBPOP, 1]); end

   if nargin < 4, VLUB = []; end
   if isnan(VLUB), VLUB = []; end

% Select individuals of one subpopulation and call low level function
   NewChrom = [];
   for irun = 1:NumSUBPOP,
      % Get number of individuals in actual subpopulation
      Nind = SUBPOP(irun);
      RecOptIntern = RecOpt(irun,:);

      % Copy individuals of actual subpopulation
      ChromSub = Chrom(sum(SUBPOP(1:irun-1))+1:sum(SUBPOP(1:irun)),:);

      % Test for special case 'recnone': no recombination
      if strcmp(lower(deblank(REC_F(irun,:))), 'recnone'),
         NewChromSub = ChromSub;
      % Test for special case 'reclinex': extended line recombination
      elseif strcmp(lower(deblank(REC_F(irun,:))), 'reclinex'),
         if isempty(VLUB), error('For reclinex boundaries (VLUB) are needed!'); end
         NewChromSub = feval(deblank(REC_F(irun,:)), ChromSub, RecOptIntern, VLUB);
      else     % all other rec* functions
         NewChromSub = feval(deblank(REC_F(irun,:)), ChromSub, RecOptIntern);
      end
      NewChrom=[NewChrom; NewChromSub];
   end


% End of function
