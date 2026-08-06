% COMPute DIVerse things of GEA Toolbox
%
% This function computes diverse special results for the GEA Toolbox
% during computation used at different points of the toolbox.
%
% Syntax:  [OP1, OP2, OP3, OP4, OP5] = compdiv(WhatTask, P1, P2, P3, P4, P5, P6, P7, P8, P9, P10)
%
% Input parameters:
%    WhatTask      - String containing the name of the needed computation
%    P1 - P10  - Parameters needed for the specific computations
%
% Output parameter:
%    OP1 - OP5 - Output parameters, specific for every computation
%
% Possible functions:
%    WhatTask == 'fitness_distance_correlation' or 'fdc'
%       Compute fitness distance correlation
%       P1     - Vector containing Fitnesses (objective values for single
%                objective functions), corresponds with ChromAll (P2)
%       P2     - Matrix containing ChromAll, alle individuals for
%                distance computation, every row in ChromAll corresponds
%                the same value in Fitnesses(P1)
%       P3     - Vector containing best individual or global solution
%       OP1    - Scalar containing fitness distance correlation coefficient
%       OP2    - Vector containing Fitnesses (same as P1)
%       OP3    - Vector containing Distances computed from P2 and P3
%
%    WhatTask == 'distance_chrom'
%       Compute distance between individuals (used in resplot)
%       P1     - Matrix containing individuals, the distance between all 
%                individuals is computed
%       OP1    - Vector containing all distances, similar to upper half
%                of distance matrix
%
%    WhatTask == 'distance_chrom_mat'
%       Compute distance between individuals (used in resplot)
%       P1     - Matrix containing individuals, the distance between all 
%                individuals is computed
%       OP1    - Matrix containing all distances
%
%    WhatTask == 'possubpop'
%       Sort/order subpopulations according objective values, return
%          position of every subpopulation
%       P1     - Matrix/vector containing (objective) values
%       P2     - Vector containing number of individuals per subpopulation
%       P3     - Vector containing previous filtered order of subpopulations
%       OP1    - (row) Vector containing position of every subpopulation
%                   subpopulation with best/minimal objective values gets 1,
%                   worst subpopulation gets length(SUBPOP)
%       OP2    - (row) Vector containing index to best values in every subpopulation,
%                   thus, P1(OP2) = values of best individuals of
%                   every subpopulation
%       OP3    - (row) Vector containing filtered order of subpopulations
%
%    WhatTask == 'checksubpop'
%       Check variable SUBPOP against number of objective
%          values/individuals and set correct values
%       P1     - Vector/scalar containing number of individuals per subpopulation
%       P2     - Scalar containing number of (objective) values
%       OP1    - Vector containing checked number of individuals per subpopulation
%
%
%    WhatTask == 'cutfillstring'
%       Check length of CFString against NewLength, if longer - cut string, 
%          if shorter, fill with white space
%       P1     - String CFString 
%       P2     - Scalar NewLength containing number of new length of string
%       OP1    - String containing cutted or filled string
%
%    WhatTask == 'phi_convergence'
%       Calculate the Kappa vconvergence measure
%       P1     - Matrix with individuals of population (Chrom)
%       P2     - Matrix with boundaries of variables (VLUB)
%       OP1    - Scalar with Phi value
%
%    WhatTask == 'kappa_convergence'
%       Calculate the Kappa vconvergence measure
%       P1     - Matrix with individuals of population (Chrom)
%       P2     - Matrix with boundaries of variables (VLUB)
%       OP1    - Scalar with Kappa value
%
% See also: geamain2, resplot, terminat

%  Author:  Hartmut Pohlheim
%  History: 20.06.1995  file created
%           30.06.1996  method 'sort_nan' added
%           xx.07.1996  method 'possubpop' added
%           xx.07.1996  method 'checksubpop' added
%           09.10.1996  2nd method for 'possubpop' added, ordering using
%                          sum of rank of individuals
%           24.10.1996  method 'sort_nan' removed
%           20.11.1996  correct calculation of distance in 'distance_chrom'
%           07.03.1997  calculation of filtered order of subpopulations
%                          added to 'possubpop'
%           09.06.1997  calculation of distance_chrom_mat slightly changed
%                          (loop from 1:Nind)
%           02.03.1998  method 'cutfillstring' added
%           xx.07.1998  included phi and kappa implementations
%           02.09.1998  reworked the phi and kappa implementations
%           17.02.2002  many of the still undocumented methods moved into 
%                          separate functions, many parts cleaned
%           06.05.2002  moved 'getdata_objfun' into separate function (geaobjpara)



function [OP1, OP2, OP3, OP4, OP5] = compdiv(WhatTask, P1, P2, P3, P4, P5, P6, P7, P8, P9, P10);

% Check input parameters
   if nargin < 1, WhatTask = []; end 
   if isempty(WhatTask), error('Parameter WHAT undefined! Do you know what you want?'); end


% Compute fitness distance correlation
   if (strcmp(lower(WhatTask), 'fitness_distance_correlation') | strcmp(lower(WhatTask), 'fdc')),
      if nargin < 3, error('Two input parameters for fitness distance calculation necessary !'); end
      Fitnesses = P1; ChromAll = P2;
      if nargin < 4, [BestFitness BestPos]= min(Fitnesses); Best = ChromAll(BestPos,:);
      else Best = P3; end
      Distances = ChromAll - repmat(Best, [size(ChromAll, 1), 1]);
      Distances = sqrt(sum((Distances.^2)')');
      fdccoeff = cov(Fitnesses, Distances) / (std(Fitnesses) * std(Distances));
      OP1 = fdccoeff(1,2); OP2 = Fitnesses; OP3 = Distances;   


% Compute distance between individuals (used in resplot)
   elseif strcmp(lower(WhatTask), 'distance_chrom'),
      if nargin < 2, P1 = []; end
      if isempty(P1), error('Parameter P1 is needed for distance computation!'); end
      Chrom = P1;
      Dist = []; Nind = size(Chrom, 1);
      for i = 1:Nind-1,
         % create vector with distances, every distance only once, quick
         Diff1 = repmat(Chrom(i,:), [Nind-i 1]);
         Diff2 = Chrom(i+1:Nind,:);
         Dist = [Dist, sqrt(sum(((Diff1 - Diff2)').^2))];
      end
      OP1 = Dist;   

   elseif any([strcmp(lower(WhatTask), 'distance_chrom_mat'), strcmp(lower(WhatTask), 'distance_chrom_mat_2')]),
      if nargin < 2, P1 = []; end
      if isempty(P1), error('Parameter P1 is needed for distance computation!'); end
      Chrom = P1;
      Dist = []; Nind = size(Chrom, 1);
      for i = 1:Nind,
         % create full matrix with distances, every distance twice,
         % 2-3 times more computing time than upper version and uses more memory
         Diff2 = Chrom;
         if strcmp(lower(WhatTask), 'distance_chrom_mat'),
            Diff1 = repmat(Chrom(i,:), [Nind-1 1]);
            Diff2(i,:) = [];
         else   % if strcmp(lower(WhatTask), 'distance_chrom_mat_2'),
            Diff1 = repmat(Chrom(i,:), [Nind 1]);
         end
         Dist(i,:) = sqrt(sum(((Diff1 - Diff2).^2)'));
      end
      OP1 = Dist;   


% Compute ordering of subpopulations
   elseif strcmp(lower(WhatTask), 'possubpop'),
      ObjV = P1; SUBPOP = P2; NumSUBPOP = length(SUBPOP);
      if nargin < 4, PosSubPopFilt = []; else PosSubPopFilt = P3; end

      % Parameter checking
      if size(ObjV,1) ~= sum(SUBPOP), error('Size of ObjV (P1) and values of SUBPOP (P2) disagree!'); end

      % Set internal variables
      ValforMinimum = zeros(1, NumSUBPOP); ixbest = zeros(1, NumSUBPOP);

      % Compute best (minimal) value / weighted sum of ranks per subpopulation/subvector
         % 0: weighted ranking using all values; 1: ranking with best value only
         RankwithOne = 0;
         if RankwithOne == 1,
            % sort values of one subpopulation, look for minimal value in subpopulation,
            % smaller value for minimum in subpopulation is better and determines rank
            % of subpopulation,
            % here only the best/minimal value is used for subpopulation ranking
            for irun = 1:NumSUBPOP,
               % Extract values
               Startix = sum(SUBPOP(1:irun-1))+1;
               SubObjV = ObjV(Startix:sum(SUBPOP(1:irun)),:);
               if size(ObjV, 2) > 1,      % here could be a multiobjective ranking included
                  SubObjV = SubObjV(:,1); % at the moment use first column for single objective ranking
               end
               [ValforMinimum(irun), ixbest(irun)] = min(SubObjV);
               ixbest(irun) = ixbest(irun) + Startix - 1;
            end
        else
            % sort by ranking all individuals at once, compute sum of (negative) rank
            % values in subpopulation and weight with number of individuals in
            % subpopulation, smaller value for weighted sum is better and determines
            % rank of subpopulation,
            % here all values are used for weighted ranking of subpopulations
            RankValues = -(ranking(ObjV));
            RankValSubpop = zeros(1, NumSUBPOP);
            for irun = 1: NumSUBPOP,
                StartIx = sum(SUBPOP(1:irun-1))+1; NindIx = StartIx:sum(SUBPOP(1:irun));
                [MinRank(irun), ixbest(irun)] = min(RankValues(NindIx));
                ixbest(irun) = ixbest(irun) + StartIx - 1;
                ValforMinimum(irun) = sum(RankValues(NindIx)) / length(NindIx);
            end
        end
        
      % Compute ranking of subpopulations, index of best individual per subpopulation and
      % filtered order of subpopulations
      PosSubPopAct = (sum(repmat(ValforMinimum, [NumSUBPOP, 1])' < repmat(ValforMinimum, [NumSUBPOP, 1])) + 1);
      if isempty(PosSubPopFilt), PosSubPopFilt = length(PosSubPopAct) / 2 + 0.1 * PosSubPopAct;
      else PosSubPopFilt = 0.9 * PosSubPopFilt + 0.1 * PosSubPopAct; end

      % Assign variables to output variables
      OP1 = PosSubPopAct;
      OP2 = ixbest;
      OP3 = PosSubPopFilt;
      

% Check variable SUBPOP against number of objective values/individuals and set correct values
   elseif strcmp(lower(WhatTask), 'checksubpop'),
      SUBPOP = P1; NumObjV = P2;
      if isnan(SUBPOP), SUBPOP = []; end
      if isempty(SUBPOP), SUBPOP = NumObjV; end
      if min(size(SUBPOP)) ~= 1, error('SUBPOP must be a vector or scalar'); end
      if sum(SUBPOP) ~= NumObjV,
         if all([length(SUBPOP) == 1, NumObjV ~= SUBPOP, (NumObjV/SUBPOP(1)) == fix(NumObjV/SUBPOP(1))]),
            SUBPOP = repmat(NumObjV/SUBPOP, [SUBPOP, 1]);
         else error('Parameters SUBPOP (P1) and NumObjV (P2) disagree! (sum(SUBPOP) should be NumObjV)'); end
      end
      OP1 = SUBPOP(:);


% Check length of CFString against NewLength,
% if longer - cut string, if shorter, fill with white space
   elseif strcmp(lower(WhatTask), 'cutfillstring'),
      CFString = P1; NewLength = P2;
      CFLength = length(CFString);
      if nargin < 2, NewLength = CFLength; end
      
      CFString2 =  CFString(1:min([NewLength-1, CFLength]));
      CFStringNew = [CFString2, repmat(' ', [1, max(1, NewLength-CFLength)])];
      
      OP1 = CFStringNew;      

% Calculate the Phi convergence measure
   elseif strcmp(lower(WhatTask), 'phi_convergence'),
      BestObjV = P1; WorstObjV = P2; ObjV = P3;
      % get the population size (Nind) and the number of objectives (ObjLength)
      [Nind, ObjLength] = size(ObjV);
      % Calculate diff to best objective value for all objective values
      Diff2Best = ObjV - repmat(BestObjV, [Nind,1]);
      % Now compute the average diff for all
      DiffAvg = sum(abs(Diff2Best)) / Nind;
      % Weight the average by the area between best and worst objective value(s)
      if (WorstObjV - BestObjV) == 0, DiffAvgWeight = ObjLength;
      else DiffAvgWeight = DiffAvg ./ (WorstObjV - BestObjV); end
      % Sum it up and if multiple objectives are used, ...
      Phi = 1 - sum(DiffAvgWeight) / ObjLength;
      
      OP1 = Phi;


% Calculate the Kappa convergence measure
   elseif strcmp(lower(WhatTask), 'kappa_convergence'),
      Chrom = P1; VLUB = P2;
      % get population size(Nind) and variable number (VarLength)
      [Nind, VarLength] = size(Chrom);
      % Check for wrong sizes
      if VarLength ~= size(VLUB, 2), 
         warning('The number of variables in Chrom and VLUB disagree !');
         OP1 = 0; return;
      end
      % Check for special case
      if Nind == 1, OP1 = 0; return; end
      % calculate kappa_max
      kappa_max = (Nind^2 - Nind) / 2;
      % calculate kappa
      BoundsSqrd = repmat(((VLUB(2,:) - VLUB(1,:)) .^ 2), [Nind-1, 1]);
      DistSum = 0.0;
      for i = 1:Nind-1,
         Dist = (Chrom((i+1):Nind,:) - repmat(Chrom(i,:), [Nind - i, 1])) .^ 2;
         DistSum = DistSum + sum(sum((Dist ./ BoundsSqrd(1:Nind-i,:))'));
      end
      Kappa = 1 - 1 / sqrt(VarLength) * DistSum / kappa_max;
      
      OP1 = Kappa;
      
% Check for diff of numbers in array and return all or first
   elseif strcmp(lower(WhatTask), 'diff_num'),
      TestVar = P1;
      
      if any(diff(TestVar)), OP1 = TestVar;
      else                   OP1 = TestVar(1);  end


% Check for diff of strings in char array and return all or first
   elseif strcmp(lower(WhatTask), 'diff_str'),
      TestStr = P1;
      
      if iscellstr(TestStr), IntTestStr = char(TestStr); else IntTestStr = TestStr; end
      if length(strmatch(IntTestStr(1,:), IntTestStr, 'exact')) == size(IntTestStr, 1), 
         OP1 = IntTestStr(1,:);
      else 
         OP1 = IntTestStr;
      end


% Get special data from objective function, use old and new syntax
   elseif strcmp(lower(WhatTask), 'getdata_objfun'),
      warning('Functionality moved to geaobjpara. Please change your source.');
      OP1 = [];


% Read input data for special project from text file
   % P1: Path and Filename of text-parameter-file
   % P2: cell array of valid option names
   % in most cases the new paraoptset is much better
   elseif strcmp(lower(WhatTask), 'parain_file'),
      FileNamePath = P1;
      % Define para necessary
      NamesInputPara = P2;
      OutOpt = [];
      
      % Read data from file, receive a structure
      InOpt = geaoptload(FileNamePath);

      % Get fieldnames of all InOpt
      InOptFieldNames = fieldnames_full(InOpt);
      InOptFieldNamesLow = lower(InOptFieldNames);
      
      for iname = 1:size(NamesInputPara,1),
         % Reset OptValue to empty matrix
         OptValue = [];

         % Check, if the current name is inside InOpt
         IxCmp = strcmp(InOptFieldNamesLow, lower(NamesInputPara{iname, 1}));

         % If this name is in InOpt
         if any(IxCmp),
            % Get index in InOpt name array
            IxFind = find(IxCmp == 1);
            % Get field value from InOpt
            OptValue = getfield(InOpt, InOptFieldNames{IxFind(1)});
            % Possible parameter checking
            
         end

         % Set checked option value in output structure with correct field name
         OutOpt = setfield(OutOpt, NamesInputPara{iname, 1}, OptValue);
       
      end
      
      OP1 = OutOpt;
      
      
   % Choose a number of best individuals according to their fitness 
   % the returned individuals are sorted best first
   elseif strcmp(lower(WhatTask), 'get_nbestind'),
      Chrom = P1; ObjV = P2; FitnV = P3; NumIndGet = P4;
      % Get number of individuals, variables and objective values
      [Nind, Nvar] = size(Chrom); NObj = size(ObjV, 2);
      % The number of returned individuals can not be larger than the one provided
      NumIndGet = min(NumIndGet, Nind);
      
      % Compare FitnV with maximum fitness value to get indizes of all non-dominated individuals
      IndNonDomIx = find(FitnV == max(FitnV));

      % If more individuals are returned than non-dominated, 
      % the best NumIndGet individuals contain all non-dominated individuals
	   if NumIndGet >= length(IndNonDomIx),
         % choose the best NumIndGet individuals for output by sort command
         [Dummy, SortIx] = sort(-FitnV);
         posbest = SortIx(1:NumIndGet);

      % Choose randomly from the non-dominated individuals
      else
         [Dummy, chInd] = sort(rand(NumIndGet, 1));
         % Only pareto-optimal solutions are chosen
         posbest = IndNonDomIx(chInd);
      end
      % Select individuals and objective values accordingly
      Chrom = Chrom(posbest, :); ObjV = ObjV(posbest, :);
      
      OP1 = Chrom; OP2 = ObjV; OP3 = posbest;


% If unknown option, issue an error message
   else
      warning(sprintf('%s: Unknown option for action! (%s)', mfilename, WhatTask));
   end


% End of function

