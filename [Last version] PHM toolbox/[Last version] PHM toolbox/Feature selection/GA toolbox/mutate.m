% high level MUTATion function
%
% This function takes a matrix Chrom containing the 
% representation of the individuals in the current population,
% mutates the individuals and returns the resulting population.
% The function handles multiple populations and calls the low level
% mutation function for the actual mutation process.
% Different size of every subpopulation is supported.
%
% Syntax:  [NewChrom, SUBPOP] = mutate(MUT_F, Chrom, MutOpt, VLUB, SUBPOP)
%
% Input parameter:
%    MUT_F     - String containing the name of the mutation function
%    Chrom     - Matrix containing the chromosomes of the old
%                population. Each row corresponds to one individual.
%    MutOpt    - (optional) Vector/matrix containing mutation rate, mutation range
%                and mutation ptecision
%                multiple sets of options are supported, 1 row per subpopulation
%                if omitted or NaN, MutOpt = NaN is assumed
%                MutOpt(1): MutR - number containing the mutation rate -
%                           probability for mutation of a variable
%                           (real, integer and binary mutation)
%                MutOpt(2): MutRange - (optional) number for shrinking the
%                           mutation range in the range [0, 1], possibility to
%                           shrink the range of the mutation depending on,
%                           for instance actual generation.
%                           (real mutation)
%                MutOpt(3): MutPreci - (optional) number for precision of 
%                           mutation steps, (mutbm* - real mutation)
%                           MutNumOff - (optional) number of mutants per offspring
%                           (mutes* - real mutation)
%    VLUB      - Matrix containing the boundaries of each variable (real values)
%    SUBPOP    - (optional) Vector/scalar containing number of individuals
%                per subpopulation/number of subpopulations
%                if omitted or NaN, 1 subpopulation is assumed
%
% Output parameter:
%    NewChrom  - Matrix containing the chromosomes of the population
%                after mutation in the same format as Chrom.
%    SUBPOP    - (optional) Vector/scalar containing number of individuals
%                per subpopulation/number of subpopulations
%
% See also: mutreal, mutint, mutbin, migrate, recombin, selection

% Author:   Hartmut Pohlheim
% History:  19.03.1995  file created
%           07.08.1995  multi strategy support added
%                          parameter checking shortened
%           13.03.1996  test for mutnone added
%           29.04.1996  call of mutation function with eval changed, made
%                          problem with error
%           01.08.1996  new format for SUBPOP introduced, vector contains now
%                          number of individuals for every subpopulation
%           06.08.1996  multiple sets of parameters for MutOpt possible
%                          (one for every subpopulation)
%                       output parameter SUBPOP added (however, not needed
%                          at the moment, may be later in mutes*)
%           21.10.1996  new calling syntax of low level mutation function,
%                          thus, all mutation functions use same syntax
%           12.02.1997  calling syntax changed, VLUB is now 4th parameter
%                          and MutOpt is 3rd parameter
%           25.05.1999  eval replaced by feval
%                       test for mutnone simpler now
%           28.09.1999  added function pragmas for all mut functions
%           21.08.2003  extra check for empty MutOpt when setting MutOptIntern


function [NewChrom, SUBPOP] = mutate(MUT_F, Chrom, MutOpt, VLUB, SUBPOP);

% include mutation functions for compilation
%#function mutbin mutint mutreal mutrand mutrandreal mutrandint mutrandbin mutrandperm
%#function mutes1 mutes2 mutswap mutswaptyp mutexch

% Identify the population size (Nind) and the number of variables (Nvar)
   [Nind, Nvar] = size(Chrom);

% Check parameter consistency
   if nargin < 2,  error('Not enough input parameter'); end

   if nargin < 3, MutOpt = []; end

   if nargin < 4, VLUB = []; end
   if isnan(VLUB), VLUB = []; end
   if ~isempty(VLUB),
      [mF, nF] = size(VLUB);
      % nF and Nvar disagree for mutes*, thus, next line comment
      % if nF ~= Nvar, error('VLUB and Chrom disagree'); end
      if mF ~= 2, error('VLUB must be a matrix with 2 rows'); end
   end

   if nargin < 5, SUBPOP = []; end
   SUBPOP = compdiv('checksubpop', SUBPOP, Nind);
   NumSUBPOP = length(SUBPOP);

   if all([size(MUT_F,1)  == 1, NumSUBPOP > 1]), MUT_F  = repmat(MUT_F,  [NumSUBPOP, 1]); end
   if all([size(MutOpt,1) == 1, NumSUBPOP > 1]), MutOpt = repmat(MutOpt, [NumSUBPOP, 1]); end

% Select individuals of one subpopulation and call low level mutation function
   NewChrom = [];
   for irun = 1:NumSUBPOP,
      % Get number of individuals in actual subpopulation
      Nind = SUBPOP(irun);
      if isempty(MutOpt), MutOptIntern = []; else, MutOptIntern = MutOpt(irun,:); end
      
      % Copy individuals of actual subpopulation
      ChromSub = Chrom(sum(SUBPOP(1:irun-1))+1:sum(SUBPOP(1:irun)),:);

      % Test for special case 'mutnone': no mutation
      if strcmp(lower(deblank(MUT_F(irun,:))), 'mutnone'),
         NewChromSub = ChromSub;
         
      % Perform low level mutation for subpopulation
      else
         NewChromSub = feval(deblank(MUT_F(irun,:)), ChromSub, VLUB, MutOptIntern);
      end

      NewChrom=[NewChrom; NewChromSub];
      SUBPOP(irun) = size(NewChromSub, 1);
   end


% End of function

