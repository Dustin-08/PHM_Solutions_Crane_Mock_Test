% REINSertion of offspring in REGional population model replacing parents
%
% This function performs insertion of offspring into the current 
% population, replacing parents with offspring and returning the
% resulting population. The population can be divided in different
% subpopulation (regional model).
% The offspring are contained in the matrix SelCh and the parents 
% in the matrix Chrom. Each row in Chrom and Selch corresponds
% to one individual.
% If the objective values of the population (ObjVCh) and the
% offspring (ObjVSel) are input parameter and ObjVCh is output
% parameter the objective values are copied, according to the
% insertion of offspring, saving the recomputation of the objective
% values for the whole population.
% The function can handle multiple objective values per individual. 
% For fitness-based reinsertion the fitness values/ranking of the
% population (RankCh) are needed. If omitted or empty single objective
% scaling using the first column of ObjVCh is assumed.
% If the number of offspring is greater than the number of offspring
% to reinsert the fitness values/ranking of the offspring (RankSel)
% are needed. If omitted or empty single objective scaling using the
% first column of ObjVSel is assumed.
% Different size of every subpopulation is supported.
%
% Syntax:  [Chrom, ObjVCh] = reinsreg(Chrom, SelCh, SUBPOPCh, SUBPOPSel, InsOpt, ObjVCh, ObjVSel, RankCh, RankSel)
%
% Input parameters:
%    Chrom     - Matrix containing the individuals (parents) of the current
%                population. Each row corresponds to one individual.
%    SelCh     - Matrix containing the offspring of the current
%                population. Each row corresponds to one individual.
%    SUBPOPCh  - (optional) Vector/scalar containing number of individuals
%                per subpopulation/number of subpopulations of Chrom (parents)
%                if omitted or NaN, 1 subpopulation is assumed
%    SUBPOPSel - (optional) Vector/scalar containing number of individuals
%                per subpopulation/number of subpopulations of SelCh (offspring)
%                if omitted or NaN, the same as SUBPOPCh is initially assumed
%    InsOpt    - (optional) Vector containing the insertion method parameters
%                InsOpt(1): Select - number indicating kind of insertion
%                             0 - uniform insertion
%                           >=2 - fitness-based insertion
%                           if omitted or NaN, 0 is assumed
%                InsOpt(2): INSR - Rate of offspring to be inserted per
%                           subpopulation (% of subpopulation)
%                           if omitted or NaN, 1.0 (100%) is assumed
%    ObjVCh    - (optional) Column vector or matrix containing the objective values
%                of the individuals (parents - Chrom) in the current population,
%                needed for fitness-based insertion
%                saves recalculation of objective values for population
%    ObjVSel   - (optional) Column vector or matrix containing the objective values
%                of the offspring (SelCh) in the current population, needed for
%                partial insertion of offspring,
%                saves recalculation of objective values for population
%    RankCh    - (optional) Column vector containing the fitness values (obtained
%                by ranking) of the individuals (parents - Chrom) in the current
%                population, best individual has highest value,
%                if omitted or empty, single objective scaling using ObjVCh is assumed
%    RankSel   - (optional) Column vector containing the fitness values (obtained
%                by ranking) of the offspring (SelCh) in the current
%                population, best offspring has highest value
%                if omitted or empty, single objective scaling using ObjVSel is assumed
%
% Output parameters:
%    Chrom     - Matrix containing the individuals of the current
%                population after reinsertion.
%    ObjVCh    - if ObjVCh and ObjVSel are input parameter, than column vector containing
%                the objective values of the individuals of the current
%                generation after reinsertion.
%
% See also: reins, reinsloc, sellocal, ranking, geamain

% Author:   Hartmut Pohlheim
% History:  10.05.94    file created
%           19.05.94    parameter checking improved
%           07.06.95    rank based reinsertion possible (used for 
%                          reinsertion with multiobjective problems)
%           08.06.95    long description added
%           02.07.96    parameter checking changed, much smaller now and
%                             easier to understand and maintain
%           01.08.96    new format for SUBPOP introduced, vector contains now
%                          number of individuals for every subpopulation
%                       some parameter names changed to more meaningful names
%                       calling syntax of function changed, parameter SUBPOPSel added
%           12.02.97    function renamed from reins to reinsreg
%           31.07.97    flipud included for handling of NaN


function [Chrom, ObjVCh] = reinsreg(Chrom, SelCh, SUBPOPCh, SUBPOPSel, InsOpt, ObjVCh, ObjVSel, RankCh, RankSel, Dummy);

% Set standard insertion parameter
   InsOptStandard = [0, 1];      % Select = 0; INSR = 1;

% Check parameter consistency
   if nargin < 2, error('Not enough input parameter'); end

   [NindCh, NvarP] = size(Chrom);
   [NindSel, NvarO] = size(SelCh);

   if nargin < 3, SUBPOPCh = []; end
   if isnan(SUBPOPCh), SUBPOPCh = []; end, if isempty(SUBPOPCh), SUBPOPCh = 1; end
   if nargin < 4, SUBPOPSel = []; end
   if isnan(SUBPOPSel), SUBPOPSel = []; end, if isempty(SUBPOPSel), SUBPOPSel = SUBPOPCh; end
   SUBPOPCh  = compdiv('checksubpop', SUBPOPCh, NindCh);
   SUBPOPSel = compdiv('checksubpop', SUBPOPSel, NindSel);
   if length(SUBPOPCh) ~= length(SUBPOPSel), error('Length of SUBPOPCh and SUBPOPSel disagree!'); end
   
   if nargin < 5, InsOpt = []; end   
   if length(InsOpt) > length(InsOptStandard), error('Too many parameter in InsOpt!'); end

   InsOptIntern = InsOptStandard; InsOptIntern(1:length(InsOpt)) = InsOpt;
   Select = InsOptIntern(1); INSR = InsOptIntern(2);

   if isnan(Select), Select = InsOptStandard(1);
   elseif Select < 0, error('Parameter for selection method must be >= 0!'); end

   if isnan(INSR), INSR = InsOptStandard(2);
   elseif (INSR < 0 | INSR > 1), error('Parameter for insertion rate must be a scalar in [0, 1]'); end
   
   IsObjVCh = 0; IsObjVSel = 0;
   if nargin > 5, 
      if ~isempty(ObjVCh), 
         [mO, nO] = size(ObjVCh);
         if NindCh ~= mO, error('Chrom and ObjVCh disagree'); end
         IsObjVCh = 1;
      end
   end
   if nargin > 6, 
      if ~isempty(ObjVSel)
         [mO, nO] = size(ObjVSel);
         if NindSel ~= mO, error('SelCh and ObjVSel disagree'); end
         IsObjVSel = 1;
      end
   end

   if (nargout == 2 & (IsObjVCh == 0 | IsObjVSel == 0)),
      error('Input parameter ObjVCh and/or ObjVSel for output of ObjVCh missing!');
   end

   IsRankCh = 0; IsRankSel = 0;
   if nargin > 7, 
      if ~isempty(RankCh), 
         [mO, nO] = size(RankCh);
         if nO ~= 1, error('RankCh must be a column vector'); end
         if NindCh ~= mO, error('Chrom and RankCh disagree'); end
         IsRankCh = 1;
      end
   end
   if nargin > 8, 
      if ~isempty(RankSel), 
         [mO, nO] = size(RankSel);
         if nO ~= 1, error('RankSel must be a column vector'); end
         if NindSel ~= mO, error('SelCh and RankSel disagree'); end
         IsRankSel = 1;
      end
   end
       
   if all([INSR < 1, IsObjVSel == 0, IsRankSel == 0]),
      error('For selection of offspring ObjVSel/RankSel is needed');
   end 
   if all([Select >= 2, IsObjVCh == 0, IsRankCh == 0]),
      error('ObjVCh/RankCh for fitness-based insertion needed');
   end

   % For no insertion nothing to do
   if INSR == 0, return; end

   % If no rank values are provided; produce them assuming single objective problems
   if all([Select >= 2, IsRankCh == 0]), RankCh = -ObjVCh(:,1); end
   if all([IsObjVSel == 1, IsRankSel == 0]), RankSel = -ObjVSel(:,1); end

% perform insertion for each subpopulation
   for irun = 1:length(SUBPOPCh),
      % Get number of individuals/offspring in actual subpopulation
         NindCh = SUBPOPCh(irun);
         NindSel = SUBPOPSel(irun);

      % Compute number of offspring to insert
         NIns = min(max(round(INSR * NindCh), 1), NindSel);

      % Calculate positions in old subpopulation, where offsprings are inserted
         if Select >= 2,    % fitness-based reinsertion, select least fit individuals
            % Sort first for best individual (-highest rank val is first) and 
            % flip afterwards - necessary for NaN, NaN should be the first to replace
            [Dummy, ChIx] = sort(-RankCh(sum(SUBPOPCh(1:irun-1))+1:sum(SUBPOPCh(1:irun))));
            ChIx = flipud(ChIx);
         else               % uniform reinsertion
            [Dummy, ChIx] = sort(rand(NindCh,1));
         end
         PopIx = ChIx((1:NIns)') + sum(SUBPOPCh(1:irun-1));
      % Calculate position of NIns-% best offspring
         if (NIns < NindSel),  % Select best offspring
            % Sort for worst individual (highest obj val is first),
            % NaN should be the last to insert
            [Dummy,OffIx] = sort(-RankSel(sum(SUBPOPSel(1:irun-1))+1:sum(SUBPOPSel(1:irun))));
         else              
            OffIx = (1:NIns)';
         end
         SelIx = OffIx((1:NIns)') + sum(SUBPOPSel(1:irun-1));
      % Insert offspring in subpopulation -> new subpopulation
         Chrom(PopIx,:) = SelCh(SelIx,:);
         if (IsObjVCh == 1 & IsObjVSel == 1), ObjVCh(PopIx,:) = ObjVSel(SelIx,:); end
   end


% End of function
