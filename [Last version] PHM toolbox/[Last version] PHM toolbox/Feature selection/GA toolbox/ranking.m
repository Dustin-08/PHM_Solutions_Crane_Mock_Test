% RANK-based fitness assignment, single and multi objective, linear and nonlinear
%
% This function performs single and multi objective ranking of objective values. 
% Linear and nonlinear distribution of the fitness values is possible.
% Sharing between MO individuals (search space) and objective values (solution space)
% is possible.
%
% Syntax:  [FitnV, RankV] = ranking(ObjV, RankOpt, SUBPOP, Goals, Chrom, ShareOpt)
%
% This function ranks individuals represented by their associated
% cost, to be *minimized*, and returns a column vector FitnV
% containing the corresponding individual fitnesses. For multiple
% subpopulations the ranking is performed separately for each
% subpopulation. Different size of every subpopulation and multiple
% strategies are supported.
%
% Single and multi-objective ranking are supported. For multi-objective
% ranking the respective option must be set. Then PARETO ranking is
% performed and (if provided) Goals are used.
%
% The implementation follows in large parts the standard way of PARETO ranking 
% and goal attainment. For a good description have a look at many of the papers 
% of Carlos Fonseca (including his dissertation), for instance:
%  Fonseca, C. M.: Multiobjective Genetic Algorithms with Application to Control
%  Engineering Problems. Ph.D. Thesis, Department of Automatic Control and 
%  Systems Engineering, University of Sheffield, Sheffield, U.K., 1995.
%
% If individuals and ShareOpt are provided, sharing in search or solution space 
% is performed. The default method is sharing in search space. The switch to 
% sharing in solution space can be done at the end of the file inside the source 
% code (see ShareMethod).
%
% For multiple objetives single objective ranking can be enforced. Then only
% the first objective value ObjV(:,1) is used. The remaining objective values
% ObjV(:,2:end) are ignored.
%
% Input parameters:
%    ObjV      - Column vector/matrix containing the objective values of the
%                individuals in the current population (cost values).
%                if a matrix, multiobjective ranking assumed (at the moment
%                only singleobjective ranking - however, this is transparent)
%                each row corresponds to the objective value/s of one individual
%    RankOpt   - (optional) If RankOpt is a scalar in [1, 2] linear ranking is
%                assumed and the scalar indicates the selective pressure.
%                If RankOpt is a 2 or 3 element vector:
%                RankOpt(1): SP - scalar indicating the selective pressure
%                RankOpt(2): RM - ranking method
%                            RM = 0: linear ranking
%                            RM = 1: non-linear ranking
%                RankOpt(3): RMO - single/multi objective ranking
%                            RMO = 0: single objective ranking (even for multiple
%                                     objective values, first objective value 
%                                     ObjV(:,1) is only used for ranking)
%                            RMO > 0: multi objective ranking
%                If RankOpt is omitted or NaN, linear ranking, a selective
%                pressure of 2 and single objective ranking are assumed.
%                When RankOpt contains multiple rows (as many as subpopulations),
%                each row contains the parameters for one subpopulation. 
%                If RankOpt is a vector with length(RankOpt) > 3 it containes
%                the fitness to be assigned to each rank. Then it should have
%                at least the length of the longest subpopulation (or as many 
%                entries as rows in ObjV). Usually RankOpt is monotonously
%                decreasing. Rank 1 is the best individual!
%    SUBPOP    - (optional) Vector/scalar containing number of individuals
%                per subpopulation/number of subpopulations
%                if omitted or NaN, 1 subpopulation is assumed
%    Goals     - (optional) Row vector containing objective function goals for
%                multiobjective Pareto-ranking. Individuals who satisfy goals
%                are preferred in a Pareto fashion against these who do not
%                To satisfy a goal the respective objective value must be smaller 
%                or equal to the Goal value.
%    Chrom     - (optional) Column Vector/Matrix  of Chromosomes needed for fitness
%                sharing in Individual space. If omitted or NaN no sharing in 
%                individual space is performed
%    ShareOpt  - (optional) 2-row-matrix, first row contains parameter for sharing 
%                in individual space, second row for sharing in objective space.
%                3 Parameters:
%                   ShareOpt(:, 1): ShareSigma, minimum cluster size for the spaces
%                   ShareOpt(:, 2): ShareAlpha, penalty factor for single faults
%                   ShareOpt(:, 3): ShareBeta , penalty factor for summarized faults
%                If omitted or NaN ShareAlpha and ShareBeta are set to 1.
%                If ShareSigma is omitted or NaN sharing of applied space is not possible
%                see geamain2 for the calculation of the ShareOpt parameters
%
% Output parameters:
%    FitnV     - Column vector containing the fitness values of the
%                individuals in the current population.
%    RankV     - Column vector containing the (Pareto-) Rank of the 
%                Individuals in the current population
%
%
% Examples:
% % It is assumed in the first examples, that the variable objv contains a 
% % column of objective values.
%
% % This performs linear ranking with standard selective pressure, all objv 
% % are taken from individuals in one population
% >> ranking(objv)
%
% % The same as above, however, the objv are from 4 subpopulations
% >> ranking(objv, [], 4)
%
% % Use linear ranking with selective pressure 1.5
% >> ranking(objv, [1.5])
%
% % Use non-linear ranking with selective pressure 1.5
% >> ranking(objv, [1.5, 1])
%
% % Use different strategies for every of the three subpopulation. The 
% % first subpop works with nonlinear ranking and SP=1.5, the second uses
% % nonlinear ranking with SP=2.5 and the third linear ranking with SP=1.5.
% >> ranking(objv, [1.5 1; 2.5 1; 1.5 0], 3)
%
% % Similar to above, ranking method is computed internally. If SP > 2, 
% % nonlinear ranking is used, else linear ranking,
% % the different size of each subpopulation is given directly
% >> ranking(objv, [1.5; 2.5; 1.5], [11 23 16])
%
% % multiple objectives per individual: the variable MObjv contains an 
% % array of objective values.
% >> MObjv = [1 2 3; 1.5 2.5 3.5; 1 3 5; 2 1.4 8];
%
% % Perform multi-objective ranking with linear ranking and selective
% % pressure of 1.6, no sharing performed
% >> ranking(MObjv, [1.6 0 1])
%
% % Similar to above with different selective pressure for each subpopulation
% % and goals defined
% >> ranking(MObjv, [1.6 0 1; 1.2 0 1; 1.8 0 1; 1.4 0 1], 4, [1.6 2.9 4.2])
%
% % MO ranking with sharing, Chrom and ShareOpt are needed
% >> ranking(MObjv, [1.6 0 1; 1.2 0 1; 1.8 0 1; 1.4 0 1], 4, [1.6 2.9 4.2], [1 2; 1 3; 1 4; 1 5],[10; 1])
% % Perform this ranking once with ShareMethod=0 (sharing between individuals)
% % and once with ShareMethod=1 (sharing between objective values) and compare
% % the fitness  values (ShareMethod must be set in the source code)
%
% See also: selection, compdiv, rankgoal, rankshare

% Author:   Hartmut Pohlheim
% History:  04.03.1995  non-linear ranking
%           11.03.1995  multiple subpopulations
%           30.06.1996  incorporation of sort_nan in compdiv
%           27.07.1996  new format for SUBPOP introduced, vector contains now
%                          number of individuals for every subpopulation
%                       if Nind-2 > SP, than non-linear ranking normally not
%                          possible, added some code to adjust SP to the best
%                          matching value for this particular subpopulation,
%                          needed for competing subpopulations
%           20.10.1996  sort_nan is not necessary, sort is correct
%                       reverse of RankOpt is now computed
%           01.11.1998  update for multiple strategies (different selection 
%                          pressure and  ranking method per subpopulation)
%           07.11.1998  rework of parameter settings and parameter tests
%                       RFunLoop for nonlinear ranking is calculated now
%                       useful values for all non-given parameters are defined
%                       Examples added to help text
%           09.05.1999  multi-objective ranking included
%                       additionell output rank values and input Goals
%           09.10.1999  selection of objective values for mo-ranking possible
%                          (define NaN in Goals)
%           17.10.1999  preset of Goal values included
%           13.01.2001  Pareto-ranking optimized
%           24.06.2001  Goals in medium-speed MO-Ranking included
%           16.09.2001  Fitness sharing included
%           05.05.2002  fitness sharing in search and solution space, is switched
%                          off when no input of Chrom or ShareOpt
%                       simple visu for fitness changes by sharing (commented out)
%           20.10.2002  help text reworked, MO examples included
%           10.12.2004  sharing inside the function (at the end) explained, 
%                       now both methods - sharing in search and solution space 
%                          are directly available (sharing between individuals and 
%                          objective values)
%                       added example for sharing


function [FitnV, RankV] = ranking(ObjV, RankOpt, SUBPOP, Goals, Chrom, ShareOpt);

   % Backup nargin and nargout
   NAIN = nargin; NAOUT = nargout;

   % Identify the population size
   [Nind, NObj] = size(ObjV);

   % Define default parameters
   RankOptStandard = [2, 0, 0];      % SP = 2, Lin/NonLinRank = 0, MultiOpt = 0
   usedMemory = 4 * 32000001;        % real RAM for use in MO-Ranking, Standard is 32MB for 128MB - Systems
   
   % Check input parameters
   if NAIN < 2, RankOpt = []; end
   if isnan(RankOpt), RankOpt = []; end
   if isempty(RankOpt), RankOpt = RankOptStandard; end
   if size(RankOpt, 2) == 1, RankOpt(:, 2:3) = RankOptStandard(2:3);
   elseif size(RankOpt, 2) == 2, RankOpt(:, 3) = RankOptStandard(3); end
   if size(RankOpt, 2) > size(RankOptStandard, 2), RankOpt = RankOpt(:, 1:3); end
   
   if NAIN < 3, SUBPOP = []; end
   SUBPOP = compdiv('checksubpop', SUBPOP, Nind);


   % Get size of RankOpt
   [ROrow, ROcol] = size(RankOpt);

   % If ranking method is not defined, set it to zero (linear) or one (non-linear, when SP larger 2)
   % use single objective ranking as default
   if ROcol == 1, RankOpt = [RankOpt, RankOpt > 2, RankOptStandard(3)*ones(size(RankOpt))]; end
   
   % Replicate as often as subpops
   if ROrow == 1, 
      RankOptIntern = RankOptStandard; RankOptIntern(1:length(RankOpt)) = RankOpt;
      RankOpt = repmat(RankOpt, [length(SUBPOP), 1]);
   end

   % Check selective pressure for smaller than 1 and reset if necessary
   if all([size(RankOpt, 2) <= 3])
      if any(isnan(RankOpt(:, 1))), IxNaN = isnan(RankOpt(:, 1)); RankOpt(IxNaN, 1) = RankOptStandard(1); end
      if any(isnan(RankOpt(:, 2))), IxNaN = isnan(RankOpt(:, 2)); RankOpt(IxNaN, 2) = (RankOpt(IxNaN, 1) > 2); end
      if any(RankOpt(:, 1) < 1), warning('At least one selective pressure is smaller than one!'); end
      RankOpt(:, 1) = max(1, RankOpt(:, 1));
      % RankOpt(:, 2) = fix(RankOpt(:, 2));
      if any(RankOpt(:, 2) > 1), warning('At least one ranking method is larger than allowed (0, 1]!'); end
      RankOpt(:, 2) = (fix(RankOpt(:, 2)) > 0);
   end
   
   
   
   % Preset Goals for multiobjective ranking
   if NAIN < 4, Goals = []; end
   if all([any(RankOpt(:, 3) >= 1), ~(isempty(Goals))]),
      [Gind, GObj] = size(Goals);
      if GObj ~= NObj,
         % Warning disabled, is not really necessary
         % warning('The size of the goal vector and the number of multiple objective values disagree! Missing values are set to Inf.');
         if GObj > NObj, Goals = Goals(1, 1:NObj); else Goals(1, GObj+1:NObj) = Inf; end
      end
      if any(isnan(Goals)),
         UseObjVIx = find(~(isnan(Goals)));
         ObjV = ObjV(:, UseObjVIx);
         Goals = Goals(UseObjVIx);
      end 
   else Goals(1, 1:NObj) = Inf; end
  
   % Check Chromosomes
   if NAIN < 5, Chrom = []; end
   if isnan(Chrom), Chrom = []; end
  
   % Check ShareOpt
   if NAIN < 6, ShareOpt = []; end
   if isnan(ShareOpt), ShareOpt = []; end

   RankOptAll = RankOpt;
   
   FitnV = []; RankV = [];


   % loop over all subpopulations
   for irun = 1:length(SUBPOP),
      % Get number of individuals in actual subpopulation
      Nind = SUBPOP(irun);

      if Nind == 1, FitnVSub = 1;
      else

         % Check ranking function and use default values if necessary
         RankOpt = RankOptAll(irun,:);

         % When selective pressure and ranking method and single/multi objective ranking is defined
         if size(RankOpt, 2) <= 3,
            % linear ranking, check selective pressure and reset if necessary
            if RankOpt(2) == 0,
               if RankOpt(1) > 2,
                  warning('Selective pressure for linear ranking can not be larger than 2! Internally changed to nonlinear ranking!');
                  RankOpt(2) = 1;
               end
            end
            % non-linear ranking
            if RankOpt(2) == 1,     % check selective pressure and adjust if necessary/possible
               % For nonlinear ranking selective pressure must be smaller Nind-2
               RankOpt(1) = min(RankOpt(1), Nind-2);
               % If selective pressure would be smaller 1, reset to standard linear ranking
               if RankOpt(1) < 1, RankOpt = [RankOptStandard(1), 0, RankOpt(3)]; end
            end

            % compute the RFunLoop values
            % Nonlinear ranking
            if RankOpt(2) == 1,
               % Compute the root of this polynom
               Root1 = roots([RankOpt(1)-Nind [RankOpt(1)*ones(1,Nind-1)]]);
               % disp(sprintf('%12.6g  %12.6g', Root1(1), Root1(1)^Nind));
               RFunLoop = (abs(Root1(1)) * ones(Nind,1)) .^ [(Nind-1:-1:0)'];
               RFunLoop = RFunLoop / sum(RFunLoop) * Nind;

            % linear ranking (with selective pressure SP between 1 and 2)
            elseif RankOpt(2) == 0,
               RFunLoop = 2-RankOpt(1) + 2*(RankOpt(1)-1)*[Nind-1:-1:0]'/(Nind-1);
            end

         % When fitness values are defined
         else 
            if length(RankOpt) < Nind,
               warning('Not enough fitness values for individuals defined! Using zero for missing fitness values.');
            end
            % Set not defined fitness values to zero
            RFunLoop = zeros([1, Nind]);
            % Select needed fitness values
            RFunLoop(1:min(Nind, length(RankOpt))) = RankOpt(1:min(Nind, length(RankOpt)));
         end;

         % Copy objective values of actual subpopulation
         ObjVSub = ObjV(sum(SUBPOP(1:irun-1))+1:sum(SUBPOP(1:irun)),:);

		   % Check for multiobjective ranking
         if all([NObj > 1, RankOpt(3) >= 1]),
            % if no goals are used or all goals from all individuals are satisfied or not
            % standard Pareto Ranking is used
            temp = repmat(Goals(1, :), [Nind 1]);
            not_sat = all(all(ObjVSub > temp));
            sat = all(all(ObjVSub <= temp));
            % compute needed Memory for fast and medium pareto
            memfast = 3 * Nind^2 * NObj * 8 + Nind^2 * 8;
            memmed  = 3 * Nind * NObj * 8;
            % fprintf(1, '\nMem for fast:  %e;  Mem for medium:  %e;  defined max Mem:  %e\r', memfast, memmed, usedMemory);
            
            % Check if fastest ranking should be used
            if ((memfast <= usedMemory) & (sat | not_sat)),
               % 2 Tensors are put together in a way, that all solutions 
               % can be compared by partially less
               Tensor1 = repmat(ObjVSub , [1 1 Nind]);
               Tensor2 = repmat(ObjVSub', [1 1 Nind]);
               Tensor2 = shiftdim(Tensor2, 2);
               % since identical individuals are not p<
               % they must get an offset for every equal individual
               % that exists
               tempT = (Tensor1 == Tensor2);
               temp =  - all(tempT, 2);
               % together with Tensor1==Tensor2 partially less is realized
               tempT = (Tensor1 <= Tensor2);
               temp = temp + all(tempT, 2);
               temp = squeeze(temp);
               RankMOV = sum(temp)';

            % Check if medium ranking should be preferred or goals are considered
            elseif (memmed <= usedMemory),
               % Every individual compared with all others by p< in a loop
               RankMOV = zeros(Nind, 1);
               for i=1:Nind
                  i_not = find(ObjVSub(i, :) >  Goals);
                  i_sat = find(ObjVSub(i, :) <= Goals);
                  temp2 = repmat(ObjVSub(i, :), [Nind 1]);
                  % test, if no Goal is satisfied
                  if length(i_not) == NObj, RankMOV = RankMOV + all([temp2 <= ObjVSub, any(temp2 < ObjVSub, 2)], 2);
                  % test if all Goals are satisfied
                  elseif length(i_sat) == NObj,
                     RankMOV = RankMOV + any([any(ObjVSub > temp, 2), ...
                                              all([temp2 <= ObjVSub, any(temp2 < ObjVSub, 2)], 2)], 2);
                  % mixed case                      
                  else RankMOV = RankMOV + all([all(temp2(:, i_not) <= ObjVSub(:, i_not), 2), ...
                                                any([any(ObjVSub(:, i_sat) > temp(:, i_sat), 2), ...
                                                     all([all(temp2(:, i_sat) <= ObjVSub(:, i_sat), 2), any(temp2(:, i_sat) < ObjVSub(:, i_sat), 2)] ... 
                                                     , 2)] ...
                                                , 2)] ...
                                           , 2);
                  end
               end

            % if nothing goes the normal ranking is used
            else
               % Standard Pareto with Goals (Legacy)
               % loop and sum for each individual
               RankMOV = zeros(Nind, 1);
               for i=1:Nind, for j=1:Nind, RankMOV(i) = RankMOV(i) + rankgoal(ObjVSub(j,:), ObjVSub(i,:), Goals); end, end
            end

	         ObjVSub = RankMOV;
   	      RankV = [RankV; RankMOV];
         else ObjVSub = ObjVSub(:, 1); end


         % Single objective ranking, sort ObjV/RankMOV
         [Sorted, PosSort] = sort(ObjVSub);

         % Assign fitness according to RFunLoop.
         i = 1;
         FitnVSub = zeros(Nind,1);
         for j = [find(Sorted(1:Nind-1) ~= Sorted(2:Nind)); Nind]',
            FitnVSub(i:j) = sum(RFunLoop(i:j)) * ones(j-i+1,1) / (j-i+1);
            i = j + 1;
         end

         % Create unsorted vector.
         [dummy, PosSortBack] = sort(PosSort);
         FitnVSub = FitnVSub(PosSortBack);

      end
      
      % Add FitnVSub to FitnV
      FitnV = [FitnV; FitnVSub];
   end

   % Perform fitness-sharing if possible
   % ShareMethod = 0: search space (between individuals), = 1: solution space (between ObjV)
   ShareMethod = 0;
   % if all([NObj > 1, RankOpt(3) >= 1, size(ShareOpt, 1) > 1]), FitnV = rankshare(ObjV, FitnV, ShareOpt(2, :)); end
   if all([size(Chrom, 2) > 1, RankOpt(3) >= 1, size(ShareOpt, 1) > 0]),

      % For sharing in search space (between individuals)
      if ShareMethod == 0,
         FitnVShare = rankshare(Chrom, FitnV, ShareOpt(1,:));

      % For sharing in objective space (between objective values)
      elseif ShareMethod == 1,
         FitnVShare = rankshare(ObjV, FitnV, ShareOpt(2,:));
      else
         warning('Wrong sharing method defined! Only 0 and 1 are possible.');
      end

      % If we want to plot the fitness values before and after sharing
      % FitnVDiff = FitnV - FitnVShare; 
      % figure(10); plot([1:length(FitnV)], FitnV, 'g*', [1:length(FitnVShare)], FitnVShare, 'b.', [1:length(FitnVDiff)], FitnVDiff, 'r.')

      % Assign the shared fitness values as new fitness values
      FitnV = FitnVShare;

   end


% End of function
