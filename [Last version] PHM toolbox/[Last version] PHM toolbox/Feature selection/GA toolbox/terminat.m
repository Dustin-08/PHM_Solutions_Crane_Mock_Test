% TERMINATion function
%
% This function is the high level termination function.
% Different methods for termination are supported. (See
% explanation of TERM_F input parameter below.)
% All termination methods can be combined. Then termination
% occurs, if any one of the termination methods is true 
% (the methods are OR combined).
%
% Syntax:  [DoTerm, WhatTerm] = terminat(TERM_F, TermOpt, ActGen, ActTime, ...
%                               GlobalOpt, BestObjV, ObjV, Chrom, VLUB);
%
% Input parameters:
%    TERMMETHOD- String/Scalar containing name of the termination
%                function/termination method.
%                   1: terminate, if maximal number of generations
%                      TermOpt(1) is reached 
%                   2: terminate, if maximal execution/computing
%                      time TermOpt(2) is reached 
%                   3: terminate, if global optimum with termination
%                      precision TermOpt(3) is reached 
%                   4: terminate, if difference between mean of best 
%                      objective values of last xx generations and 
%                      current best objective value is smaller than 
%                      value in TermOpt(5)
%                   5: terminate, if standard deviation of objective
%                      values of current generation is smaller than
%                      value in TermOpt(4)
%                   6: terminate, if difference between the objective 
%                      values of the current worst and best individual 
%                      is smaller than value in TermOpt(6)
%                   7: terminate, if the difference between 1 and the phi
%                      value is smaller than value in TermOpt(7)
%                   8: terminate, if the difference between 1 and the kappa
%                      value is smaller than value in TermOpt(8)
%                   9: terminate, if cluster analysis tells you
%                      value is smaller than value in TermOpt(9)
%                >=12: terminate for each of the single digit 
%                       numbers
%                 for example:
%                  12: terminate for 1 or 2 
%                  13: terminate for 1 or 3 
%                  32: terminate for 3 or 2 
%                 135: terminate for 1 or 3 or 5 
%    TermOpt   - Vector/scalar containg parameters/values for ter-
%                mination methods.
%                TermOpt(1): maximal number of generations
%                TermOpt(2): maximal execution/computing time
%                TermOpt(3): difference to global optimum
%                TermOpt(4): difference of best objective value and
%                            running mean of last xx generation
%                TermOpt(5): minimal standard deviation
%                TermOpt(6): difference of best and worst objective
%                            value in current generation
%                TermOpt(7): difference between 1 and phi
%                TermOpt(8): difference between 1 and kappa
%                TermOpt(9): difference between 1 and cluster termination criteria
%    ActGen    - (optional) Scalar containing actual number of generations.
%    ActTime   - (optional) Scalar containing actual execution time in
%                minutes.
%    GlobalOpt - (optional) Scalar containg global optimum.
%    BestObjV  - (optional) Vector/matrix containing best objective
%                value(s) per generation for all previous generations.
%    ObjV      - (optional) Vector/Matrix containing all objective 
%                values of current generations.
%    Chrom     - (optional) Matrix containing decoded variables of all 
%                individuals in current generation
%    VLUB      - (optional) Matrix containing boundaries of variables
%
% Output parameters:
%    DoTerm    - Scalar indicating termination or not (termination
%                criterion fullfilled or not)
%                   0: do not terminate
%                   1: do terminate
%    WhatTerm  - Vector containing percent of termination criterion
%                already reached, for instance: 10 from 100 
%                generations would be result in WhatTerm(1) = 0.1,
%                similar for other termination methods,
%                if a criterion is not used, WhatTerm for this
%                criterion will be NaN, max(WhatTerm) will give the
%                current termination criterion
%
% See also: geamain

% Author:   Hartmut Pohlheim
% History:  10.10.1996  file created
%           22.10.1996  second output parameter WhatTerm added, used
%                          for returning percent of criterion already
%                          reached
%           03.02.1998  start of rework of termination function
%                       changed the meaning of values (MAXGEN == 1 now)
%                          excludes trouble with definition of 0 for or
%           04.02.1998  internal handling of multiple options changed 
%                          no extra variables, all in TermOptIntern, refe-
%                          renced by constants
%                       new termination options implemented
%                          standard deviation (option 4)
%                          running mean (option 5)
%                          good worst (option 6)
%           26.05.1998  new termination options implemented (thanks ro Michael)
%                          phi convergence and kappa convergence
%           20.07.1998  comments updated
%           03.09.1998  update of phi and kappa terminate (PHI is very similar
%                          to MINSTD and not robust in practical applications 
%                          (due to the use of worst ever objective value)
%                       new parameters TermChrom and VLUB (needed for KAPPA)
%                       QuoteMinPreci new calculated (log-scaled) for more realistic display
%           11.11.1998  update for new structure toolbox version, 
%                       termination methods defined by multiple values
%           29.03.1999  inclusion of cluster analysis
%           06.02.2005  small correction for termination diff to optimum, for non-elitest
%                          optimizations the worst objective value could be better than the 
%                          current "best", thus, we would get a negative termination percentage
%                          to correct this, the worst value is set to the best value when better


function [DoTerm, WhatTerm] = terminat(TERMMETHOD, TermOpt, ActGen, ActTime, GlobalOpt, BestObjV, ObjV, Chrom, VLUB);

format compact
% Define standard termination parameters
   MAXGEN = 1; MAXTIME = 2; MINPRECI = 3; MINRUNMEAN = 4; MINSTD = 5; MINGOODWORST = 6; PHI = 7; KAPPA = 8; CLUSTER = 9;
   % TermMaxGen = 100, TermMaxTime = 10, TermPreci = 1e-4,          
   % TermRunMean = 0, TermStd = 1e-3, TermGoodWorst = 1e-1
   % TermPhi = 1e-6, TermKappa = 1e-6, TermCluster = 0
   TermOptStandard = [100, 10, 1e-4, 0, 1e-3, 1e-1, 1e-6, 1e-6, 0]; 
   % Define possible termination methods
   TermMPossible = [1:length(TermOptStandard)];

% Check parameters and set standard parameters
   if nargin < 3, error('Not enough input parameter'); end
   
   if isnan(TERMMETHOD),  TERMMETHOD = []; end
   if isempty(TERMMETHOD), TERMMETHOD = 1; end
   if TERMMETHOD == 0, TERMMETHOD = 1; end
   if all([length(TERMMETHOD) == 1, TERMMETHOD > 12]), TERMMETHOD = str2num(sprintf('%d', TERMMETHOD)')'; end
   if (~any(TERMMETHOD(1) == TermMPossible)), 
      error(sprintf('termination method must be %g to %g (or concatenation)', ...
                    TermMPossible(1), TermMPossible(length(TermMPossible))));
   end
   
   if isnan(TermOpt), TermOpt = []; end
   if length(TermOpt) > length(TermOptStandard), error('Too many parameters in TermOpt'); end

   TermOptIntern = TermOptStandard; TermOptIntern(1:length(TermOpt)) = TermOpt;
   if any(TermOptIntern(TERMMETHOD) < 0),
      [dummy, SmallerIx] = find(TermOptIntern(TERMMETHOD) < 0);
      error(sprintf('When used, termination option  %d  must be >= 0 !', TERMMETHOD(SmallerIx(1))));
   end
   if any(isnan(TermOptIntern(TERMMETHOD))),
      [dummy, NaNIx] = find(isnan(TermOptIntern));
      TermOptIntern(NaNIx) = TermOptStandard(NaNIx);
   end
   
   if isnan(ActGen), ActGen = []; end
   if nargin < 4, ActTime = [];   end, if isnan(ActTime), ActTime = []; end
   if nargin < 5, GlobalOpt = []; end, if isnan(GlobalOpt), GlobalOpt = []; end
   if nargin < 6, BestObjV = [];  end, if isnan(BestObjV), BestObjV = []; end
   if nargin < 7, ObjV = [];      end, if isnan(ObjV), ObjV = []; end
   if nargin < 8, Chrom = [];     end, if isnan(Chrom), Chrom = []; end
   if nargin < 9, VLUB = [];      end, if isnan(VLUB), VLUB = []; end  

% compute for termination
   DoTerm = 0; WhatTerm = repmat(NaN, [1, length(TermMPossible)]);
   % terminate, if maximal number of generations (TermOpt(1)) is reached 
   if any(TERMMETHOD == MAXGEN),
      if isempty(ActGen),
         error('Value for actual generation for termination (max. generations) needed!');
      end
      if TermOptIntern(MAXGEN) > 0,
         DoTerm = [DoTerm, (floor(ActGen) >= floor(TermOptIntern(MAXGEN)))];
         WhatTerm(MAXGEN) =  floor(ActGen) / floor(TermOptIntern(MAXGEN));
      end
   end

   % terminate, if maximal execution/computing time (TermOpt(2)) is reached 
   if any(TERMMETHOD == MAXTIME),
      if isempty(ActTime),
         error('Value for actual execution time for termination (execution time) needed!');
      end
      if TermOptIntern(MAXTIME) > 0,
         DoTerm = [DoTerm, (ActTime >= TermOptIntern(MAXTIME))];
         WhatTerm(MAXTIME) =  ActTime / TermOptIntern(MAXTIME);
      end
   end

   % terminate, if global optimum with termination precision (TermOpt(3)) is reached 
   if any(TERMMETHOD == MINPRECI),
      if isempty(GlobalOpt),
         error('Value for global optimum for termination (global optimum) needed!');
      end
      if isempty(BestObjV),
         error('Vector/scalar of best objective values for termination (global optimum) needed!');
      end
      CurrentBestObjV = BestObjV(size(BestObjV, 1), 1);
      FirstBestObjV = BestObjV(1, 1);
      if CurrentBestObjV <= (GlobalOpt + TermOptIntern(MINPRECI)),
         QuotMinPreci = 1.0;
      else
         Worst2TermRange = (FirstBestObjV - (GlobalOpt + TermOptIntern(MINPRECI)));
         Best2TermRange = CurrentBestObjV - (GlobalOpt + TermOptIntern(MINPRECI));
         % When worst value is better than best value (can be the case for non-elitest optimization),
         % reset worst value to best value, thus, we do not get a negative termination percentage
         if Worst2TermRange < Best2TermRange, Worst2TermRange = Best2TermRange; end
         QuotMinPreci = 1-log(Best2TermRange+1)/ log(Worst2TermRange+1);
         if QuotMinPreci >= .99992, QuotMinPreci = .99991; end
      end
      
      DoTerm = [DoTerm, QuotMinPreci >= .99999];
      WhatTerm(MINPRECI) = QuotMinPreci;
   end

   % terminate, if running mean of best objective values over
   % last generations is smaller than parameter TermOpt(4)
   if any(TERMMETHOD == MINRUNMEAN),
      if isempty(ActGen),
         error('Value for actual generation for termination (min running mean) needed!');
      end
      if isempty(BestObjV),
         error('Vector/scalar of best objective values for termination (min running mean) needed!');
      end
      NeededMinGen = 15;    % parameter for this method, number of generation for mean calculation
      if ActGen >= NeededMinGen,
         NObjV = size(BestObjV, 1);
         DiffBestMean = mean(BestObjV(NObjV-NeededMinGen+1:NObjV,1)) - BestObjV(NObjV, 1);
         if DiffBestMean == 0, DiffBestMean = TermOptIntern(MINRUNMEAN) / 1.11; end
         % When parameter os zero, just the number of generations with unchanged best objv is important
         if TermOptIntern(MINRUNMEAN) == 0, 
            % Get diff between last NeededMinGen objective values
            DiffObjV = diff(BestObjV(NObjV-NeededMinGen+1:NObjV,1));
            % Calculate percentage of generations, where the objective value didn't change
            QuotRunMean = (NeededMinGen -1 - sum(abs(DiffObjV) > 0))/ (NeededMinGen-1);
         else
            % Standard calculation for running mean, when para larger than 0
            QuotRunMean = TermOptIntern(MINRUNMEAN) / DiffBestMean;
         end
         DoTerm = [DoTerm, QuotRunMean >= .99999];
         WhatTerm(MINRUNMEAN) = QuotRunMean;
      else
         DoTerm = [DoTerm, 0];
         WhatTerm(MINRUNMEAN) =  0.0001 * ActGen;
      end
      
   end

   % terminate, if standard deviation of objective values of current generation 
   % is smaller than parameter TermOpt(5)
   if any(TERMMETHOD == MINSTD),
      if isempty(ObjV),
         error('All current objective values for termination (min standard deviation) needed!');
      end
      StdObjV = std(ObjV(:,1));
      if StdObjV == 0, StdObjV = TermOptIntern(MINSTD) / 1.11; end
      QuotStd = TermOptIntern(MINSTD) / StdObjV;
      DoTerm = [DoTerm, QuotStd >= .99999];
      WhatTerm(MINSTD) = QuotStd;
   end

   % terminate, if standard deviation of objective values of current generation 
   % is smaller than parameter TermOpt(4)
   if any(TERMMETHOD == MINGOODWORST),
      if isempty(ObjV),
         error('All current objective values for termination (good worst individual) needed!');
      end
      DiffGoodWorst = max(ObjV(:,1)) - min(ObjV(:,1));
      if DiffGoodWorst == 0, DiffGoodWorst = TermOptIntern(MINGOODWORST) / 1.11; end
      QuotGoodWorst = TermOptIntern(MINGOODWORST) / DiffGoodWorst;
      DoTerm = [DoTerm, QuotGoodWorst >= .99999];
      WhatTerm(MINGOODWORST) = QuotGoodWorst;
   end

   % terminate, if phi convergence measure is close to 1
   % Does phi convergence make any sense for multi objective results ???
   % Do we really need the worst objective value ever ??? It's very often
   % far away from the realistic and good objective values.
   % At the moment, just the worst objective value of the current generation is used.
   if any(TERMMETHOD == PHI),
      if any([isempty(BestObjV), isempty(ObjV)]),
         error('Best objective value (BestObjV) and/or all objective values (ObjV) for termination (phi convergence) needed!');
      end
      ObjVWorst = max(ObjV);     % BestObjV(1,:);
      Phi   = compdiv('phi_convergence', BestObjV(size(BestObjV, 1),:), ObjVWorst, ObjV);
      DiffPhi = 1.0 - Phi;
      QuotPhi = TermOptIntern(PHI) / DiffPhi;
      DoTerm = [DoTerm, QuotPhi > .99999];
      WhatTerm(PHI) = QuotPhi;
   end

   % terminate, if kappa convergence measure is close to 1
   if any(TERMMETHOD == KAPPA),
      if any([isempty(Chrom), isempty(VLUB)]),
         error('Individuals of current generation (Chrom) and/or boundaries of variables (VLUB) for termination (kappa convergence) needed!');
      end
      Kappa = compdiv('kappa_convergence', Chrom, VLUB);
      DiffKappa = 1.0 - Kappa;
      QuotKappa = TermOptIntern(KAPPA) / DiffKappa;
      DoTerm = [DoTerm, QuotKappa > .99999];
      WhatTerm(KAPPA) = QuotKappa;
   end

   % terminate, if cluster analysis measure is close to 1
   if any(TERMMETHOD == CLUSTER),
      if any([isempty(ActGen), isempty(Chrom), isempty(ObjV), isempty(VLUB), isempty(BestObjV)]),
         error('many things are needed for cluster analysis termination (ActGen, Chrom, ObjV, BestObjV, VLUB)!');
      end
      TermCluster = clusterm([], ActGen, Chrom, ObjV, BestObjV, VLUB);
      %%TermCluster = 0;  % just for compilation
      TermCluster = TermCluster / (1 - TermOptIntern(CLUSTER));
      DoTerm = [DoTerm, TermCluster > .99999];
      WhatTerm(CLUSTER) = TermCluster;
   end


% Compress termination values
   if any(DoTerm == 1), DoTerm = 1; else DoTerm = 0; end


% End of function
