% Ask for the percentage of non-dominated individuals in a population
%
% This function implements the answer to the question:
% How many individuals of a given population are non-dominated (and
% the remainder is dominated)?
% Depending on the size of the population and the number of ojectives 
% this number changes dramatically (from only a few non-dominated to 
% nearly all individuals are non-dominated).
% The function is implemented as an objective function. Thus, it can be 
% used throughout the GEATbx (but especially for plotmesh).
% The parameters of the "individuals" are the size of the population
% and the number of objectives (optional). An additional parameter 
% to the function defines the multi-objective objective function to 
% use. Any of the many examples of the GEATbx an be used.
%
% The results of this experiment are published in:
% Bagot, Benoit and Pohlheim, Hartmut: Complementary Selection and 
% Variation for an Efficient Multiobjective Optimization of Complex 
% Systems. CEC2005, 2005.
% The paper can also be found at: http://pohlheim.com/publications.html
%
% Syntax:  ObjVal = asknondom(Chrom, MObjFun)
% 
%
% Input parameters:
%    Chrom     - Matrix containing the variables of the problem formulation.
%                Each line constitutes one population with the given size and
%                the given number of objectives.
%                Chrom(:,1): number of individuals in the population
%                Chrom(:,2): number of objectives of the used MO function
%    MObjFun   - (optional) String containing the name of the MO function to use
%                if omitted or NaN 'mobjfonseca2' is used
%
% Output parameters:
%    ObjVal    - Column vector containing the percentage of non-dominated 
%                individuals in the given populations.
%                
% See also: plotmesh, mobjfonseca2, objfun1, objfunoptset

% Author:   Hartmut Pohlheim
% History:  15.01.2005  file created


function ObjVal = asknondom(Chrom, MObjFun, varargin)

   % Compute population parameters
   [Nind, Nvar] = size(Chrom);

   % Check input parameters
   if nargin < 1, Chrom = []; end
   if isnan(Chrom), Chrom = []; end
   if isempty(Chrom), Chrom = [NaN, NaN, 1]; end
   ObjVal = [];
   
   if nargin < 2, MObjFun = []; end
   if isnan(MObjFun), MObjFun = []; end
   if isempty(MObjFun), MObjFun = 'mobjfonseca2'; end

   % Create option-structure
   if isnan(Chrom(1,1)), 
      if isnan(Chrom(1,2)),
         if Chrom(1,3) <= 10,
           ObjVal = objfunoptset( 'FunctionName', 'Non-Dominated Individuals 1' ...
                                , 'VarBoundMin', 1, 'VarBoundMax', Inf ...
                                , 'NumVarDefault', 2, 'NumVarMin', 1, 'NumVarMax', 3 ...
                                , 'NumObjDefault', 2, 'NumObjMin', 1, 'NumObjMax', 2 ...
                                );
         end
      end

   % Calculate objective values
   else
      ParaNumInd = round(Chrom(:,1));
      % Check if number of objectives is given
      if Nvar > 1, ParaNumMObj = round(Chrom(:,2)); else ParaNumMObj = []; end
      % Check if number of variables is given
      if Nvar > 2, ParaNumVar = round(Chrom(:,3)); else ParaNumVar = repmat(NaN, [Nind,1]); end
      % For statistical reasons multiple runs are performed and we use only the mean value
      NumofStats = 1;
      % Loop through all the given configurations/individuals
      for irun = 1:Nind,
         if irun == 1, fprintf(1, ' %s [%s] point: ', mfilename, MObjFun);
         elseif irun > 1, fprintf(1, '\b\b\b\b\b\b\b\b\b\b\b'); end
         fprintf(1, '%5g/%5g', irun, Nind);
         % Set the number of objectives to use for the current configuration
         if ~(isempty(ParaNumMObj(irun))),
            StateNObj = geaobjpara(MObjFun, [11 ParaNumMObj(irun)]);
         end
         
         for istat = 1:NumofStats,
            % Get VLUB of MO function
            VLUB = geaobjpara(MObjFun, [1 ParaNumVar(irun)]);
            % Get number of individuals of current population
            CurNumInd = ParaNumInd(irun,1);
            % Generate population of given size
            CurPop = initrp(CurNumInd, VLUB);
            % Calculate the objective values for the current population
            CurObjV = feval(MObjFun, CurPop, varargin{:});
            % Rank the current population objective values
            % Put all the ranking options into one array for later use
            % GEAOpt.Selection.Pressure; GEAOpt.Selection.RankingMethod; GEAOpt.Selection.RankingMultiobj
            RankOpt = [2; 0; 1]';
            [CurFitnV, CurRankV] = ranking(CurObjV, RankOpt, 1);
            % Get all rank values of 0 and calculate percentage
            CurRankNonDom(istat,1) = sum(CurRankV < 1);
         end
         ObjVal(irun,1) = 100 .* mean(CurRankNonDom) ./ CurNumInd;
         ObjVal(irun,2) = 100 .*  std(CurRankNonDom) ./ CurNumInd;
      end
   end


% End of function


% plotmesh('asknondom', [40, 3, 20; 230, 18, 30], [10, 25;NaN,NaN;0 100], 'mobjdtlz1')

      % plotmesh(PF{imesh,1}, PF{imesh,2}, PF{imesh,3}); 
      % eval(['print ' ' -d' PrintStyle ' ' PrintExt ' ',  ResPathMesh, PF{imesh,4} FileSuffix ';'])
      % disp([sprintf('%2d: ', imesh) 'Grafic saved as  ', ResPathMesh, PF{imesh,4} FileSuffix '   ' ]);
