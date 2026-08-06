% COMPETition between subpopulations
%
% This function performs competition between subpopulations.
% The division of the individuals to the subpopulations can be 
% controlled by one parameter - the division pressure. The 
% effect of this parameter is identical to selection pressure
% (even the same functions are used for calculation). Instead 
% of using individuals here we use subpopulations.
% The selection of the individuals for transfer to other 
% (better) subpopulations can be chosen between:
%  - uniform at random selection
%  - fitness-based selection
% For fitness-based competition (worst individuals are deleted)
% the fitness values/ranking of the population (FitnV) is needed.
% If omitted or empty single objective scaling using the first
% column of the objective values (ObjV) is assumed.
% If the objective values of the population (ObjV) are input
% parameter and ObjV is output parameter the objective values
% are copied, according to the flowing of individuals, saving
% the recomputation of the objective values for the whole popu-
% lation.
% The function can handle multiple objective values per individual. 
%
% Syntax:  [NewChrom, NewObjV, SUBPOP, CompQuality] = compete(Chrom, SUBPOP, CompQuality, CompOpt, ObjV, FitnV)
%
% Input parameters:
%    Chrom     - Matrix containing the individuals of the current
%                population. Each row corresponds to one individual.
%    SubPop    - Vector/scalar containing number of individuals per
%                subpopulation/number of subpopulations
%                if omitted or NaN, 1 subpopulation is assumed
%    CompQuality - Vector containing the competition quality of each
%                  subpopulation (output parameter of this function)
%                if omitted, NaN or empty, CompQuality is calculated
%                equivalent to the size of each subpopulation
%    CompOpt   - (optional) Vector containing competition paremeters
%                CompOpt(1): CompRate - Rate of individuals to be deleted/
%                            included per subpopulation (% of subpopulation)
%                            if omitted or NaN, 0.2 (20%) is assumed
%                CompOpt(2): Select - number indicating the selection method
%                            of deleting individuals
%                            0 - uniform selection
%                            1 - fitness-based selection (worst individuals are deleted)
%                            if omitted or NaN, 1 is assumed
%                CompOpt(3): CompMin - number indicating the minimal number of
%                            individuals in a subpopulation
%                            if omitted or NaN, 5 is assumed
%                CompOpt(4): DivisionPressure (analog to selective pressure)
%                            can be given in the range: 1 - (NumSubPop-2)
%                            1: no division pressure (not really useful)
%                            2: the best subpop receives twice as many individuals 
%                               as the mean of all subpops
%                            max value (for instance 4, when using 6 subpops): the
%                                best subpop gets 4 times as many individuals ...
%                                (this means nearly 50% of the individuals)
%                            (maximal 2 for linear division)
%                            if omitted or NaN, 2 is assumed
%                CompOpt(5): for test purpose only
%                            NaN: automatically selected 
%                                (DivisionPressure <=2: linear division, 
%                                 else non-linear) 
%                            1: lin. division function
%                            2: nonlin. division function
%    ObjV      - Column vector or matrix containing the objective values
%                of the individuals in the current population,
%                if Rank is omitted, first column is used for
%                fitness-based competition, saves recalculation
%                of objective values for population
%    FitnV     - (optional) Column vector containing the fitness
%                values of the individuals
%                in the current population, best individual has
%                highest value,
%                if omitted or empty, single objective scaling
%                using first column of ObjV is assumed
%
% Output parameters:
%    NewChrom  - Matrix containing the individuals of the current
%                population after competition.
%    NewObjV   - (optional) Column vector containing the objective
%                values of the individuals of the current generation
%                after competition.
%    SubPop    - (optional) Vector/scalar containing number of indi-
%                viduals per subpopulation/number of subpopulations
%                after competition
%
% See also: geamain2, migrate, compdiv

% Author:   Hartmut Pohlheim, Arne Griep
% History:  05.08.1996  file created
%           09.10.1996  documentation updated
%                       algorithm of deletion and insertion of indivi-
%                          duals changed, best subpopulation can take
%                          over much quicker and better now
%           07.03.1997  use of filtered order of subpopulations added
%                          thus, filtering inside here can be deleted% Calculation of verteilung of ressources
%           06.05.2001  ressource distribution by division function added (Arne Griep)
%           17.02.2002  documentation reviewed, some error messages changed to warning


function [NewChrom, NewObjV, SubPop, CompQuality, TestVars] = compete(Chrom, SubPop, CompQuality, CompOpt, ObjV, FitnV);

% Parameter for selection methods: worst, best, random
% and parameters for turning on some visualisation (intended for internal tests)
   selectmeth='worst';
   DrawDivision = 0; DrawDistribution = 0; truncationdivision = 0;

% Set standard competition parameter
  % CompRate = 0.2; Select = 1; CompMin = 5; DivisionPressure = 2
  CompOptStandard = [0.2, 1, 5, 2, NaN];

% Check parameter consistency
   [Nind, Nvar] = size(Chrom);

   if nargin < 2, 
      SubPop = Nind; warning('Input parameter SubPop missing. No competition possible');
   end
   SubPop = compdiv('checksubpop', SubPop, Nind);
   NumSubPop = length(SubPop);
   if NumSubPop == 1, NewChrom = Chrom; NewObjV = ObjV; CompQuality = []; return; end
   SUBPOPComp = zeros(size(SubPop));

   if nargin < 3, CompQuality = []; end 
   if isnan(CompQuality), CompQuality = []; end 
   if isempty(CompQuality), CompQuality = 0.5 * SubPop/max(SubPop); end 
   CompQuality = CompQuality(:);
   if (size(CompQuality, 1) ~= size(SubPop, 1)),
      error('Size of CompQuality and SubPop disagree (number of rows)!');
   end

   IsObjV = 0;
   if nargin > 4, 
      if ~isempty(ObjV),
         [objNind, objNvar] = size(ObjV);
         if objNind ~= Nind, error('Chrom and ObjV disagree (number of rows)!'); end
         IsObjV = 1;
      end
   end
   if all([nargout > 1, IsObjV == 0]),
      error('Input parameter ObjV missing or empty (for output of ObjV needed)!');
   end
   
   IsFitnV = 0;
   if nargin > 5, 
      if ~isempty(FitnV),
         [rankNind, rankNvar] = size(FitnV);
         if rankNvar ~= 1,
            FitnV = FitnV'; [rankNind, rankNvar] = size(FitnV);
            warning('FitnV must be a column vector');
         end
         if Nind ~= rankNind, error('Chrom and FitnV disagree (number of rows)'); end
         IsFitnV = 1;
      end
   end
   if all([IsObjV == 1, IsFitnV == 0]),  FitnV = -ObjV(:,1); IsFitnV = 1; end 
   if IsFitnV == 0, error('ObjV or FitnV are needed as input parameters (for competition)!'); end
   
   if nargin < 4, CompOpt = []; end
   if length(CompOpt) > length(CompOptStandard),
      warning('Too many parameter in CompOpt! Ignoring additional parameters.');
      CompOpt = CompOpt(1:length(CompOptStandard));
   end
   
   CompOptIntern = CompOptStandard; CompOptIntern(1:length(CompOpt)) = CompOpt;
   CompRate = CompOptIntern(1); Select = CompOptIntern(2); CompMin = CompOptIntern(3);
   DivPress = CompOptIntern(4);
   
   if isnan(CompRate), CompRate = CompOptStandard(1);
   elseif (CompRate < 0 | CompRate > 1), 
      warning('Parameter for competition rate must be a scalar in [0 1]');
      CompRate = max(min(CompRate, 1), 0);
   end
   
   if ~(any(Select == [0,1])),
      if ~(isnan(Select)), warning('Parameter for selection method must be 0 or 1'); end
      Select = CompOptStandard(2);
   end
   
   if ~(CompMin > 0),
      if ~(isnan(CompMin)), warning('Parameter for competition minimum must be greater than 0!'); end
      CompMin = CompOptStandard(3);
   end
   
   if (Select == 1 & IsFitnV == 0), error('FitnV (or ObjV) for fitness-based distribution needed (in competition).'); end
   
   if CompRate == 0,  NewChrom = Chrom; NewObjV = ObjV; return; end

% Perform competition between subpopulations --> delete individuals from "bad" 
% subpopulation and add individuals to "good" subpopulations

% Compute order of subpopulations
% PosSubPopComp = compdiv('possubpop', -Rank, SubPop);
% factor OldQuality determines speed of change of quality
% smaller values mean quicker change of quality (less filtering)
% 0.75 is good for medium speed; 0.9 means slower change of quality
% OldQuality = 0.75; NewQuality = 1- OldQuality;
% CompQuality = CompQuality * OldQuality;
% CompQuality = CompQuality + (1 - (PosSubPopComp-1)/length(SubPop)) * NewQuality;
% SIEHE S.98 SPRINGER

if 0, % bisherige Ressourcenverteilung
    % Convert order (lowest value is best) to Quality (lowest ist worst) and sort
    [Dummy, PosSubPopSorted] = sort(1./ CompQuality);   % include later direct ranking
    % percent of subpopulations to delete individuals from
    NumSubPopDelete = (NumSubPop - 1) / NumSubPop;           % 0.75;
    PosSubPopDelete = PosSubPopSorted(1:floor(length(PosSubPopSorted) * NumSubPopDelete));
    PosSubPopAdd = PosSubPopSorted(length(PosSubPopDelete)+1:length(PosSubPopSorted));
    
    % Number of individuals per subpopulation to delete, proportional to size of
    % subpopulation and bounded by minimal number of individuals per subpopulation
    CompTeil = min(max(1, floor(SubPop' * CompRate)), max(0, SubPop' - CompMin));
    
    % Delete worse/uniform individuals from bad subpopulations
    SUBPOPSave = [];
    IxNindAll = []; IxSaveAll = [];
    for irun = PosSubPopDelete',
       % Get number of individuals/offspring in actual subpopulation
       Nind = SubPop(irun);
       
       % Index to individuals of current subpopulation
       IxNind = sum(SubPop(1:irun-1))+1:sum(SubPop(1:irun));
       
       if CompTeil(irun) > 0,
          % sort FitnV of actual subpopulation
          if Select == 1,  % fitness-based selection, select worse
             [Dummy, IndCompSort]=sort(FitnV(IxNind));
          else     % if Select == 0    % uniform selection
             [Dummy, IndCompSort]=sort(-rand(Nind, 1));
          end
          % take CompTeil (worse) individuals
          IndCompDel=IndCompSort(1:CompTeil(irun));
          
          % save index of individuals to delete
          IxSaveAll = [IxSaveAll, IxNind(IndCompDel)];
          
          % delete CompTeil (worse) individuals from index
          IxNind(IndCompDel) = [];
       end
       
       % copy index of individuals
       SUBPOPSave = [SUBPOPSave; length(IxNind)];
       IxNindAll = [IxNindAll, IxNind];
    end
    
    % Add to good subpopulations
    NindAdd = repmat(floor(length(IxSaveAll) / length(PosSubPopAdd)),[length(PosSubPopAdd), 1]);
    NindAdd(length(PosSubPopAdd)) = length(IxSaveAll) - sum(NindAdd(1:length(PosSubPopAdd)-1));
    
    for irun = 1:length(PosSubPopAdd),
       % Get number of individuals/offspring in actual subpopulation
       Nind = SubPop(PosSubPopAdd(irun));
       
       % Index to individuals of current subpopulation
       IxNind = sum(SubPop(1:PosSubPopAdd(irun)-1))+1:sum(SubPop(1:PosSubPopAdd(irun)));
       
       % get index of individuals to add
       IxAdd = sum(NindAdd(1:irun-1))+1:sum(NindAdd(1:irun));
       
       % copy individuals and objective values of subpopulation
       SUBPOPSave = [SUBPOPSave; length(IxNind) + length(IxAdd)];
       IxNindAll = [IxNindAll, IxNind, IxSaveAll(IxAdd)];
    end
    
    
    % Rebuild population from index
    NewChrom = zeros(size(Chrom)); NewObjV = zeros(size(ObjV));
    [Dummy, IxSortedBack] = sort(PosSubPopSorted);
    SubPop = SUBPOPSave(IxSortedBack);
    for irun = 1:NumSubPop,
       % Index to new positions of individuals in new population
       IxNind = sum(SubPop(1:PosSubPopSorted(irun)-1))+1:sum(SubPop(1:PosSubPopSorted(irun)));
       
       % Index to individuals to copy to IxNind positions
       IxNindSave = sum(SUBPOPSave(1:irun-1))+1:sum(SUBPOPSave(1:irun));
       
       % Copy individuals and objective values according IxNind and IxNindSave
       NewChrom(IxNind,:) = Chrom(IxNindAll(IxNindSave),:);
       if IsObjV == 1, NewObjV(IxNind,:) = ObjV(IxNindAll(IxNindSave),:); end
    end
    SubPop = SubPop';
    % Ende der bisherigen Implementation
    
    
    
else
    ObjVSorted = zeros(size(ObjV)); 
    % ranking of subpopulations, subpopulation(n) corresponds to RankSubPop(n)
    RankSubPop = (sum(repmat(CompQuality, [1, NumSubPop])' > repmat(CompQuality, [1, NumSubPop])) + 1);
    % ressource ratio
    if ~isnan(CompOptIntern(5)),
       ratio = ranking(RankSubPop, [DivPress, CompOpt(5),0],[],[]) / length(RankSubPop); % for test purpose
    else
       ratio = ranking(RankSubPop', DivPress) / length(RankSubPop);
    end;
    if truncationdivision == 1, 
       ratio(RankSubPop < 2) = 1;
       ratio(RankSubPop > 1) = 0;
    end
    % total number of individuals
    NindAll = size(ObjV,1); 
    NewSubPop = []; 
  
   % find out which subpops have to release individuals according division function
   % number of individuals to rearrange per subpop  
   NindToDistribute = fix(SubPop - NindAll * ratio);
   % populations which have to release individuals
   ReleaseInd = find(NindToDistribute > 0);
    
   % find out how many individuals have to be released
   % by keeping of: CompMin, max. number of ind. to release defined by CompRate and max. number defined by division function
   % at least one individual will be released by keeping CompMin
   % number of individuals which can be distributed according comprate   
   NindToDist_CompRate = floor(CompRate * (SubPop(ReleaseInd)));       
   % number of individuals which should be distributed according division function
   NindToDist_DivF = floor(SubPop(ReleaseInd) - ratio(ReleaseInd) * NindAll); 
   % number of individuals which can be distributed by keeping minimal number of individuals per subpop
   NindToDist_Max = SubPop(ReleaseInd) - CompMin;
   % keeping of maximal number of individuals to release defined by comprate and max. number defined by division function
   % at least one individual will be released
   NindToDistribute(ReleaseInd) = max(min(NindToDist_CompRate, NindToDist_DivF), 1);
   % keeping of CompMin
   NindToDistribute(ReleaseInd) = min(NindToDist_Max, NindToDistribute(ReleaseInd));
   
   % find out how many individuals have to be added  
   % populations which assimilate individuals
   AssimilateInd = find(NindToDistribute < 0);
   % get individuals proportional to the number of individuals to be released, according division function
   NindToDistribute(AssimilateInd) = -ceil(NindToDistribute(AssimilateInd) ... 
                                     / sum(NindToDistribute(AssimilateInd)) ... 
                                     * sum(NindToDistribute(ReleaseInd)));
   % calculate size of new subpops
   NewSubPop = SubPop - NindToDistribute;
   % remain of rounding difference
   DiffNindAll = NindAll - sum(NewSubPop);
   % detect best subpop
   [dummy, ixbestsubpop] = min(RankSubPop);
   % transfer remain to best subpop
   NindToDistribute(ixbestsubpop) = NindToDistribute(ixbestsubpop) - DiffNindAll;
   % final values
   NewSubPop = SubPop - NindToDistribute;
   
   % sort individuals within their subpops and select individuals for distribution
   IxToDistribute = [];
   IxToDistributeAll = [];
   for irun = 1:NumSubPop,
      % indices of individuals of current subpop
      StartIx = sum(SubPop(1:irun - 1)) + 1; NindIx = StartIx:sum(SubPop(1:irun));

      % sort individuals within their subpop, relative indices
      switch selectmeth
         case 'worst', [dummy, IxSortedRel] = sort(-FitnV(NindIx)); 
         case 'best', [dummy, IxSortedRel] = sort(FitnV(NindIx));
         case 'random', [dummy, IxSortedRel] = sort(rand(SubPop(irun),1));
      end
      % compute absolute indices
      IxSortedAbs(NindIx) = IxSortedRel + StartIx - 1;

      % indices of individuals to distribute per subpop
      IxToDistribute{irun}=[IxSortedAbs(StartIx:StartIx + NindToDistribute(irun) - 1)]; 
      if NindToDistribute(irun) > 0,
         % indices of individuals to distribute, overall
         IxToDistributeAll = [IxToDistributeAll; IxToDistribute{irun}'];
      end
   end
       
   % reconstruction of the whole population
   NewObjV = zeros(size(ObjV));
   NewChrom = zeros(size(Chrom));
   BackupIxToDistribute=IxToDistribute;
   TestVars=[IxToDistribute {NindToDistribute} {IxToDistributeAll}]; % for test purpose
   IxNewSUBPOP=[];

   % how much individuals have to be added per subpop
   AssimilateInd = find(NindToDistribute < 0);
   NindToAdd = zeros(size(NindToDistribute));
   NindToAdd(AssimilateInd) = -NindToDistribute(AssimilateInd);
   
   % save testvars\nodistribution\IxToDistributeAll.txt IxToDistributeAll -ascii; % for test purpose
   
   % create random order of distribution pool
   [dummy, IxToAdd]=sort(rand(length(IxToDistributeAll),1));
   
   for irun = 1:NumSubPop,
      % indices of individuals of current subpop, old and new
      StartIx = sum(SubPop(1:irun - 1)) + 1; NindIx = StartIx:sum(SubPop(1:irun));
      NewStartIx = sum(NewSubPop(1:irun - 1)) + 1; NewNindIx = NewStartIx:sum(NewSubPop(1:irun));
      if NindToDistribute(irun) > 0, % if individuals have to be released
         BackupNindIx = NindIx;
         % remove individuals to delete from sub index
         BackupNindIx(IxToDistribute{irun}-StartIx+1) = [];
         % new order of individuals
         IxNewSUBPOP=[IxNewSUBPOP; BackupNindIx'];
      else % if individuals will be assimilated
         BackupNewNindIx=NewNindIx;
         % shorten length of BackupNewNindIx to length of NindIx
         BackupNewNindIx(SubPop(irun)+1:NewSubPop(irun)) = [];
         % new order of individuals
         IxNewSUBPOP=[IxNewSUBPOP; NindIx'];
         IxNewSUBPOP=[IxNewSUBPOP; IxToDistributeAll(IxToAdd(sum(NindToAdd(1:irun-1))+1:sum(NindToAdd(1:irun))))];
      end   
   end

   % copy old individuals to new population
   NewChrom=Chrom(IxNewSUBPOP,:);
   NewObjV=ObjV(IxNewSUBPOP,:);
   
   % draw figure of required division and actual division
   % comptime
   % comptime if DrawDivision ~=0 | DrawDistribution ~=0,
   % comptime    FigureName = ('Division and Distribute per Generation');
   % comptime    
   % comptime    NumRowSubplots = 1;
   % comptime    NumColSubplots = DrawDistribution + DrawDivision;
   % comptime    
   % comptime    % look for figure, set name, paperposition, position and all standard settings
   % comptime    FigureTag = 'geatbx_fig_complot';
   % comptime    
   % comptime    VisuOptBase = visuoptset;
   % comptime    VisuOptBase = visuoptset( VisuOptBase ...
   % comptime                          , 'Plot.FigureName', FigureName, 'Plot.FigureTag', FigureTag ...
   % comptime                          , 'Plot.SubplotGrid', [NumRowSubplots NumColSubplots] ...
   % comptime                          , 'Preproc.CompressMode', [] ...
   % comptime                          , 'Plot.WindowWidth', 0.4 ...
   % comptime                          );
   % comptime    if DrawDivision == 1,
   % comptime       % draw subplot of required division
   % comptime       VisuOpt = visuoptset( VisuOptBase ...
   % comptime                              , 'Plot.Type', '2dstairs', 'Plot.GridMode', 'y' ...
   % comptime                              , 'Plot.LegendMode', 1, 'Plot.SubplotNum', NumRowSubplots ...
   % comptime                              , 'Plot.Title', 'Division', 'Plot.YCaption', 'rank subpop', 'Plot.XCaption', 'share of ressources' ...
   % comptime                              );
   % comptime       currentratio = NewSubPop / sum(NewSubPop);
   % comptime       currentratio = -sort(-currentratio);
   % comptime       % draw subplot of current division
   % comptime       %comptime% 
   % comptime       %comptime% visubase({[-sort(-ratio); min(ratio)], [0:NumSubPop] + 0.5; [currentratio; min(currentratio)], [0:NumSubPop] + 0.5}, ... 
   % comptime       %comptime%          {'required division'; 'current division'}, VisuOpt);
   % comptime    end
   % comptime    
   % comptime    % draw figure of distribution
   % comptime    if DrawDistribution == 1,
   % comptime       VisuOpt = visuoptset( VisuOptBase ...
   % comptime                              , 'Plot.Type', 'cq', 'Plot.ColorBarMode', '', 'Plot.GridMode', '' ...
   % comptime                              , 'Plot.LegendMode', 0, 'Plot.SubplotNum', NumColSubplots ...
   % comptime                              , 'Plot.Title', 'Distribution' ...
   % comptime                              , 'Plot.YCaption', 'index of individuals', 'Plot.XCaption', 'old subp. | distr. subpop | new subp.' ...
   % comptime                              );
   % comptime       ColVal = NaN * zeros(NindAll, 3); % last column is not used by pcolor
   % comptime       for irun = 1:length(SubPop),
   % comptime           % indices of individuals of current subpop
   % comptime           StartIx = sum(SubPop(1:irun - 1)) + 1; NindIx = StartIx:sum(SubPop(1:irun));
   % comptime           NewStartIx = sum(NewSubPop(1:irun - 1)) + 1; NewNindIx = NewStartIx:sum(NewSubPop(1:irun));
   % comptime           % set color values of 1st and 3rd column to number of current subpop
   % comptime           % 1st column stands for the original subpop, 3rd column stands for the new subpop
   % comptime           ColVal(NindIx, 1) = irun;
   % comptime           ColVal(NewNindIx, 3) = irun;
   % comptime       end
   % comptime       % 2nd column is set to newsubpop but with colors of the 1st
   % comptime       ColVal(:,2) = ColVal(IxNewSUBPOP,1);
   % comptime       ColVal1 = [num2cell(ColVal,2), num2cell(NaN*ones(size(ColVal)),2)];
   % comptime       %comptime% 
   % comptime       %comptime% visubase(ColVal1, {''}, VisuOpt);
   % comptime    end
   % comptime end

   SubPop = NewSubPop';

end


% end of function
