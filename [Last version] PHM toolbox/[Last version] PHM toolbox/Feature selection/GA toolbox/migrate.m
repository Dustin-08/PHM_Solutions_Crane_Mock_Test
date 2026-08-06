% MIGRATion of individuals between subpopulations
%
% This function performs migration of individuals.
% The structure of the subpopulations can be chosen between:
%  - complete net structure (unrestricted migration)
%  - neighbourhood structure
%  - ring structure
% The selection of the individuals for migration can be chosen between:
%  - uniform at random selection
%  - fitness-based selection
% The insertion of migrants is done uniform at random.
% For fitness-based migration (best individuals migrate) the fitness
% values/ranking of the population (Rank) is needed. If omitted or
% empty single objective scaling using the first column of the objective
% values (ObjV) is assumed.
% If the objective values of the population (ObjV) are input parameter
% and ObjV is output parameter the objective values are copied,
% according to the migration of individuals, saving the recomputation
% of the objective values for the whole population.
% The function can handle multiple objective values per individual. 
% Different size of every subpopulation is supported.
%
% Syntax:  [Chrom, ObjV] = migrate(Chrom, SUBPOP, MigOpt, ObjV, Rank)
%
% Input parameters:
%    Chrom     - Matrix containing the individuals of the current
%                population. Each row corresponds to one individual.
%    SUBPOP    - (optional) Vector/scalar containing number of individuals
%                per subpopulation/number of subpopulations
%                if omitted or NaN, 1 subpopulation is assumed
%    MigOpt    - (optional) Vector containing migration paremeters
%                MigOpt(1): MIGR - Rate of individuals to be migrated per
%                           subpopulation (% of subpopulation)
%                           if omitted or NaN, 0.2 (20%) is assumed
%                MigOpt(2): Select - number indicating the selection method
%                           of replacing individuals
%                           0 - uniform selection
%                           1 - fitness-based selection (best individuals migrate)
%                           if omitted or NaN, 0 is assumed
%                MigOpt(3): Structure - number indicating the structure
%                           of the subpopulations for migration
%                           0 - net structure (unconstrained migration)
%                           1 - neighbourhood structure
%                           2 - ring structure
%                           if omitted or NaN, 0 is assumed
%    ObjV      - (optional) Column vector or matrix containing the objective values
%                of the individuals in the current population,
%                if Rank is omitted, first column is used for fitness-based migration,
%                saves recalculation of objective values for population
%    Rank      - (optional) Column vector containing the fitness values (obtained
%                by ranking) of the individuals in the current population,
%                best individual has highest value,
%                if omitted or empty, single objective scaling using first column
%                of ObjV is assumed
%
% Output parameters:
%    Chrom     - Matrix containing the individuals of the current
%                population after migration.
%    ObjV      - if ObjV is input parameter, than column vector containing
%                the objective values of the individuals of the current
%                generation after migration.
%
% See also: geamain, mutate, recombin, selection

% Author:   Hartmut Pohlheim
% History:  16.02.95    file created
%           18.02.95    comments at the beginning added
%                       exchange of ObjV too
%           25.02.95    clean up
%           26.02.95    ObjV optional input parameter
%                       Select and Structure added, parameter reordered
%           17.03.95    renamed to migrate.m, more parameter checks
%           01.07.96    multiobjective support added, ObjV may be a matrix,
%                       parameter Rank added
%           02.07.96    long description added
%                       parameter checking changed, much smaller now and
%                          easier to understand and maintain
%           01.08.96    new format for SUBPOP introduced, vector contains now
%                          number of individuals for every subpopulation


function [Chrom, ObjV] = migrate(Chrom, SUBPOP, MigOpt, ObjV, Rank);

% Set standard mutation parameter
   MigOptStandard = [0.2, 0, 0];      % MIGR = 0.2; Select = 0; Structure = 0

% Check parameter consistency
   [Nind, Nvar] = size(Chrom);

   if nargin < 2, error('Input parameter SUBPOP missing'); end
   SUBPOP = compdiv('checksubpop', SUBPOP, Nind);
   NumSUBPOP = length(SUBPOP);
   if NumSUBPOP == 1, return; end
   
   IsObjV = 0;
   if nargin > 3, 
      if ~isempty(ObjV),
         [objNind, objNvar] = size(ObjV);
         if objNind ~= Nind, error('Chrom and ObjV disagree (number of rows)'); end
         IsObjV = 1;
      end
   end
   if all([nargout > 1, IsObjV == 0]),
      error('Input parameter ObjV missing or empty (for output of ObjV needed)');
   end

   IsRank = 0;
   if nargin > 4, 
      if ~isempty(Rank),
         [rankNind, rankNvar] = size(Rank);
         if rankNvar ~= 1, error('Rank must be a column vector'); end
         if Nind ~= rankNind, error('Chrom and Rank disagree (number of rows)'); end
         IsRank = 1;
      end
   end
   if all([IsObjV == 1, IsRank == 0]),  Rank = -ObjV(:,1); IsRank = 1; end 

   if nargin < 3, MigOpt = []; end
   if length(MigOpt) > length(MigOptStandard), error(' Too many parameter in MigOpt'); end

   MigOptIntern = MigOptStandard; MigOptIntern(1:length(MigOpt)) = MigOpt;
   MIGR = MigOptIntern(1); Select = MigOptIntern(2); Structure = MigOptIntern(3);

   if isnan(MIGR), MIGR = MigOptStandard(1);
   elseif (MIGR < 0 | MIGR > 1), error('Parameter for migration rate must be a scalar in [0 1]'); end
   
   if isnan(Select), Select = MigOptStandard(2);
   elseif (~any(Select==[0,1])), error('Parameter for selection method must be 0 or 1'); end

   if isnan(Structure), Structure = MigOptStandard(3);
   elseif (~any(Structure==[0,1,2])), error ('Parameter for structure must be 0, 1 or 2'); end

   if (Select == 1 & IsRank == 0), error('Rank (or ObjV) for fitness-based migration needed');end

   if MIGR == 0, return; end
   % Number of individuals per subpopulation to migrate
   MigTeil = max(floor(SUBPOP * MIGR), 1);

% Perform migration between subpopulations --> create a matrix for migration
% in every subpopulation from best individuals of the other subpopulations

   % Clear storing matrices
      ChromMigAll = [];
      if IsObjV == 1, ObjVAll = []; end

   % Create matrix with best/uniform individuals of all subpopulations
      for irun = 1:NumSUBPOP
         % Get number of individuals/offspring in actual subpopulation
            Nind = SUBPOP(irun);
         
         % Index to individuals of current subpopulation
            IxNind = sum(SUBPOP(1:irun-1))+1:sum(SUBPOP(1:irun));

         % sort Rank of actual subpopulation
            if Select == 1,              % fitness-based selection
               [Dummy, IndMigSo]=sort(-Rank(IxNind));
            else     % if Select == 0    % uniform selection
               [Dummy, IndMigSo]=sort(rand(Nind, 1));
            end
         % take MigTeil (best) individuals, copy individuals, objective values and rank
            IndMigTeil=IndMigSo(1:MigTeil(irun)) + sum(SUBPOP(1:irun-1));
            ChromMigAll = [ChromMigAll; Chrom(IndMigTeil,:)];
            if IsObjV == 1, ObjVAll = [ObjVAll; ObjV(IndMigTeil,:)]; end
      end

   % perform migration
      for irun = 1:NumSUBPOP
         % Get number of individuals/offspring in actual subpopulation
            Nind = SUBPOP(irun);
         
         % Get all migration individuals and their objective values
            ChromMig = ChromMigAll;
            if IsObjV == 1, ObjVMig = ObjVAll; end

         % neighbourhood structure
            if Structure == 1,
               % Select individuals of neighbourhood subpopulations
               % (current-1 and current+1) for ChromMig and ObjVMig
               popnum = [NumSUBPOP 1:NumSUBPOP 1];
               ins1 = popnum(irun); ins2 = popnum(irun + 2);
               InsRows = [sum(MigTeil(1:ins1-1))+1:sum(MigTeil(1:ins1))];
               InsRows = [InsRows sum(MigTeil(1:ins2-1))+1:sum(MigTeil(1:ins2))];
               ChromMig = ChromMig(InsRows,:);
               if IsObjV == 1, ObjVMig = ObjVMig(InsRows,:); end

         % ring structure
            elseif Structure == 2,
               % Select individuals of actual-1 subpopulation for ChromMig and ObjVMig
               popnum = [NumSUBPOP 1:NumSUBPOP 1];
               ins1 = popnum(irun);
               InsRows = [sum(MigTeil(1:ins1-1))+1:sum(MigTeil(1:ins1))];
               ChromMig = ChromMig(InsRows,:);
               if IsObjV == 1, ObjVMig = ObjVMig(InsRows,:); end

         % complete net, unrestricted migration
            else                     % if Structure == 0,  % complete net
               % delete individuals of actual subpopulation from ChromMig and ObjVMig
               DelRows = sum(MigTeil(1:irun-1))+1:sum(MigTeil(1:irun));
               ChromMig(DelRows,:) = [];
               if IsObjV == 1, ObjVMig(DelRows,:) = []; end
            end

         % Create an index from a sorted vector with random numbers of size of
         % all possible immigration individuals
            [Dummy, IndMigRa] = sort(rand(size(ChromMig,1),1));
         % Take MigTeil(irun) numbers from the random vector, thus selecting
         % the individuals for immigration
         % Number of immigrants is determined as minimum of possible immigrants
         % (from other subpopulations) and size of migrants of current subpopulation
            NumMigReal = min(size(ChromMig,1), MigTeil(irun));
            IndMigN = IndMigRa((1:NumMigReal)');

         % select individuals in original subpopulation to replace uniform at random
            [Dummy, IndMigSo]=sort(rand(Nind, 1));
            IndMigTeil = IndMigSo(1:NumMigReal) + sum(SUBPOP(1:irun-1));

         % copy immigrants into Chrom and ObjV
            Chrom(IndMigTeil,:) = ChromMig(IndMigN,:);
            if IsObjV == 1, ObjV(IndMigTeil,:) = ObjVMig(IndMigN,:); end
      end


% End of function
