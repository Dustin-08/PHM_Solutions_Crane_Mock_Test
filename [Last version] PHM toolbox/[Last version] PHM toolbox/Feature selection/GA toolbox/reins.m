% high-level RE-INSertion function
%
% This function performs insertion of offspring into the current 
% population, replacing parents with offspring and returning the
% resulting population.
% The offspring are contained in the matrix SelCh and the parents 
% in the matrix Chrom. Each row in Chrom and Selch corresponds
% to one individual.
% If the objective values of the population (ObjVCh) and the
% offspring (ObjVSel) are input parameter and ObjVCh is output
% parameter the objective values are copied, according to the
% insertion of offspring, saving the recomputation of the objective
% values for the whole population. The function can handle multiple
% objective values per individual. 
% For fitness-based reinsertion the fitness values/ranking of the
% population (RankCh) are needed. If omitted or empty single objective
% scaling using the first column of ObjVCh is assumed.
% If the number of offspring is greater than the number of offspring
% to reinsert the fitness values/ranking of the offspring (RankSel)
% is needed. If omitted or empty single objective scaling using the
% first column of ObjVSel is assumed.
% Different size of every subpopulation is supported.
% For the actual reinsertion low-level functions corresponding the
% used population model (regional or local model) are called.
%
% Syntax:  [Chrom, ObjVCh] = reins(Chrom, SelCh, SUBPOPCh, SUBPOPSel, InsOpt, ObjVCh, ObjVSel, RankCh, RankSel, SelIx, SelFun)
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
%                InsOpt(1): Select - number indicating reinsertion method
%                              kind of selection of parents to replace
%                           for description see respective functions
%                              reinsreg and reinsloc
%                InsOpt(2): INSR - Rate of offspring to be inserted per
%                           subpopulation (% of subpopulation)
%                InsOpt(3): not used
%                InsOpt(4): not used
%                InsOpt(5): local dimension (see comploc)
%                InsOpt(6): local structure (see comploc)
%                InsOpt(7): local distance  (see comploc)
%    ObjVCh    - (optional) Column vector containing the objective values
%                of the individuals (parents - Chrom) in the current population,
%                needed for fitness-based insertion
%                saves recalculation of objective values for population
%    ObjVSel   - (optional) Column vector containing the objective values
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
%    SelIx     - Matrix containing indices of selected parents in Chrom, output parameter
%                of selection/sellocal
%    SelFun    - Vector containing numbers indicating used selection algorithm
%
% Output parameters:
%    Chrom     - Matrix containing the individuals of the current
%                population after reinsertion.
%    ObjVCh    - if ObjVCh and ObjVSel are input parameter, than column vector containing
%                the objective values of the individuals of the current
%                generation after reinsertion.
%
% See also: reinsreg, reinsloc, sellocal, ranking

% Author:   Hartmut Pohlheim
% History:  12.02.97    file created


function [Chrom, ObjVCh] = reins(Chrom, SelCh, SUBPOPCh, SUBPOPSel, InsOpt, ObjVCh, ObjVSel, RankCh, RankSel, SelIx, SelFun);

% Set standard insertion parameter
   InsOptStandard = [2, 1, NaN, NaN, NaN, NaN, NaN];      % Select = 2; INSR = 1; Dummy1; Dummy2; 
                                                          % LocalDimension = NaN; LocalStructure = NaN; LocalDistance = NaN;

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
   if length(InsOpt) > length(InsOptStandard), error(' Too many parameter in InsOpt'); end

   InsOptIntern = InsOptStandard; InsOptIntern(1:length(InsOpt)) = InsOpt;
   Select = InsOptIntern(1); INSR = InsOptIntern(2);
   LocalDimension = InsOptIntern(5); LocalStructure = InsOptIntern(6); LocalDistance = InsOptIntern(7); 

   if isnan(Select), Select = InsOptStandard(1);
   elseif (~any(Select==[0:6])), error('Parameter for reinsertion method must be in [0:6]'); end
   
   IsObjVCh = 0; IsObjVSel = 0;
   if nargin > 5, 
      if ~isempty(ObjVCh),
         [testNind, testNvar] = size(ObjVCh);
         if testNind ~= NindCh, error('Chrom and ObjVCh disagree'); end
         IsObjVCh = 1;
      end
   end
   if nargin > 6, 
      if ~isempty(ObjVSel),
         [testNind, testNvar] = size(ObjVSel);
         if testNind ~= NindSel, error('SelCh and ObjVSel disagree'); end
         IsObjVSel = 1;
      end
   end

   if (nargout == 2 & (IsObjVCh == 0 | IsObjVSel == 0)),
      error('Input parameter ObjVCh and/or ObjVSel for output of ObjVCh missing!');
   end

   IsRankCh = 0; IsRankSel = 0;
   if nargin > 7, 
      if ~isempty(RankCh), 
         [testNind, testNvar] = size(RankCh);
         if testNvar ~= 1, error('RankCh must be a column vector'); end
         if testNind ~= NindCh, error('Chrom and RankCh disagree'); end
         IsRankCh = 1;
      end
   end
   if nargin > 8, 
      if ~isempty(RankSel), 
         [testNind, testNvar] = size(RankSel);
         if testNvar ~= 1, error('RankSel must be a column vector'); end
         if testNind ~= NindSel, error('SelCh and RankSel disagree'); end
         IsRankSel = 1;
      end
   end

   IsSelIx = 0;       
   if nargin > 9, 
      if isnan(SelIx), SelIx = []; end
      if isempty(SelIx), IsSelIx = 0;
      else
         [testNind, testNvar] = size(SelIx);
         if testNvar ~= 1, error('SelIx must be a column vector'); end
         if testNind ~= NindSel, error('SelCh and SelIx disagree'); end
         IsSelIx = 1;
      end
   end
          
   if nargin < 11, SelFun = []; end
   if isnan(SelFun), SelFun = []; end
   if isempty(SelFun), SelFun = 0; end
   if length(SelFun)== 1, SelFun = ones(1, length(SUBPOPCh)) .* SelFun; end

% If no rank values are provided; produce them assuming single objective problems
   % Check for ObjVCh
   if all([Select >= 1, IsObjVCh == 0, IsRankCh == 0]),
      error('For selection of parents ObjVCh/RankCh is needed');
   end
   if all([Select >= 1, IsRankCh == 0]), RankCh = -(ObjVCh(:,1)); IsRankCh = 1;  end
   % Check for ObjVSel
   if all([Select >= 2, IsObjVSel == 0, IsRankSel == 0]),
      error('For selection of offspring ObjVSel/RankSel is needed');
   end 
   if all([Select >= 2, IsRankSel == 0]), RankSel = -(ObjVSel(:,1)); IsRankSel = 1; end

% perform insertion for each subpopulation
   for irun = 1:length(SUBPOPCh),
      % Get number of individuals/offspring in actual subpopulation
      NindCh = SUBPOPCh(irun);
      NindSel = SUBPOPSel(irun);
         
      % Index to individuals of current subpopulation
      IxNindCh = sum(SUBPOPCh(1:irun-1))+1:sum(SUBPOPCh(1:irun));
      IxNindSel = sum(SUBPOPSel(1:irun-1))+1:sum(SUBPOPSel(1:irun));

      % copy according size of subpopulations
      ChromSub = Chrom(IxNindCh,:); SelChSub = SelCh(IxNindSel,:);
      if IsObjVCh == 1, ObjVChSub = ObjVCh(IxNindCh,:); else ObjVChSub = []; end
      if IsObjVSel == 1, ObjVSelSub = ObjVSel(IxNindSel,:); else ObjVSelSub = [];  end
      if IsRankCh == 1, RankChSub = RankCh(IxNindCh); else RankChSub = []; end
      if IsRankSel == 1, RankSelSub = RankSel(IxNindSel); else RankSelSub = []; end

      if any([SelFun(irun) ~= 2, NindCh <= 1, NindSel <= 3]),
         % Regional reinsertion for not local model (or if to less individuals in local model)
         ReinsOpt = [Select INSR];
         [ChromSub, ObjVChSub] = reinsreg(ChromSub, SelChSub, NindCh, NindSel, ReinsOpt, ObjVChSub, ObjVSelSub, RankChSub, RankSelSub);
      else
         if IsSelIx == 0, error('Input parameter missing: SelIx'); end
         SelIxSub = SelIx(IxNindSel,:) - sum(SUBPOPCh(1:irun-1));
         ReinsOpt = [Select INSR NaN NaN LocalDimension LocalStructure LocalDistance];
         [ChromSub, ObjVChSub] = reinsloc(ChromSub, SelChSub, NindCh, NindSel, ReinsOpt, ObjVChSub, ObjVSelSub, RankChSub, RankSelSub, SelIxSub);
      end

      % copy new Chrom and ObjVCh back
      Chrom(IxNindCh,:) = ChromSub;
      if IsObjVCh == 1, ObjVCh(IxNindCh,:) = ObjVChSub; end
   end


% End of function
